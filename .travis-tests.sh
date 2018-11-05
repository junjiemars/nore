#!/bin/bash

if [ "true" != "$TRAVIS" ]; then
	TRAVIS_BUILD_DIR="`cd $(dirname ${BASH_SOURCE[0]}); pwd`"
fi

using_cc() {
	if [ -z "$1" ]; then
		case "$TRAVIS_OS_NAME" in
			osx)     CC=clang ;;
			linux)   CC=gcc   ;;
			*)       :        ;;
		esac
	elif `command -v $1`; then
		CC="$1"
	fi
}


make_ci_env() {
  nore_ci_dir="${TRAVIS_BUILD_DIR%/}/ci"
  if [ -d "$nore_ci_dir" ]; then
		rm -r "${nore_ci_dir}"
	fi
	mkdir -p "$nore_ci_dir"
	cd "$nore_ci_dir"

  echo "------------"
  echo "TRAVIS_BUILD_DIR=$TRAVIS_BUILD_DIR"
  echo "------------"
  echo "${TRAVIS_BUILD_DIR%/}/bootstrap.sh"
  echo "`${TRAVIS_BUILD_DIR%/}/bootstrap.sh`"
  echo "------------"
  echo "${nore_ci_dir}/configure where"
  echo "`${nore_ci_dir}/configure where`"

	using_cc
}

echo_ci_what() {
	echo "------------"
	echo "# CI: $1 option ..."
	echo "------------"
}


ci_nore_options() {
	make_ci_env
	cd "$nore_ci_dir"

	echo_ci_what "--new"
	CC=$CC ./configure --new
	make clean test

	echo_ci_what "--with-optimize="
	CC=$CC ./configure --with-optimize=YES
	make clean test

	echo_ci_what "--with-std=c11"
	CC=$CC ./configure --with-std=c11
	make clean test

	echo_ci_what "--without-symbol,--without-debug,--without-error"
	CC=$CC ./configure \
		--without-symbol \
		--without-debug \
		--without-error
	make clean test

	echo_ci_what "--with-warn=,--with-verbose"
	CC=$CC ./configure \
		--with-warn=NO \
		--with-verbose
	make clean test

	make_ci_env
	cd "$nore_ci_dir"

	echo_ci_what "--src-dir,--out-dir="
	CC=$CC ./configure --src-dir=src --out-dir=out --new
	make clean test
}


ci_nore_options

[ -d "${nore_ci_dir}" ] && rm -r "${nore_ci_dir}"
