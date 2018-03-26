# Wiki

No More than a C build system for clang, gcc and msvc.


* [Configuration](#configuration)
  * [On Unix-like Platform](#on-unix-like-platform)
  * [On Windows Platform](#on-windows-platform)
* [Getting start](#getting-start)
  * [New a Skeleton](#new-a-skeleton)
  * [Configure existing one](#configure-existing-one)
  * [Build and Test](#build-and-test)
* [Feature Testing](#feature-testing)
  * [Compiler Feature Testing](#compiler-feature-testing)
  * [Compiler Switch Testing](#compiler-switch-testing)
  * [OS Feature Testing](#os-feature-testing)
  

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


## Getting start

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

Add a _c.c_ source file into _src/_.


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
```

Following the prompt of __configure__ and __make__, change the _options_ of __configure__ or modify _src/Makefile_.

## Feature Testing

Write a _bash_ script named _configure_ and put it into _--src-dir_ directory.

### Compiler Feature Testing

```sh
# check features
#----------------------------------------
#nm_feature="endian"
#nm_feature_name="nm_have_little_endian"
#nm_feature_run=value
#nm_feature_h="#include <stdio.h>"
#nm_feature_flags=
#nm_feature_inc=
#nm_feature_ldlibs=
#nm_feature_test='int i=0x11223344;
#                 char *p = (char *)&i;
#             	  int le = (0x44 == *p);
#                 printf("%d", le);'
#. ${NORE_ROOT}/auto/feature

```


### Compiler Switch Testing

```sh
# check features based on Compiler
#----------------------------------------
#case $CC_NAME in
#	clang)
#		;;
#	gcc)
#		nm_feature="$CC_NAME -Wl,-E|--export-dynamic"
#		nm_feature_name=
#		nm_feature_run=no
#		nm_feature_h=
#		nm_feature_flags=-Wl,-E
#		nm_feature_inc=
#		nm_feature_ldlibs=
#		nm_feature_test=
#		. ${NORE_ROOT}/auto/feature
#
#		if [ yes = $nm_found ]; then
#			flag=LDFLAGS op="+=" value=$nm_feature_flags . ${NORE_ROOT}/auto/make_define
#		fi
#		;;
#	msvc)
#		;;
#esac
```

### OS Feature Testing

```sh
# check features based on OS
#----------------------------------------
#case $NM_SYSTEM in
#	Darwin)
#		nm_feature="libuv"
#		nm_feature_name="nm_have_uv_h"
#		nm_feature_run=no
#		nm_feature_h="#include <uv.h>"
#		nm_feature_flags=-L/opt/local/lib
#		nm_feature_inc=-I/opt/local/include
#		nm_feature_ldlibs=-luv
#		nm_feature_test=
#		. ${NORE_ROOT}/auto/feature
#	  ;;
#	Linux)
#	  ;;
#	WinNT)
#	  ;;
#	*)
#	  ;;
#esac

```
