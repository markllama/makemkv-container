#!/usr/bin/bash
# ----------------------------------------
# Build a container for dhcpd from scratch
# ----------------------------------------

# To tag and publish the image
# buildah tag localhost/dhcpd quay.io/markllama/dhcpd
# buildah push quay.io/markllama/dhcpd

# Stop on any error 
set -o errexit

SCRIPT=$0

OPT_SPEC='a:b:c:s:r:'

DEFAULT_SERVICE="makemkvcon"
DEFAULT_SOURCE_ROOT="build/model"
DEFAULT_AUTHOR="Guinpin Software Inc. <markllama@gmail.com>"
DEFAULT_BUILDER="Mark Lamourine <markllama@gmail.com>"
DEFAULT_BASE=scratch

: SERVICE="${SERVICE:=${DEFAULT_SERVICE}}"
: SOURCE_ROOT="${SOURCE_ROOT:=${DEFAULT_SOURCE_ROOT}}"
: AUTHOR="${AUTHOR:=${DEFAULT_AUTHOR}}"
: BUILDER="${BUILDER:=${DEFAULT_BUILDER}}"
: BASE="${BASE:=${DEFAULT_BASE}}":

# podman run -v <key_file>:/keyfile -v <dir>:/input [-v <dir>:/output] quay.io/markllama/makemkv <info|backup|mkv> <input type> <input file> [<track ids> <output dir>]

# /usr/bin/makemkv

function main() {

    parse_args $*

    # Create a container
    local container=$(buildah from --name $SERVICE ${BASE})

    buildah config --workingdir / $container
	
    # add a volume to include the configuration file
    # Leave the files in the default locations 
    buildah config --env "LD_LIBRARY_PATH=/usr/lib64:/usr/lib" $container
    buildah config --env "HOME=/home" $container
    buildah config --env 'MAKEMKV_KEY=' $container

#	buildah config --volume /config $container
    buildah config --volume /input $container
    buildah config --volume /output $container

    # # Define the startup command
    buildah config --entrypoint '["/usr/bin/entrypoint"]' $container

    buildah config --author "${AUTHOR}" $container
    buildah config --created-by "${BUILDER}" $container
    buildah config --annotation description="MakeMKV 2.0.0" $container
    buildah config --annotation license="Copyright (C) 2007-2026 GuinpinSoft inc" $container

    buildah copy $container build/tools/model build/tools/resolved /
    buildah copy $container build/model build/resolved /
    buildah copy $container scripts/entrypoint.sh /usr/bin/entrypoint
    
    # # Save the container to an image
    buildah commit --squash $container $SERVICE

	# name for quay registry
#	buildah tag localhost/makemkvcon quay.io/markllama/makemkvcon:latest
	# tag for github registry
    buildah tag localhost/makemkvcon ghcr.io/markllama/makemkvcon:latest

    podman rm ${SERVICE}
}

function parse_args() {
    local opt
    
    while getopts "${OPT_SPEC}" opt; do
	case "${opt}" in
	    a)
		AUTHOR=${OPTARG}
		;;
	    b)
		BUILDER=${OPTARG}
		;;
	    c)
		CONTAINER_ID=${OPTARG}
		;;
	    s)
		SERVICE=${OPTARG}
		;;
	    r)
		ROOT=${OPTARG}
		;;
	esac
    done
}

# == Call main after all functions are defined
main $*
