#!/bin/bash
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
DEFAULT_AUTHOR="Mark Lamourine <markllama@gmail.com>"
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

    if [ -z "${BUILDAH_ISOLATION}" -o -z "${CONTAINER_ID}" ] ; then
	# Create a container
	local container=$(buildah from --name $SERVICE ${BASE})

	if [ -z "${BUILDAH_ISOLATION}" ] ; then
	    # Run the file copy in an unshare environement
	    buildah unshare bash $0 -c ${container} -s ${SOURCE_ROOT}
	else
	    # Already in an unshare environment
	    copy_model_tree ${SOURCE_ROOT} ${container}
	fi

	buildah config --workingdir / $container
	
	# add a volume to include the configuration file
	# Leave the files in the default locations 
	buildah config --env 'MAKEMKV_KEY=' $container
	buildah config --env "HOME=/" $container
	buildah config --env "LD_LIBRARY_PATH=/usr/lib64:/usr/lib" $container

	buildah config --volume /config $container

	buildah config --volume /input $container
	buildah config --volume /output $container

	# # open ports for listening
#	buildah config --port 68/udp --port 69/udp ${container}

	# # Define the startup command
	#buildah config --entrypoint "/usr/bin/bash" $container
	#buildah config --cmd "/usr/bin/makemkvcon" $container

	buildah config --author "${AUTHOR}" $container
	buildah config --created-by "${BUILDER}" $container
	buildah config --annotation description="MakeMKV 1.18.4" $container
	buildah config --annotation license="Copyright (C) 2007-2025 GuinpinSoft inc" $container

	# # Save the container to an image
	buildah commit --squash $container $SERVICE

	buildah tag localhost/makemkvcon quay.io/markllama/makemkvcon

	podman rm ${SERVICE}

    else
	# Only the copy needs to happen in an unshare environment
	copy_model_tree ${SOURCE_ROOT} ${CONTAINER_ID}
    fi
}

function copy_model_tree() {
    set -x
    local source_root=$1
    local container_id=$2
    
    # Access the container file space
    local mountpoint=$(buildah mount ${container_id})

    [ -z ${DEBUG} ] || (echo EMPTY ; cd ${mountpoint} ; pwd ; find . -type f)

    
    # Create the model directory tree
    (cd ${source_root} ; find * -type d) | xargs -I{} mkdir -p ${mountpoint}/{}

    cp -r ${source_root}/* ${mountpoint}
    
    # Create volume mount points
    mkdir -p ${mountpoint}/tmp

    mkdir -p ${mountpoint}/input
    mkdir -p ${mountpoint}/output

    # If you pass in the settings file in /config
    mkdir -p ${mountpoint}/.MakeMKV
    ln -s /config ${mountpoint}/.MakeMKV/settings.conf

    [ -z ${DEBUG} ] || (echo FULL ; cd ${mountpoint} ; pwd ;  find . -type f)

    # Release the container file space
    buildah unmount ${container_id}
    set +x
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
