#!/bin/bash

BINDIR=/usr/bin

: BUILD_ROOT=${BUILD_ROOT:=${PWD}/build}
: MODEL_ROOT=${MODEL_ROOT:=${BUILD_ROOT}/tools/model}
: LIBRARY_PATH=${LIBRARY_PATH:=${MODEL_ROOT}/usr/lib:${MODEL_ROOT}/usr/lib64}
: RESOLVED_ROOT=${RESOLVED_ROOT:=${BUILD_ROOT}/tools/resolved}
: PACKAGE_ROOT=${PACKAGE_ROOT:=${BUILD_ROOT}/tools/packages}
: PACKAGE_ARCH=${PACKAGE_ARCH:=$(uname -m)}
: UNPACK_ROOT=${UNPACK_ROOT:=${BUILD_ROOT}/tools/unpack}

TOOLS=(bash ls ldd)

SCRIPT_DIR=$(dirname $0)

source ${SCRIPT_DIR}/shared_object_lib.sh

function main(){
    set_os_id

    mkdir -p ${MODEL_ROOT}
    mkdir -p ${MODEL_ROOT}/${BINDIR}
    mkdir -p ${RESOLVED_ROOT}
    mkdir -p ${PACKAGE_ROOT}
    mkdir -p ${UNPACK_ROOT}
    
    local tool
    for tool in ${TOOLS[@]} ; do
	local package_name=$(find_file_package ${BINDIR}/${tool})

	download_package ${PACKAGE_ROOT} ${package_name} 
        unpack_package ${PACKAGE_ROOT}/${package_name}*.rpm ${UNPACK_ROOT}
        cp ${UNPACK_ROOT}/${BINDIR}/${tool} ${MODEL_ROOT}/${BINDIR}/${tool} 
    done

    # resolve libraries 
    # find binaries in ${TOOLS_ROOT}

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
    
}

#
#
#
main $*
