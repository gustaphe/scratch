#!/bin/bash
backend=${0}
jobid=${1}
cupsuser=${2}
jobtitle=${3}
jobcopies=${4}
joboptions=${5}
jobfile=${6}

rmapi=/usr/bin/rmapi
export RMAPI_CONFIG=$(eval echo ~${cupsuser}/.config/rmapi/rmapi.conf)

printtime=$(date +%Y-%m-%dT%H:%M)
sanitized_jobtitle="$(echo ${jobtitle} | tr [[:blank:]:/%\&=+?\\\\#\'\`\´\*] _ | sed 's/ü/u/g;s/ä/a/g;s/ö/o/g;s/Ü/U/g;s/Ä/A/g;s/Ö/O/g;s/{\\ß}/ss/g;s/ /_/g' | cut -f 1 -d '.' ).pdf"
outname=/tmp/${printtime}_${sanitized_jobtitle}

#echo "$(date +%Y-%m-%d:%T%H:%M):\t${1}\t${2}\t${3}\t${4}\t${5}\t${6}" >> /tmp/cupslog #DEBUG

case ${#} in
    0)
        # this case is for "backend discovery mode"
        echo "Remarkable Printer \"Mark Meyer\" \"Backend to print directly to Remarkable cloud\""
        exit 0
        ;;

    5)
        # backend needs to read from stdin if number of arguments is 5
        cat - > ${outname}
	if [ ! -e ${DEVICE_URI#remarkable:} ]; then
	    ${rmapi} put ${outname} ${DEVICE_URI#remarkable:}
	else
	    ${rmapi} put ${outname}
	fi
	rm ${outname}
        ;;
    
    6)
	if pdfinfo "${jobfile}" > /dev/null ; then
		# jobfile is a pdf
		cp "${jobfile}" ${outname}
	else
		# jobfile is not a pdf, assume ps
		ps2pdf "${jobfile}" ${outname}
	fi
        if [ ! -e ${DEVICE_URI#remarkable:} ]; then
	    ${rmapi} put ${outname} ${DEVICE_URI#remarkable:}
	else
	    ${rmapi} put ${outname}
	fi
        ;;
esac

echo 1>&2

exit 0
