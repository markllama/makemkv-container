#!/bin/bash

: MODEL_ROOT=${MODEL_ROOT:=model}
: LIBRARY_PATH=${LIBRARY_PATH:=${MODEL_ROOT}/usr/lib:${MODEL_ROOT}/usr/lib64}
: PACKAGE_ROOT=${PACKAGE_ROOT:=rpms}
: PACKAGE_ARCH=${PACKAGE_ARCH:=$(uname -m)}
: UNPACK_ROOT=${UNPACK_ROOT:=unpack}
function main() {

    #dnf install -yes --installroot ${MODEL_ROOT} -- setopt install_weak_deps=false 
    [ -s ${MODEL_ROOT}/bin ] || ln -s usr/bin ${MODEL_ROOT}/bin
    [ -s ${MODEL_ROOT}/lib ] || ln -s usr/lib ${MODEL_ROOT}/lib64
    [ -s ${MODEL_ROOT}/lib64 ] || ln -s usr/lib64 ${MODEL_ROOT}/lib64
    [ -s ${MODEL_ROOT}/usr/lib ] || ln -s lib64 ${MODEL_ROOT}/usr/lib
    
    rm -rf ${PACKAGE_ROOT}/*
    rm -rf ${UNPACK_ROOT}/*

    # Add debugging tools: bash and ldd
    cp /usr/bin/bash ${MODEL_ROOT}/usr/bin/bash
    ln -s bash ${MODEL_ROOT}/usr/bin/sh
    cp /usr/bin/ldd ${MODEL_ROOT}/usr/bin/ldd

    local binaries=$(find_dynamic_binaries ${MODEL_ROOT})

    # Identify the shared libraries that must be resolved for the dynamic binaries
    local libraries=$(find_dynamic_libraries "${LIBRARY_PATH}" ${binaries})
    #echo ${libraries}

    mkdir -p ${PACKAGE_ROOT}
    mkdir -p ${UNPACK_ROOT}
#    [ -s ${UNPACK_ROOT}/lib ] || ln -s usr/lib ${UNPACK_ROOT}/lib 
    [ -s ${UNPACK_ROOT}/lib64 ] || ln -s usr/lib64 ${UNPACK_ROOT}/lib64
 
    # Accumulate the list of packages that provide the required libraries
    declare -a packages
    local library_file
    for library_file in $libraries ; do
	packages+=($(find_file_package $library_file))
    done
    # Remove any duplicates
    packages=($(echo ${packages[@]} | tr ' ' '\n' | sort -u))

    local package_name
    for package_name in ${packages[@]} ; do
	download_package ${PACKAGE_ROOT} ${package_name}
    done

    local rpm_file
    for rpm_file in $(ls ${PACKAGE_ROOT}/*.rpm) ; do
	unpack_package ${rpm_file} ${UNPACK_ROOT}
    done
    
    # Copy the required library files to the model
    for library_file in $libraries ; do
	cp ${UNPACK_ROOT}/${library_file} ${MODEL_ROOT}/${library_file}
    done

    cp ${UNPACK_ROOT}/lib64/ld-linux-* ${MODEL_ROOT}/lib64
    
}

function find_dynamic_binaries() {
    local model_root=$1

    [ -z "${DEBUG}" ] || echo "discovering dynamic binaries in ${model_root}" >&2

    find ${model_root} -type f |
	xargs file | grep executable |
	grep 'dynamically linked' |
	cut -d: -f1
}

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

function find_file_package() {
    local package=$1

    rpm -qf --qf "%{NAME}\n" $package
}

function download_package() {
    local package_dir=$1
    local package_name=$2

    dnf download --quiet --arch ${PACKAGE_ARCH} --destdir ${package_dir} ${package_name}
}

#
# Unpack a package into a working directory
#
function unpack_package() {
    local package_filename=$1
    local unpack_root=$2
    
    rpm2cpio ${package_filename} | cpio -idmu --quiet --directory ${unpack_root}
}

#
#
#
main $*
