#!/bin/bash -ex


source optviewer/bin/activate

set -euo pipefail
export OUTPUT=${HOME}/output_analysis/
mkdir -p ${OUTPUT}/thrift
mkdir -p ${OUTPUT}/cpython

# Thrift
build_thrift()
{
    cd thrift
    ./bootstrap.sh 
    CXX=clang++-4.0 CC=clang-4.0 CXXFLAGS="-fsave-optimization-record" CFLAGS="-fsave-optimization-record" ./configure 
    make 
    cd -
}

build_thrift 2>&1 | tee ${OUTPUT}/thrift/build.log
THRIFT_YAML=$(find thrift -name '*.opt.yaml')
# TODO: actually there's multiple source dirs... :(
./llvm/utils/opt-viewer/opt-viewer.py -source-dir thrift/ ${THRIFT_YAML} ${OUTPUT}/thrift/

# CPython
build_cpython()
{
    cd cpython; CC=clang-4.0 CFLAGS="-fsave-optimization-record" ./configure --with-optimizations && make ; cd -
}

build_cpython 2>&1 | tee ${OUTPUT}/cpython/build.log
CPY_YAML=$(find cpython -name '*.opt.yaml')
./llvm/utils/opt-viewer/opt-viewer.py -source-dir cpython/ ${CPY_YAML} ${OUTPUT}/cpython/
