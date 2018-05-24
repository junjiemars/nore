#!/bin/bash

[ -d "$TRAVIS_BUILD_DIR" ] && cd "$TRAVIS_BUILD_DIR"

echo "------------"
echo "TRAVIS_BUILD_DIR=$TRAVIS_BUILD_DIR"
echo "./configure where"
echo "`./configure where`"
echo "------------"

CC=
case "$TRAVIS_OS_NAME" in
  osx) CC=clang ;;
  linux) CC=gcc ;;
  *) : ;;
esac

echo_test_what() {
	echo "------------"
	echo "# testing $1 option ..."
	echo "------------"
}


CC=$CC ./configure --new
CC=$CC ./configure
make clean test


echo_test_what "--with-optimize="
CC=$CC ./configure --with-optimize=YES
make clean test


echo_test_what "--with-std=c11"
CC=$CC ./configure --with-std=c11
make clean


echo_test_what "--without-*="
CC=$CC ./configure \
	--without-symbol \
	--without-debug \
	--without-error
make clean test


echo_test_what "--with-warn/verbose="
CC=$CC ./configure \
	--with-warn=NO \
	--with-verbose


echo_test_what "--src/out-dir="
CC=$CC ./configure --src-dir=src --out-dir=build
make clean test
