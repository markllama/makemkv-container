#!/bin/bash
#
# 
#

# /usr/
#   bin/
#   lib64/
#     libdriveio.so.0
#     libmakemkv.so.1
#     libmmbd.so.0
#   share/
#     MakeMKV/
#       appdata.tar
#       blues.jar
#       blues.policy

MODEL_ROOT=${PWD}/model
MODEL_DIRS=(usr/lib64 usr/bin usr/share/MakeMKV)
SHARED_LIBRARIES=(libdriveio.so.0 libmakemkv.so.1 libmmbd.so.0)

function main() {
    create_model
}

function create_model() {
    echo Creating Models
    create_directories
    place_libraries
    place_binaries
    place_shared_files
}

function create_directories() {
    echo Creating Directories
    local new_dir
    for new_dir in ${MODEL_DIRS[@]} ; do
	mkdir -p ${MODEL_ROOT}/${new_dir}
    done
}

function place_libraries() {
    echo Placing Libraries
}

function place_binaries() {
    echo Placing Binaries
}

function place_shared_files() {
    echo Placing Shared Files
}

main $*
# usr
# /usr/bin/install -c -D -m 644 out/libdriveio.so.0 /usr/lib64/libdriveio.so.0
# /usr/bin/install -c -D -m 644 out/libmakemkv.so.1 /usr/lib64/libmakemkv.so.1
# /usr/bin/install -c -D -m 644 out/libmmbd.so.0 /usr/lib64/libmmbd.so.0
# ldconfig
# /usr/bin/install -c -D -m 755 out/mmccextr /usr/bin/mmccextr
# /usr/bin/install -c -D -m 755 out/mmgplsrv /usr/bin/mmgplsrv

# rm -f /usr/bin/makemkvcon
# rm -f /usr/bin/mmdtsdec
# rm -f /usr/share/MakeMKV/*
# /usr/bin/install -d /usr/share/MakeMKV
# /usr/bin/install -d /usr/bin
# /usr/bin/install -t /usr/bin bin/amd64/makemkvcon
# /usr/bin/install -m 644 -t /usr/share/MakeMKV src/share/appdata.tar
# /usr/bin/install -m 644 -t /usr/share/MakeMKV src/share/blues.jar
# /usr/bin/install -m 644 -t /usr/share/MakeMKV src/share/blues.policy
# ln -s -f makemkvcon /usr/bin/sdftool
