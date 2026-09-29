#!/bin/bash
set -e

: BUILD_ROOT=${BUILD_ROOT:=${PWD}/build}
: MODEL_ROOT=${MODEL_ROOT:=${BUILD_ROOT}/model}
: LIBRARY_PATH=${LIBRARY_PATH:=${MODEL_ROOT}/usr/lib:${MODEL_ROOT}/usr/lib64}
: RESOLVED_ROOT=${RESOLVED_ROOT:=${BUILD_ROOT}/resolved}
: PACKAGE_ROOT=${PACKAGE_ROOT:=${BUILD_ROOT}/packages}
: PACKAGE_ARCH=${PACKAGE_ARCH:=$(uname -m)}
: UNPACK_ROOT=${UNPACK_ROOT:=${BUILD_ROOT}/unpack}

SCRIPT_DIR=$(dirname $0)
source ${SCRIPT_DIR}/shared_object_lib.sh

function main() {

    # make it simple to branch based on the working OS environment
    set_os_id # now ${ID} in [fedora|debian|ubuntu]
    echo "- OS_ID=${ID}"

    #dnf install -yes --installroot ${MODEL_ROOT} -- setopt install_weak_deps=false

    echo "- Preparing Model Tree ${MODEL_ROOT}"
    prepare_model_tree ${MODEL_ROOT}

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
    #echo "Libraries: ${libraries}"
    local packages=$(resolve_packages $libraries)
    
    echo "- Downloading package files to ${PACKAGE_ROOT}"
    #echo "Packages: ${packages}"
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
    mkdir -p ${RESOLVED_ROOT}/usr/lib
    
    populate_libraries ${UNPACK_ROOT} ${RESOLVED_ROOT} ${libraries}

    # # Copy the linker/loader shared library
    cp ${UNPACK_ROOT}/lib64/ld-linux-x86-64.so.* ${RESOLVED_ROOT}/usr/lib
}

#
#
#
main $*
