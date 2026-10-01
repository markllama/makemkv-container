#!/usr/bin/bash
#
# makemkvcon.sh [switches] MODE INPUT [OUTPUT]
#
# podman run -it --rm \
#   --volume ${INPUT}:/input[.iso]:ro,Z \
#   [--volume ${OUTPUT}:/output:rw,Z] \
#   ${IMAGE} \
#   ${MODE}

: DEBUG=${DEBUG:='echo'}
: MODE=${MODE:='info'}
: INPUT=${INPUT:=$(pwd)}
: OUTPUT=${OUTPUT:=''}


function main(){
    parse_args $*

    local extension
    
    ${DEBUG} podman run -it --rm \
      --volume ${INPUT}:/input${extension}:ro,Z \
      ${OUTPUT_SPEC} \
      ${IMAGE} \
      ${MODE}
}

function parse_args(){
    echo Parsing

    # use getopt for switches
    # Left over are [MODE] [INPUT] [OUTPUT]
    # Check that mode is in (info|backup|mkv)
    # Check if INPUT is file or dir
    # Check that output is DIR and writable

    
}

main $*
