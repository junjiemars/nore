#!/bin/bash


# cd $TRAVIS_BUILD_DIR

echo "TRAVIS_BUILD_DIR=$TRAVIS_BUILD_DIR"
echo "./configure where"
echo "`./configure where`"

case "$TRAVIS_OS_NAME" in
  osx)
    ./configure --new
		./configure
    make clean test
  ;;

  linux)
    CC=gcc ./configure --new
		CC=gcc ./configure
    make clean test

    CC=clang ./configure --new
		CC=clang ./configure
    make clean test
  ;;

  *)
    ./configure --new
		./configure
		make clean test
	;;

esac

