# Nore

[![build status](https://api.travis-ci.org/junjiemars/nore.svg?branch=master)](https://api.travis-ci.org/junjiemars/nore)

No More than a C build system for [clang](https://clang.llvm.org), [gcc](https://gcc.gnu.org) and [msvc](https://www.visualstudio.com/vs/cplusplus/).


## Getting start

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


[story](story.md) | [wiki](wiki.md)
