#!/bin/bash

cd "$NORE_TEST_DIR"
[ -f "Makefile" ] && make clean

case "$TRAVIS_OS_NAME" in
  osx)
    ./configure --has-hi
    make test
  ;;

  linux|*)
    CC=gcc ./configure --has-hi
    make test

    [ -f "Makefile" ] && make clean

    CC=clang ./configure --has-hi
    make test
  ;;
esac

