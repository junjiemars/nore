#!env bash

NORE_ROOT_DIR="`cd $(dirname ${BASH_SOURCE[0]}); pwd`"
NORE_CI_DIR="${NORE_ROOT_DIR%/}/ci"
NORE_OS_NAME="`uname -s 2>/dev/null`"

case "${NORE_OS_NAME}" in
  MSYS_NT-*|MINGW??_NT-*) NORE_OS_NAME="WinNT" ;;
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
  if [ -d "$NORE_CI_DIR" ]; then
		rm -r "${NORE_CI_DIR}"
	fi
	mkdir -p "$NORE_CI_DIR"

  cd "${NORE_CI_DIR}"
  echo "------------"
  echo "CC=$CC"
  echo "NORE_CI_DIR=$NORE_CI_DIR"
  echo "------------"
  echo "`../bootstrap.sh`"
}

echo_ci_what() {
	echo "------------"
	echo "# $@ ..."
	echo "------------"
}

test_nore_new_option() {
  make_ci_env
	cd "$NORE_CI_DIR"

	echo_ci_what "CC=$CC ./configure --new"
	./configure --new
	make clean test
}

test_nore_optimize_option() {
  make_ci_env
	cd "$NORE_CI_DIR"

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
[ -d "${NORE_CI_DIR}" ] && rm -r "${NORE_CI_DIR}"


# eof
