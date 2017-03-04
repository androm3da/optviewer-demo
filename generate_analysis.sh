#!/bin/bash -ex


source optviewer/bin/activate

set -euo pipefail
export OUTPUT=${HOME}/output_analysis/

mkdir -p ${OUTPUT}/cpython
mkdir -p ${OUTPUT}/kfr

# CPython
build_cpython()
{
    cd cpython; CC=clang-4.0 CFLAGS="-O3 -fsave-optimization-record" ./configure --with-optimizations && make ; cd -
}

build_cpython 2>&1 | tee ${OUTPUT}/cpython/build.log
CPY_YAML=$(find cpython -name '*.opt.yaml')
./llvm/utils/opt-viewer/opt-viewer.py -source-dir cpython/ ${CPY_YAML} ${OUTPUT}/cpython/

build_kfr()
{
    mkdir kfr_build
    cd kfr_build
    cmake \
         -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_C_COMPILER=clang-4.0 \
         -DCMAKE_CXX_COMPILER=clang++-4.0 \
         -DCMAKE_C_FLAGS="-O3 -fsave-optimization-record" \
         -DCMAKE_CXX_FLAGS="-O3 -fsave-optimization-record" \
         ../kfr
    make -j4
    cd -
}


build_kfr 2>&1 | tee ${OUTPUT}/kfr/build.log
#KFR_YAML=$(find kfr_build -name '*.opt.yaml')
# FIXME: hack until we get git LFS figured out (index.html
#       is greater than allowed limit)
KFR_YAML=$(find kfr_build -name '*.opt.yaml' | head -4)
./llvm/utils/opt-viewer/opt-viewer.py -source-dir kfr/ ${KFR_YAML} ${OUTPUT}/kfr/
