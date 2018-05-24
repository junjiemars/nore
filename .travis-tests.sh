#!/bin/bash

cd "$NORE_TEST_DIR"
[ -f "Makefile" ] && make clean
echo "`./configure where`"

case "$TRAVIS_OS_NAME" in
  osx)
    ./configure --new
		./configure
    make clean test
  ;;

  linux|*)
    CC=gcc ./configure --new
		CC=gcc ./configure
    make clean test

    CC=clang ./configure --new
		CC=clang ./configure
    make clean test
  ;;
esac

