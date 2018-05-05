# Nore

[![build status](https://api.travis-ci.org/junjiemars/nore.svg?branch=master)](https://api.travis-ci.org/junjiemars/nore)

No More than a C build system for [clang](https://clang.llvm.org), [gcc](https://gcc.gnu.org) and [msvc](https://www.visualstudio.com/vs/cplusplus/).


Let's start ... 

```sh
# make a new directory for your C application
# 
$ make your-c-app-dir
$ cd your-c-app-dir

# run bootstrap from github, it will generate a configure file in current directory
#
$ bash <(curl https://raw.githubusercontent.com/junjiemars/nore/master/bootstrap.sh)

# generate a C application skeleton
#
$ ./configure --new

$ ./configure

$ make test
```

Story
=======

Q: Why we need another C build system?

A: Frequently, I want to know how things works in machine level, so I need to
try something in C on popular platforms, but sadly, there are no handy weapons 
to do that.

I known there are already aswsome tools existing, but the key question is 
how to easy build C code in varied OS by varied Compilers, 
among those things I just pick the most critical ones: __Make__ and __Shell__.


So the story begins ...
* Keep things simple: classic workflow (configure, make and make install).
* Write, Run and Build code on anywhere: Linux, Darwin, Windows or Docker.
* Easy to try some new ideas but have no more unnecessary.



Use ```./configure --help``` to show help message.

## How to debug
```sh
$ ./configure debug
```

## How to upgrade 

```sh
# in your C apps dir
$ ./configure upgrade
```


[wiki](wiki.md)
