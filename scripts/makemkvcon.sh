#!/usr/bin/bash
#
# makemkvcon.sh [switches] MODE INPUT [OUTPUT]
#
# podman run -it --rm \
#   --volume ${INPUT}:/input[.iso]:ro,Z \
#   [--volume ${OUTPUT}:/output:rw,Z] \
#   ${IMAGE} \
#   ${MODE}

#: DEBUG=${DEBUG:='echo'}
: MODE=${MODE:='info'}
: INPUT=${INPUT:=$(pwd)}
: OUTPUT=${OUTPUT:=''}
: IMAGE=${IMAGE:='ghcr.io/markllama/makemkvcon:latest'}
: EXTENSION=${EXTENSION:=''}

function main(){
    parse_args $*

    # output spec --volume /output:
    ${DEBUG} podman run -it --rm \
      --volume ${INPUT}:/input${EXTENSION}:ro,Z \
      ${OUTPUT_SPEC} \
      ${IMAGE} \
      ${MODE}
}

function parse_args(){
    # use getopt for switches

    # Left over are [MODE] [INPUT] [OUTPUT]

    [ $# -ge 1 ] && MODE=$1 ; shift
    # Check that mode is in (info|backup|mkv)

    [ $# -ge 1 ] && INPUT=$1 ; shift
    # Check if INPUT is file or dir
    [ -f ${INPUT} ] && EXTENSION='.iso'

    [ $# -ge 1 ] && OUTPUT=$1 ; shift
    # Check that output is DIR and writable

    if [ "${MODE}" == 'mkv' ] ; then
	OUTPUT_SPEC="--volume ${OUTPUT}:/output:rw,Z"
    fi
}

main $*
