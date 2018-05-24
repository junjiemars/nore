#!/bin/bash

[ -d "$TRAVIS_BUILD_DIR" ] && cd "$TRAVIS_BUILD_DIR"

echo "============"
echo "TRAVIS_BUILD_DIR=$TRAVIS_BUILD_DIR"
echo "./configure where"
echo "`./configure where`"
echo "============"

CC=
case "$TRAVIS_OS_NAME" in
  osx)
    CC=clang
  ;;

  linux)
    CC=gcc
  ;;

  *)
		:
	;;
esac

CC=$CC ./configure --new
CC=$CC ./configure
make clean test

