#!/bin/bash

make clean

case "$TRAVIS_OS_NAME" in
  osx)
    ./configure --has-hi
    make test
  ;;

  linux|*)
    CC=gcc ./configure --has-hi
    make test

    make clean
    CC=clang ./configure --has-hi
    make test
  ;;
esac

