
## What is opt-viewer?

opt-viewer can tell you more about missed optimization opportunities.  The
optimizers that `clang` uses can explain the rationale for why their specific
optimization method couldn't be leveraged in given parts of your source.

![Build status](https://travis-ci.org/androm3da/optviewer-demo.svg?branch=master)

## Output Examples
* [CPython](https://androm3da.github.io/optviewer-demo/output_analysis/cpython/)
* [KFR](https://androm3da.github.io/optviewer-demo/output_analysis/kfr/) DSP lib ([repo](https://github.com/kfrlib/kfr/), [website](https://www.kfrlib.com/))

# Usage

## Prep

Grab a very recent [clang, 4.0 or later](http://releases.llvm.org) for your 
architecture/OS distro and install or unpack it on your machine.

The example below is for ARM7a linux, there are several other releases available.

    curl -O http://releases.llvm.org/4.0.0/clang+llvm-4.0.0-armv7a-linux-gnueabihf.tar.xz
    tar xf clang+llvm-4.0.0-rc1-armv7a-linux-gnueabihf.tar.xz 

Or instead you might have Ubuntu.  Below is how you would do it for Ubuntu 
Trusty.  If you're not sure which Ubuntu release you have, see ["Checking Your
Ubuntu Version"](https://help.ubuntu.com/community/CheckingYourUbuntuVersion).

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

First, gather the necessary dependencies for opt-viewer:

    virtualenv optviewer_env
    source optviewer_env/bin/activate
    pip install pyyaml pygments

Let's assume your `sample` project is in the same directory as
the one where you unpacked/cloned `llvm`.  Then you should invoke `opt-viewer`
like so:

    llvm/utils/opt-viewer/opt-viewer.py -source-dir sample/src/ \
        sample/src/baz.opt.yaml \
        sample/src/bar.opt.yaml \
        sample/src/foo.opt.yaml \
        ./output_report/

In the `output_report` dir, we'll have some output files that could look like 
below:

![opt-viewer screenshot](https://github.com/androm3da/optviewer-demo/raw/master/img/opt_viewer_sample.png)

## Advanced usage: PGO

If you are able to leverage profile-guided-optimization (PGO), opt-viewer will
produce an index that's sorted by the most-frequently executed code 
("hotness").  This makes it easy to see which functions and methods would 
benefit the most from improved optimization.

For more info on PGO, see [the `clang` manual on 
PGO](https://clang.llvm.org/docs/UsersManual.html#profile-guided-optimization).


## Appendix

* `opt-viewer` was introduced in "Compiler-assisted Performance Analysis", 2016 Bay Area LLVM Developer's Meeting ([slides](http://llvm.org/devmtg/2016-11/Slides/Nemet-Compiler-assistedPerformanceAnalysis.pdf), [video](https://youtu.be/qq0q1hfzidg))
