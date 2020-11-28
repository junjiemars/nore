#!/bin/sh

_ROOT_DIR_="`cd -- $(dirname -- $0) && pwd`"
_CI_DIR_="${_ROOT_DIR_%/}/ci"
_OS_NAME_="`uname -s 2>/dev/null`"
_WIN_ENV_=
_TRACE_="${_TRACE_}"

case "${_OS_NAME_}" in
  MSYS_NT-*|MINGW??_NT-*) _OS_NAME_="WinNT" ;;
esac

CC="${CC}"
if [ -z "$CC" ]; then
  case "$_OS_NAME_" in
    Darwin)                 CC="clang" ;;
    Linux)                  CC="gcc"   ;;
    WinNT)                  CC="cl"    ;;
  esac
fi

env_ci_build () {
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

  if [ "WinNT" = "${_OS_NAME_}" -a "cl" = "${CC}" ]; then
    if [ ! -f "${HOME}/.nore/cc-env.sh" ]; then
      echo "!panic: ${HOME}/.nore/cc-env.sh no found"
      exit 1
    fi
    ${HOME}/.nore/cc-env.sh 1

    if [ ! -f "${HOME}/.nore/cc-env.bat" ]; then
      echo "!panic: ${HOME}/.nore/cc-env.bat no found"
      exit 1
    fi
    _WIN_ENV_="${HOME}/.nore/cc-env.bat"
  fi
}

test_what () {
  echo "------------"
  echo "# $@ ..."
  echo "------------"
}

test_configure () {
  local msvc_bat="msvc.bat"
  cd "$_CI_DIR_"
  if [ -z "${_WIN_ENV_}" ]; then
    ./configure ${_TRACE_} $@
  else
    cat << END > "${msvc_bat}"
@if not "%VSCMD_DEBUG%" GEQ "3" echo off
REM generated by Nore (https://github.com/junjiemars/nore)
call "%1"
sh "%2"
END
    if [ ! -f "${msvc_bat}" ]; then
      echo "!panic: generate msvc.bat failed"
      exit 1
    fi
    chmod u+x ${msvc_bat}
    ./${msvc_bat} "${_WIN_ENV_}" "./configure ${_TRACE_} $@"
  fi
}

test_make () {
  local msvc_bat="msvc.bat"
  cd "$_CI_DIR_"
  if [ -z "${_WIN_ENV_}" ]; then
    make $@
  else
    cat << END > "${msvc_bat}"
@if not "%VSCMD_DEBUG%" GEQ "3" echo off
REM generated by Nore (https://github.com/junjiemars/nore)
call "%1"
"%2" "%3"
END
    if [ ! -f "${msvc_bat}" ]; then
      echo "!panic: generate msvc.bat failed"
      exit 1
    fi
    chmod u+x ${msvc_bat}
    ./${msvc_bat} "${_WIN_ENV_}" "make $@"
  fi
}

test_nore_new_option () {
	test_what "CC=$CC ./configure --new"
  test_configure --new
  test_make clean test
}

test_nore_symbol_option () {
  local c="`basename $_CI_DIR_`.c"

  test_what "CC=$CC ./configure --symbol-table=sym --new"
  test_configure --symbol-table=sym --new
  test_make clean test

  cat <<END > "$c"
#include <nore.h>
#include <stdio.h>

int main(void) {
#if __DARWIN__
    printf("Hello, Darwin!\n");
#elif __LINUX__
    printf("Hello, Linux!\n");
#elif __WINNT__
    printf("Hello, WinNT!\n");
#else
    printf("!panic, unknown OS\n");
#endif
    return 0;
}
END

  case "$_OS_NAME_" in
    Darwin)
      sed "s/DARWIN:DARWIN/DARWIN:__DARWIN__/g" sym > sym1 2>/dev/null
      ;;
    Linux)
      sed "s/LINUX:LINUX/LINUX:__LINUX__/g" sym > sym1 2>/dev/null
      ;;
    WinNT)
      sed "s/WINNT:WINNT/WINNT:__WINNT__/g" sym > sym1 2>/dev/null
      ;;
  esac

  test_what "CC=$CC ./configure --symbol-table=sym1"
  test_configure --symbol-table=sym1
  test_make clean test
}

