#!/bin/bash -ex

OUTPUT=${1}

set -euo pipefail
source optviewer/bin/activate 
mkdir -p ${OUTPUT}

cd thrift; ./bootstrap.sh &&  CXX=clang++-4.0 CC=clang-4.0 CXXFLAGS="-fsave-optimization-record" CFLAGS="-fsave-optimization-record" ./configure && make ; cd -

./llvm/utils/opt-viewer/opt-viewer.py -source-dir thrift/ $(find thrift -name '*.yaml') ${OUTPUT}/thrift/

cd cpython; CC=clang-4.0 CFLAGS="-fsave-optimization-record" ./configure --with-optimizations && make ; cd -
source optviewer/bin/activate ; ./llvm/utils/opt-viewer/opt-viewer.py -source-dir cpython/ $(find cpython -name '*.yaml') ${OUTPUT}/cpython/
