#!/bin/bash

[ -d "$TRAVIS_BUILD_DIR" ] && cd "$TRAVIS_BUILD_DIR"

echo "============"
echo "TRAVIS_BUILD_DIR=$TRAVIS_BUILD_DIR"
echo "./configure where"
echo "`./configure where`"
echo "============"

CC=
case "$TRAVIS_OS_NAME" in
  osx) CC=clang ;;
  linux) CC=gcc ;;
  *) : ;;
esac

# basic testing
CC=$CC ./configure --new
CC=$CC ./configure
make clean test

# --with-optimize testing
echo "============"
CC=$CC ./configure --with-optimize=YES
make clean test

# --with-std=c11 testing
echo "============"
CC=$CC ./configure --with-std=c11
make clean

# --without-* testing
echo "============"
CC=$CC ./configure \
	--without-symbol \
	--without-debug \
	--without-error \
	--without-warn \
	--with-verbose
make clean test

# --src-dir --out-dir testing
echo "============"
CC=$CC ./configure --src-dir=src --out-dir=build
make clean test
