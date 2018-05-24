#!/bin/bash

# cd $TRAVIS_BUILD_DIR

echo "TRAVIS_BUILD_DIR=$TRAVIS_BUILD_DIR"
echo "`./configure where`"
echo "`cat ./configure`"
echo "`cat ./Makefile`"
echo "`cat out/Makefile`"

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

