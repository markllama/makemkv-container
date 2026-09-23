#!/bin/bash
set -e

: BUILD_ROOT=${BUILD_ROOT:=${PWD}/build}
: MODEL_ROOT=${MODEL_ROOT:=${BUILD_ROOT}/model}
: LIBRARY_PATH=${LIBRARY_PATH:=${MODEL_ROOT}/usr/lib:${MODEL_ROOT}/usr/lib64}
: PACKAGE_ROOT=${PACKAGE_ROOT:=${BUILD_ROOT}/packages}
: PACKAGE_ARCH=${PACKAGE_ARCH:=$(uname -m)}
: UNPACK_ROOT=${UNPACK_ROOT:=${BUILD_ROOT}/unpack}

function main() {

    # make it simple to branch based on the working OS environment
    set_os_id # now ${ID} in [fedora|debian|ubuntu]
    echo "- OS_ID=${ID}"

    #dnf install -yes --installroot ${MODEL_ROOT} -- setopt install_weak_deps=false

    echo "- Preparing Model Tree ${MODEL_ROOT}"
    prepare_model_tree ${MODEL_ROOT}

    # Lay in some diagnostic tools: bash, ldd, ls...
    echo "- Overlaying Tools into model tree ${MODEL_ROOT}"
    overlay_tools ${MODEL_ROOT}

    # clean up old runs
    echo "- Clean up package and unpacking trees: ${PACKAGE_ROOT} ${UNPACK_ROOT}"
    rm -rf ${PACKAGE_ROOT}/*
    rm -rf ${UNPACK_ROOT}/*

    echo "- Locating binaries in ${MODEL_ROOT}"
    local binaries=$(find_dynamic_binaries ${MODEL_ROOT})

    echo "- Identifying shared objects required by binaries"
    # Identify the shared libraries that must be resolved for the dynamic binaries
    local libraries=$(find_dynamic_libraries "${LIBRARY_PATH}" ${binaries})

    echo "- Resolving packages that provide the required shared objects"
    echo "Libraries: ${libraries}"
    local packages=$(resolve_packages $libraries)
    
    echo "- Downloading package files to ${PACKAGE_ROOT}"
    echo "Packages: ${packages}"
    mkdir -p ${PACKAGE_ROOT}
    local package_name
    for package_name in ${packages} ; do
     	download_package ${PACKAGE_ROOT} ${package_name}
    done

    # Prepare Unpacking tree
    echo "- Preparing a location to unpack packages: ${UNPACK_ROOT}"
    mkdir -p ${UNPACK_ROOT}
    [ -d ${UNPACK_ROOT}/lib -o -L ${UNPACK_ROOT}/lib ] || ln -s usr/lib ${UNPACK_ROOT}/lib 
    [ -d ${UNPACK_ROOT}/lib64 -o -L ${UNPACK_ROOT}/lib64 ] || ln -s usr/lib64 ${UNPACK_ROOT}/lib64

    local pkg_file
    for pkg_file in $(ls ${PACKAGE_ROOT}/*) ; do
	unpack_package ${pkg_file} ${UNPACK_ROOT}
    done

    # Copy each library file from the unpack tree to the model
    populate_libraries ${UNPACK_ROOT} ${MODEL_ROOT} ${libraries}

    # # Flatten lib64 libraries to make dynamic linking simpler in the container
    # # Copy the linker/loader shared library
    #cp ${UNPACK_ROOT}/lib64/ld-linux-x86-64.so.* ${MODEL_ROOT}/lib64    
}

# --------------------------------------------------------------------------------
# Functions
# --------------------------------------------------------------------------------

# make it easier to use pkg specific variant functions
function set_os_id() {
    eval "export $(grep -e '^ID=' /etc/os-release)"
}

function prepare_model_tree() {
    local model_root=$1

    [ -d ${model_root}/usr/bin ] || mkdir -p ${model_root}/usr/bin
    [ -d ${model_root}/usr/lib ] || mkdir -p ${model_root}/usr/lib
    [ -d ${model_root}/usr/lib64 ] || mkdir -p ${model_root}/usr/lib64
    
    [ -L ${model_root}/bin ] || ln -s usr/bin ${model_root}/bin
    [ -L ${model_root}/lib ] || ln -s usr/lib ${model_root}/lib
    [ -L ${model_root}/lib64 ] || ln -s usr/lib ${model_root}/lib64
}

function overlay_tools() {
    local model_root=$1
    
    # Add debugging tools: bash and ldd
    cp /usr/bin/bash ${model_root}/usr/bin/bash
    [ -L ${model_root}/usr/bin/sh ] || ln -s bash ${model_root}/usr/bin/sh
    cp /usr/bin/ls ${model_root}/usr/bin/ls
    cp /usr/bin/ldd ${model_root}/usr/bin/ldd


}

# Generate a list of dynamically linked binaries under a file root
function find_dynamic_binaries() {
    local model_root=$1

    [ -z "${DEBUG}" ] || echo "discovering dynamic binaries in ${model_root}" >&2

    find ${model_root} -type f |
	xargs file | grep executable |
	grep 'dynamically linked' |
	cut -d: -f1
}

# Generate a list of dynamic libraries required by a matching list of
# dynamically linked binaries
function find_dynamic_libraries() {
#
# find shared libraries linked to the specified binary
#
    local library_path=$1
    shift
    local binaries=$*

    [ -z "${DEBUG}" ] || echo "discovering shared libraries on ${binary}" >&2

    # Select Only lines with filenames and only one file path
    LD_LIBRARY_PATH="${library_path}" ldd ${binaries} |
	grep '=>' |
        sed 's/^.*=> //' |
	cut -d' ' -f1 |
	grep -v ${MODEL_ROOT} |
	sort -u

}

function resolve_packages() {
    local libraries="$*"
    
    # Accumulate the list of packages that provide the required libraries
    declare -a pkgs
    local library_file
    for library_file in $libraries ; do
    	pkgs+=($(find_file_package $library_file))
    done
    # Remove any duplicates
    echo ${pkgs[@]} | tr ' ' '\n' | sort -u

}

# Determine what package provides a given file
function find_file_package() {
    local library=$1

    case ${ID} in
	fedora | redhat | centos)
	    rpm -qf --qf "%{NAME}\n" ${library}
	    ;;

	debian | ubuntu)
	    # debian resolves to /lib* but the package installs /usr/lib*
	     dpkg --search /usr${library} | cut -d: -f1
	     ;;

	*)
	    echo "FATAL: OS not supported: ${OS_ID}.  Valid: debian | ubuntu | fedora | redhat" >&2
	    exit 1
	    ;;
    esac
}

# Download a package to a given location
function download_package() {
    local package_dir=$1
    local package_name=$2

    case ${ID} in
	fedora | redhat | centos)
	    dnf download --arch ${PACKAGE_ARCH} --destdir ${package_dir} ${package_name}
	    ;;

	debian | ubuntu)
	    (cd ${package_dir} ; apt-get download ${package_name})
	    ;;

	*)
	    echo "FATAL: OS not supported: ${OS_ID}.  Valid: debian | ubuntu | fedora | redhat" >&2
	    exit 1
	    ;;
    esac
}

#
# Unpack a package into a working directory
#
function unpack_package() {
    set -x
    local package_filename=$1
    local unpack_root=$2

    case ${ID} in
	fedora | redhat | centos)
	    rpm2cpio ${package_filename} | cpio -idmu --quiet --directory ${unpack_root}
	    ;;
	debian | ubuntu)
	    dpkg-deb --extract ${package_filename} ${unpack_root}
	    ;;
	*)
	    echo "FATAL: OS not supported: ${OS_ID}.  Valid: debian | ubuntu | fedora | redhat" >&2
	    exit 1
	    ;;
    esac
    set +x
}

function populate_libraries() {
    local unpack_root=$1
    local model_root=$2
    shift ; shift
    local libraries=$*
    
    # Copy the required library files to the model
    local library_file
    for library_file in $libraries ; do
	local library_dir=$(dirname ${library_file})
	[ -d ${model_root}${library_dir} -o -L ${model_root}${library_dir} ] ||
	    mkdir -p ${model_root}${library_dir}
#	cp ${unpack_root}${library_file} ${model_root}${library_dir}
	cp ${unpack_root}${library_file} ${model_root}/usr/lib
    done
}

#
#
#
main $*
