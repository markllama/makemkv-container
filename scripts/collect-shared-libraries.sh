#!/bin/bash

: MODEL_ROOT=${MODEL_ROOT:=$(pwd)/build/model}
: MODEL_BIN=${MODEL_BIN:=${MODEL_ROOT}/usr/bin}
: MODEL_LIB=${MODEL_LIB:=${MODEL_ROOT}/usr/lib}
: LD_LIBRARY_PATH=${LD_LIBRARY_PATH:=${MODEL_ROOT}/usr/lib:${MODEL_ROOT}/usr/lib64}

function main() {
    local executable
    for executable in $(find ${MODEL_BIN} -type f) ; do
	echo Checking ${executable}
	local liblist=$(shared_libraries ${executable} ${LD_LIBRARY_PATH})
	#echo "${liblist}"
	for shared_object in ${liblist} ; do
	    cp $shared_object ${MODEL_LIB}
	done
    done
}

function shared_libraries() {
    local executable=$1
    local library_path=$2

    # List the shared libraries that link to the executable
    # Ignore libraries that don't have a matching file path
    # Ignore libraries under the current working directory
    # Sort and remove duplicates
    LD_LIBRARY_PATH=${library_path} ldd ${executable} |
	grep '=>' |
	awk '{print $3}' |
	sort -u |
	grep -v $(pwd)
}

#
#
#
main $*
