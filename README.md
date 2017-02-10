
## What is optviewer

opt-viewer can tell you more about missed optimization opportunities.  The
optimizers that `clang` uses can explain the rationale for why their specific
optimization method couldn't be leveraged in given parts of your source.


# Usage

## Prep

Grab a very recent [clang, 4.0 or later](http://releases.llvm.org) for your 
architecture/OS distro.

The example below is for ARM7a linux.

    tar xf clang+llvm-4.0.0-rc1-armv7a-linux-gnueabihf.tar.xz 

This is how you would do it for Ubuntu Trusty:

    wget -nv -O - http://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
    sudo apt-add-repository -y 'deb http://apt.llvm.org/trusty/ llvm-toolchain-trusty-4.0 main'
    sudo apt-get update -qq
    sudo apt-get install -qq -y clang-4.0 llvm-4.0

Next, you must get a copy of opt-viewer.  For now, it's not distributed with 
clang+llvm releases, so a simple way to get it is to just get a copy of the 
llvm project [source from github](https://github.com/llvm-mirror/llvm).  Unpack
or clone it somewhere convenient and note where you put it.

Once you have a new clang installed, build your software with it.  You must 
include "`-fsave-optimization-record`" among the arguments.  Imagine we have
the following sample C/C++ project:

    sample/
    └── src
        ├── bar.cpp
        ├── baz.cpp
        ├── foo.c
        └── Makefile


If you're using `make`, you could add these lines to your `Makefile`:

    CXXFLAGS+=-fsave-optimization-record
    CLAGS+=-fsave-optimization-record

and then clang will build your program or library like so:

    clang-4.0 -fsave-optimization-record -c -o foo.o foo.cpp
    ...

`clang` will create build annotation artifacts in the YAML format.  Now
you can use `opt-viewer` to see these in relation to your project.


## Generating output

You should invoke `opt-viewer` like so:

    llvm/utils/opt-viewer/opt-viewer.py -source-dir sample/src/ \
        sample/src/baz.o.yaml \
        sample/src/bar.o.yaml \
        sample/src/foo.o.yaml \
        output_report/


