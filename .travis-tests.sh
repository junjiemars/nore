#!/bin/bash

cd "$NORE_TEST_DIR"
[ -f "Makefile" ] && make clean

case "$TRAVIS_OS_NAME" in
  osx)
    ./configure --new
		./configure
    make test
  ;;

  linux|*)
    CC=gcc ./configure --new
		CC=gcc ./configure
    make test

    [ -f "Makefile" ] && make clean

    CC=clang ./configure --new
		CC=clang ./configure
    make test
  ;;
esac

