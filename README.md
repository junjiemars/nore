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

Why we need another C build system?

Frequently, I want to know how things works in machine level, so I need to
try something in C on popular platforms, but sadly, there are no handy weapons 
to do that.

I known there are already aswsome tools existing, but the key question is 
how to easy build C code in varied OS by varied Compilers, 
among those things I just pick the most critical ones: __Make__ and __Shell__.


So the story begins ...
* Keep things simple: classic workflow (configure, make and make install).
* Write, Run and Build code on anywhere: Linux, Darwin, Windows or Docker.
* Easy to try some new ideas but have no more unnecessary.


Cooking
======


* [Configuration](#configuration)
  * [On Unix-like Platform](#on-unix-like-platform)
  * [On Windows Platform](#on-windows-platform)
* [Getting Started](#getting-started)
  * [New a Skeleton](#new-a-skeleton)
  * [Configure existing one](#configure-existing-one)
  * [Build and Test](#build-and-test)
  * [Multiple Targets](#multiple-targets)
  * [Multiple Projects](#multiple-projects)
  * [Symbol Table](#symbol-table)
* [Feature Testing](#feature-testing)
  * [Compiler Feature Testing](#compiler-feature-testing)
  * [Compiler Switch Testing](#compiler-switch-testing)
  * [OS Feature Testing](#os-feature-testing)
* [Tips](#tips)
  * [Nore's Commands](#nore's-command)
  * [Troubleshotting](#troubleshotting)
  * [Code Editor](#code-editor)
  * [Debugger](#debugger)


## Configuration

### On Unix-like Platform

There are no installation process just setup __bash__ and __make__ environment. 

The most simplest way to configure is go into your __C__ application directory and run 
```sh
$ bash <(curl https://raw.githubusercontent.com/junjiemars/nore/master/bootstrap.sh)

configure Nore on Linux ...

 + checking make ... found
 + checking nore ... found
 + generating configure ... ok
 + generating ~/.cc-env.sh ... ok

... elpased 0 seconds.
```
then all had done.

### On Windows Platform

On Windows, because there are no __bash__ by default, so we need to install one, [Git Bash](https://git-scm.com/downloads) easy to install and use.
In the installation of _Git Bash_, select _unix compatible tools_ option box. Run ```bash``` in any ```CMD``` or ```Git Bash```, then
```sh
$ bash <(curl https://raw.githubusercontent.com/junjiemars/nore/master/bootstrap.sh)

configure Nore on MINGW64_NT-10.0 ...

 + checking make ... no found
 + checking bash environment ... found
 + installing make ... ok
 + checking nore ... found
 + generating configure ... ok
 + generating ~/.cc-env.sh ... ok

... elpased 9 seconds.

# generate ~/.cc-env.bat for MSVC environment
$ ~/.cc-env.sh
```

If want to use Windows C/C++ toolchains, you need to install [Windows SDK](https://developer.microsoft.com/en-US/windows/downloads/windows-10-sdk) + [C/C++ Build Tools](http://landinghub.visualstudio.com/visual-cpp-build-tools) or install [Visual Studio](https://www.visualstudio.com/).


## Getting Started

```sh
$ ./configure --help
```

On Windows, if use __MSVC__ environment, we need host __MSVC__ environment first
```sh
# switch to Command Prompt
$ cmd

# host MSVC environment
> %userprofile%/.cc-env.bat

# switch back to SHELL
> bash
```

### New a Skeleton

```sh
# generate a new project's skeleton
$ ./configure --new

checking for OS
 + MINGW64_NT-10.0 2.9.0(0.318/5/3) x86_64
checking for C compiler ... found
 + using Microsoft Visual C++ compiler
 + msvc version: 19.13.26129 for x64
checking for WinNT:10.0:x86_64 specific features

creating out/Makefile
 + generating src directory ... ok
 + generating src/version file ... ok
 + generating src/configure file ... ok
 + generating src/Makefile file ... ok

Configuration summary
  platform: WinNT:10.0:x86_64
  compiler: msvc 19.13.26129 for x64
  prefix= D:/opt/run
  out= out
  new= YES
  std= YES:
  symbol= YES: -Z7
  debug= YES
  optimize= NO
  cpu= NO
  error= YES: -WX
  warn= YES: -W4
  verbose= NO
  has= .
```


### Configure existing one

For existing C project at _<existing-c-project-root>_

```sh
$ cd <existing-c-project-root>

$ ./configure --src-dir=<source-directory>

```

### Build and Test

```sh
$ ./configure

$ make

$ make test

```

Following the prompt of __configure__ and __make__, change the _options_ of __configure__ or modify _src/Makefile_.

### Multiple Targets

Suppose project P has A and B two targets, one is a _Executable_, the other is a _Library_

```sh
$ ./configure --has-A --has-B

```

### Multiple Projects

All projects can use only one Nore.

Suppose there are A, B and C projects, those projects use one Nore clone.

```sh
# clone Nore in a directory, annoted as <Nore>

# in A project directory:
$ cd <A>
$ <Nore>/bootstrap.sh

# in B project directory:
$ cd <B>
$ <Nore>/bootstrap.sh

# in C project directory:
$ cd <C>
$ <Nore>/bootstrap.sh

```

### Symbol Table

Nore's builtin exportable symbols can be replaced via _--symbol-table_ option,
which let Nore easy to port to existing C projects.

Example: some tools annote ```DARWIN``` in C source code or make file as ```__DARWIN__``` , but the default in Nore is ```DARWIN```, you can change that to ```__DARWIN__```.

```sh
$ ./configure --symbol-table=<symbol-table-file-name-your-favor>

# if <symbol-table-file-name-your-favor> does not existing, 
# Nore will dump the symbol table into it. Otherwise, Nore will import 
# <symbol-table-file-name-your-favor>

# change the <symbol-table-file-name-your-favor> then
#
$ ./configure --symbol-table=<symbol-table-file-name-your-favor> --has-<A>
$ make clean test

```


## Feature Testing

Write a _bash_ script named _configure_ and put it into _--src-dir_ directory.

### Compiler Feature Testing

```sh
# check features
#----------------------------------------
nm_feature="endian"
nm_feature_name="nm_have_little_endian"
nm_feature_run=value
nm_feature_h="#include <stdio.h>"
nm_feature_flags=
nm_feature_inc=
nm_feature_ldlibs=
nm_feature_test='int i=0x11223344;
                 char *p = (char *)&i;
             	  int le = (0x44 == *p);
                 printf("%d", le);'
. ${NORE_ROOT}/auto/feature

```


### Compiler Switch Testing

```sh
# check features based on Compiler
#----------------------------------------
case $CC_NAME in
	clang)
		;;
	gcc)
		nm_feature="$CC_NAME -Wl,-E|--export-dynamic"
		nm_feature_name=
		nm_feature_run=no
		nm_feature_h=
		nm_feature_flags=-Wl,-E
		nm_feature_inc=
		nm_feature_ldlibs=
		nm_feature_test=
		. ${NORE_ROOT}/auto/feature

		if [ yes = $nm_found ]; then
			flag=LDFLAGS op="+=" value=$nm_feature_flags . ${NORE_ROOT}/auto/make_define
		fi
		;;
	msvc)
		;;
esac
```

### OS Feature Testing

```sh
# check features based on OS
#----------------------------------------
case $NM_SYSTEM in
	Darwin)
		nm_feature="libuv"
		nm_feature_name="nm_have_uv_h"
		nm_feature_run=no
		nm_feature_h="#include <uv.h>"
		nm_feature_flags=-L/opt/local/lib
		nm_feature_inc=-I/opt/local/include
		nm_feature_ldlibs=-luv
		nm_feature_test=
		. ${NORE_ROOT}/auto/feature
	  ;;
	Linux)
	  ;;
	WinNT)
	  ;;
	*)
	  ;;
esac

```

## Tips

### Nore's Commands

* ```where```: Nore will generate some auxiliary files, you can find those files via __where__ command.

```sh
$ ./configure where

```

* ```upgrade```: Upgrade current Nore.

```sh
# in your C application directory
#
$ ./configure upgrade

```

### Troubleshotting

Troubleshotting is more easier than other ones, because all just Makefile and shell scripts. And Nore provides a command for debugging purpose.

```sh
# debug command for debugging Nore's shell script
#
$ ./configure debug

# make debugging options: --just-print --print-data-base --warn-undefined-variables
#
$ make --just-print
```

### Code Editor

* Vim
On any platform, don't warry about C include path. 

* Emacs
On any Unix-like platform.

But on Window,
```shell-command: %userprofile%/.cc-env.bat && e:/app/c/configure --has-x```
```compile: %userprofile%/.cc-env.bat && make -C e:/apps/c/ clean test```

* Visual Stduio Code


### Debugger

* lldb
* gdb
* cdb or wdg


