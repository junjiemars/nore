#!/usr/bin/env bash

_ROOT_DIR_="`cd $(dirname ${BASH_SOURCE[0]}); pwd`"
_CI_DIR_="${_ROOT_DIR_%/}/ci"
_OS_NAME_="`uname -s 2>/dev/null`"

case "${_OS_NAME_}" in
  MSYS_NT-*|MINGW??_NT-*) _OS_NAME_="WinNT" ;;
esac

CC="${CC}"
if [ -z "$CC" ]; then
  case `uname -s 2>/dev/null` in
    Darwin)                 CC="clang" ;;
    Linux)                  CC="gcc"   ;;
    WinNT)                  CC="msvc"  ;;
  esac
fi

make_ci_env() {
  if [ -d "$_CI_DIR_" ]; then
		rm -r "${_CI_DIR_}"
	fi
	mkdir -p "$_CI_DIR_"

  echo "------------"
  echo "CC=$CC"
  echo "_ROOT_DIR_=$_ROOT_DIR_"
  echo "_CI_DIR_=$_CI_DIR_"
  echo "------------"
  if [ ! -f "${_ROOT_DIR_%/}/bootstrap.sh" ]; then
    echo "!panic: ${_ROOT_DIR_%/}/bootstrap.sh no found"
    exit 1
  fi
  cd "${_CI_DIR_}"
  ${_ROOT_DIR_%/}/bootstrap.sh
  if [ "WinNT" = "${_OS_NAME_}" ]; then
    if [ ! -f "~/.nore/cc-env.sh" ]; then
      echo "!panic: ~/.nore/cc-env.sh no found"
      exit 1
    fi
    ~/.nore/cc-env.sh
  fi
}

echo_ci_what() {
	echo "------------"
	echo "# $@ ..."
	echo "------------"
}

test_nore_new_option() {
  make_ci_env
	cd "$_CI_DIR_"

	echo_ci_what "CC=$CC ./configure --new"
	./configure --new
	make clean test
}

test_nore_optimize_option() {
  make_ci_env
	cd "$_CI_DIR_"

  echo_ci_what "CC=$CC ./configure --new"
  ./configure --new

	echo_ci_what "CC=$CC ./configure --with-optimize=no"
  ./configure --with-optimize=no
	make clean test

	echo_ci_what "CC=$CC ./configure --with-optimize=yes"
  ./configure --with-optimize=yes
	make clean test

  echo_ci_what "CC=$CC ./configure --with-optimize="
  ./configure --with-optimize=no
	make clean test
}

test_nore_new_option
test_nore_optimize_option

# clean CI directory
[ -d "${_CI_DIR_}" ] && rm -r "${_CI_DIR_}"


# eof
