#!/usr/bin/bash
#
# collect arguments and exec makemkvcon to convert a video input
#
#
: MAKEMKVCON=${MAKEMKVCON:=/usr/bin/makemkvcon}
: MODE=${MODE:=info}
: SELECT=${SELECT:=all}
: INPUT=${INPUT:=/input}
: OUTPUT=${OUTPUT:=/output}

# makemkvcon info /input.iso
# makemkvcon info /input

# makemkvcon mkv /input.iso <all|N[,N]... /output
# makemkvcon mkv /input /output

# makemkvcon backup /input.iso /output
# makemkvcon backup /input /output

function main() {

    # MODE can be passed in as the first command
    [ $# -ge 1 ] && MODE=$1 && shift
    [ $# -ge 1 ] && SELECT=$1 && shift
    [ $# -ge 1 ] && INPUT=$1 && shift
    [ $# -ge 1 ] && OUTPUT=$1 && shift
    
    # If a file is provided assume it's an iso
    [ -r /input.iso ] && INPUT=/input.iso

    # info only requires input
    [ "${MODE}" == 'info' ] && SELECT='' && OUTPUT=''

    # TODO: check for devices? /dev/sr* and /cdrom

    exec ${MAKEMKVCON} ${MODE} ${INPUT} ${SELECT} ${OUTPUT}
    #${MAKEMKVCON} ${MODE} ${INPUT} ${OUTPUT}
}

#
main $*

