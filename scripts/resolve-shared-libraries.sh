#!/bin/bash

: MODEL_ROOT=${MODEL_ROOT:=model}
: LIBRARY_PATH=${LIBRARY_PATH:=${MODEL_ROOT}/usr/lib:${MODEL_ROOT}/usr/lib64}

function main() {
    local binaries=$(find_dynamic_binaries ${MODEL_ROOT})
    local binary

#    echo "====== BINARIES ======"
#    echo ${binaries}
#    echo "======================"

    local libraries=$(find_dynamic_libraries "${LIBRARY_PATH}" ${binaries})
    #echo ${libraries}

    local lib
    declare -a packages
    for lib_file in $libraries ; do
	packages+=($(find_file_package $lib_file))
    done

    echo "${packages[@]}"
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

#
#
#
main $*