test_nore_optimize_option () {
  local c="`basename $_CI_DIR_`.c"
  local m="Makefile"

  test_configure --new

  cat <<END > "$c"
#include <nore.h>
#include <stdio.h>
#if MSVC
#  pragma warning(disable : 4996)
#endif

int
fibonacci(int n, int p, int acc) {
  if (0 == n) {
    return acc;
  }
  return fibonacci(n-1, acc, p+acc);
}

int main(int argc, char **argv) {
  if (argc < 2) {
    return 1;
  }
  int n;
  sscanf(argv[1], "%i", &n);
  int retval = fibonacci(n, 1, 0);
  printf("fibonacci(%i)=%i\n", n, retval);
  return 0;
}
END

  cat <<END > "$m"
include out/Makefile

ci_root := ./
ci_binout := \$(bin_path)ci\$(bin_ext)

ci: \$(ci_binout)
ci_test: ci
	\$(ci_binout) 5

\$(ci_binout): \$(ci_root)ci.c
	\$(CC) \$(CFLAGS) \$(INC) \$^ \$(bin_out)\$@
END

  test_what "CC=$CC ./configure --with-optimize=no"
  test_configure --with-optimize=no
  test_make clean test

  test_what "CC=$CC ./configure --with-optimize=yes"
  test_configure --with-optimize=yes
  test_make clean test
}

test_nore_std_option () {
  local a="auto"
  test_configure --new

  cat <<END > "$a"
echo "checking ISO/IEC 9899:2011 (C11) new header files ..."
#-----------------------------------
include="stdalign.h" . \${NORE_ROOT}/auto/include
include="stdatomic.h" . \${NORE_ROOT}/auto/include
include="stdnoreturn.h" . \${NORE_ROOT}/auto/include
include="threads.h" . \${NORE_ROOT}/auto/include
include="uchar.h" . \${NORE_ROOT}/auto/include

echo "checking C11 new features ..."
#-----------------------------------
nm_feature="alignof"
nm_feature_name="nm_have_alignof"
nm_feature_run=no
nm_feature_h='#include <stdalign.h>'
nm_feature_flags=
nm_feature_test='1 == alignof(char);'
. \${NORE_ROOT}/auto/feature

nm_feature="alignas"
nm_feature_name="nm_have_alignas"
nm_feature_run=no
nm_feature_h='#include <stdalign.h>'
nm_feature_flags=
nm_feature_test='alignas(64) char cache[64];'
. \${NORE_ROOT}/auto/feature

nm_feature="noreturn"
nm_feature_name="nm_have_noreturn"
nm_feature_run=no
nm_feature_h='#include <stdnoreturn.h>
              #include <stdlib.h>
              noreturn void fatal(int x) {
                exit(x);
              }
'
nm_feature_flags=
nm_feature_test='fatal(0);'
. \${NORE_ROOT}/auto/feature

nm_feature="static_assert"
nm_feature_name="nm_have_static_assert"
nm_feature_run=no
nm_feature_h="#include <assert.h>"
nm_feature_flags=
nm_feature_flags=
nm_feature_test="enum {N=5}; static_assert(N==5, \"N is not equal 5\");"
. \${NORE_ROOT}/auto/feature

nm_feature="atomic"
nm_feature_name="nm_have_atomic"
nm_feature_run=no
nm_feature_h='#include <stdatomic.h>
_Atomic struct A {
  int x;
} a;'
nm_feature_flags=
nm_feature_test='atomic_is_lock_free(&a);'
. \${NORE_ROOT}/auto/feature

END

  test_what "CC=$CC ./configure --with-std=c11"
  case "$_OS_NAME_" in
    Darwin) test_configure "--with-std=c11"   ;;
    Linux)  test_configure "--with-std=c11"   ;;
    WinNT|*)  test_configure "--with-std=yes" ;;
  esac
}

# test
env_ci_build
test_nore_new_option
test_nore_symbol_option
test_nore_optimize_option
test_nore_std_option

# clean CI directory
[ -d "${_CI_DIR_}" ] && rm -r "${_CI_DIR_}"


# eof
