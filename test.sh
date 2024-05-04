#!/bin/sh

_ROOT_DIR_="`cd -- $(dirname -- $0) && pwd`"
_CI_DIR_="${_ROOT_DIR_%/}/ci"
_BRANCH_="${_BRANCH_:-edge}"
_OS_NAME_="`uname -s 2>/dev/null`"
_MSVC_ENV_=
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
  ${_ROOT_DIR_%/}/bootstrap.sh --branch=${_BRANCH_}

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
    _MSVC_ENV_="${HOME}/.nore/cc-env.bat"
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
  if [ -z "${_MSVC_ENV_}" ]; then
    ./configure ${_TRACE_} $@
  else
    cat << END > "${msvc_bat}"
@if not "%VSCMD_DEBUG%" GEQ "3" echo off
REM generated by Nore (https://github.com/junjiemars/nore)
call "%1"
sh ./configure ${_TRACE_} $@
END
    if [ ! -f "${msvc_bat}" ]; then
      echo "!panic: generate msvc.bat failed"
      exit 1
    fi
    chmod u+x ${msvc_bat}
    ./${msvc_bat} "${_MSVC_ENV_}"
  fi
}

test_install_from_github () {
  local b="https://raw.githubusercontent.com/junjiemars/nore/master/bootstrap.sh"
  test_what "install from github.com"
  if [ -d "$_CI_DIR_" ]; then
    rm -r "${_CI_DIR_}"
  fi
  mkdir -p "$_CI_DIR_" && cd "$_CI_DIR_"

  curl $b -sSfL | sh -s -- --branch=$_BRANCH_
}

test_make_print_database () {
  test_what "print the make's predefined database"
  make -C "$_CI_DIR_" -p 2>&1 || echo "------------"
}

test_make () {
  local msvc_bat="msvc.bat"
  cd "$_CI_DIR_"
  if [ -z "${_MSVC_ENV_}" ]; then
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
    ./${msvc_bat} "${_MSVC_ENV_}" "make $@"
  fi
}

test_nore_where_command () {
  test_what "./configure where"
  test_configure where
}

test_nore_new_option () {
	test_what "CC=$CC ./configure --new"
  test_configure --new
  test_make clean test
}

test_nore_symbol_option () {
  local c="`basename $_CI_DIR_`.c"

  test_what "CC=$CC ./configure --symbol-table=sym"
  test_configure --symbol-table=sym
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

  cat <<END > "$c"
#include <nore.h>
#include <stdio.h>

#if (MSVC)
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
ci_binout := \$(bin_path)/ci\$(bin_ext)

ci: \$(ci_binout)
ci_test: ci
	\$(ci_binout) 5

\$(ci_binout): \$(ci_root)/ci.c
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
  local c="`basename $_CI_DIR_`.c"
  local m="Makefile"

  cat <<END > "$c"
#include <nore.h>
#include <stdio.h>
#include <assert.h>

int main(void) {
  enum { N = 5 };
  static_assert(N == 5, "N is not equal 5");
  return 0;
}
END

  cat <<END > "$m"
include out/Makefile

ci_root := ./
ci_binout := \$(bin_path)/ci\$(bin_ext)

ci: \$(ci_binout)
ci_test: ci
	\$(ci_binout)

\$(ci_binout): \$(ci_root)/ci.c
	\$(CC) \$(CFLAGS) \$(INC) \$^ \$(bin_out)\$@
END

  test_what "CC=$CC ./configure --with-std=yes"
  test_configure "--with-std=yes"
  test_make clean test

  test_what "CC=$CC ./configure --with-std=-std=c11"
  case "$_OS_NAME_" in
    Darwin)   test_configure "--with-std=-std=c11" ;;
    Linux)    test_configure "--with-std=-std=c11" ;;
    WinNT|*)
      case "$CC" in
        cl)      test_configure "--with-std=-std:c11" ;;
        gcc|*)   test_configure "--with-std=-std=c11" ;;
      esac
  esac
  test_make clean test
}

test_nore_prefix_option () {
  local d="${_CI_DIR_}/xxx"
	test_what "CC=$CC ./configure --prefix=xxx"
  test_configure --new
  test_configure --prefix=xxx
  test_make clean test install
  if [ -d "$d" ]; then
    rm -r "$d"
  fi
}

test_nore_override_option () {
	test_what "CC=$CC ./configure --new"
  test_configure --new --with-optimize=yes --with-optimize=-Os
  test_make clean test
}

test_nore_ld_option () {
  local c="`basename $_CI_DIR_`.c"
  local m="Makefile"

  cat <<END > "$c"
#include <nore.h>
int main(void) {
  return 0;
}
END

  cat <<END > "$m"
include out/Makefile

ci_root := ./
ci_binout := \$(bin_path)/ci\$(bin_ext)
ci_objout := \$(tmp_path)/ci\$(obj_ext)

ci: \$(ci_binout)
ci_test: ci
	\$(ci_binout)

\$(ci_binout): \$(ci_objout)
	\$(LD) \$^ \$(ld_out_opt) \$@ \$(ld_lib_opt)c

\$(ci_objout): \$(ci_root)/ci.c
	\$(CC) \$(CFLAGS) \$(INC) \$^ \$(nm_stage_c) \$(obj_out)\$@
END
  test_what "CC=$CC ./configure #ld"
  test_configure
  test_make clean test
}

test_nore_auto_check () {
  local a="auto"
  sed -e 's/^#//g' "${_ROOT_DIR_}/auto/check" > "${a}"
  test_what "CC=$CC ./configure #auto"
  test_configure
}

# test
if [ -n "$_INSIDE_CI_" ]; then
  test_install_from_github
fi
env_ci_build
test_make_print_database
test_nore_where_command
test_nore_new_option
test_nore_symbol_option
test_nore_optimize_option
test_nore_std_option
test_nore_prefix_option
test_nore_override_option
test_nore_auto_check
test_nore_ld_option

# clean CI directory
[ -d "${_CI_DIR_}" ] && rm -r "${_CI_DIR_}"

echo "#!completed"

# eof
