#!/bin/bash

MAKEMKV_VERSION=1.18.4

MODEL_ROOT=$(pwd)/model
MODEL_BINDIR=${MODEL_ROOT}/usr/bin
MODEL_LIBDIR=${MODEL_ROOT}/usr/lib64
MODEL_SHAREDIR=${MODEL_ROOT}/usr/share/MakeMKV



LD_LIBRARY_PATH=${MODEL_LIBDIR}

function main() {
    echo Starting

    delete_model_tree
    create_model_tree
    
    copy_binaries
    copy_libraries
    copy_shared

    echo Ending
}

function delete_model_tree() {
    rm -rf ${MODEL_ROOT}
}

function create_model_tree() {
    mkdir -p ${MODEL_BINDIR}
    mkdir -p ${MODEL_LIBDIR}
    mkdir -p ${MODEL_SHAREDIR}
}

function copy_binaries() {
    echo Copying Binaries
    
}

function copy_libraries() {
    echo Copying Libraries
}

function copy_shared() {
    echo Copying Shared Files
}

#
#
#
main $*
