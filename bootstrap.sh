#!/bin/sh
#------------------------------------------------
# target: bootstrap script of Nore
# url: https://github.com/junjiemars/nore.git
# author: Junjie Mars
#------------------------------------------------

check_echo_opt () {
  # check the echo's "-n" option and "\c" capability
  if echo "test\c" | grep -q c; then
    echo_c=
    if echo -n test | tr '\n' _ | grep -q _; then
      echo_n=
    else
      echo_n=-n
    fi
  else
    echo_n=
    echo_c='\c'
  fi
}
check_echo_opt

bootstrap_path () {
  local p="`dirname $0`"
  local n="${PWD}/.nore"

  if [ -d "${p}" ]; then
    p="`( cd \"${p}\" && pwd )`"
    if [ -z "$p" -o "/dev/fd" = "$p" ]; then
      echo "$n"
    elif [ ! -f "${p}/auto/configure" ]; then
      echo "${p}/.nore"
    else
      echo "$p"
    fi
  else
    echo "$n"
  fi
}

ROOT="${ROOT:-`bootstrap_path`}"
NORE_WORK="$PWD"

PLATFORM="`uname -s 2>/dev/null`"
GITHUB_R="${GITHUB_R:-https://raw.githubusercontent.com/junjiemars}"
GITHUB_H="${GITHUB_H:-https://github.com/junjiemars}"

NORE_UPGRADE=no
NORE_BRANCH=master

for option
do
  case "$option" in
    -*=*) value=`echo "$option" | sed -e 's/[-_a-zA-Z0-9]*=//'` ;;
    *) value="" ;;
  esac

  case "$option" in
    --help)                  help=yes                   ;;
    --branch=*)              NORE_BRANCH="$value"       ;;
    --work=*)                NORE_WORK="$value"         ;;

    *)
      command="`echo $option | tr '[:upper:]' '[:lower:]'`"
      ;;
  esac
done

case ".$command" in
  .u|.upgrade)
    NORE_UPGRADE=yes
    ;;
esac

on_windows_nt () {
  case "$PLATFORM" in
    MSYS_NT*|MINGW*) return 0 ;;
    *) return 1 ;;
  esac
}

on_darwin () {
  case "$PLATFORM" in
    Darwin) return 0 ;;
    *) return 1 ;;
  esac
}

on_linux () {
  case "$PLATFORM" in
    Linux) return 0 ;;
    *) return 1 ;;
  esac
}

check_nore () {
  if `git -C "${ROOT}" remote -v 2>/dev/null | grep -q 'junjiemars/nore'`; then
    if [ "`check_nore_branch`" != "${NORE_BRANCH}" -a "${ROOT}" != "${PWD}/.nore" ]; then
      ROOT="${PWD}/.nore"
      test -d "${ROOT}" && rm -rf "${ROOT}"
      return 1
    else
      # ignore unmatched branch
      return 0
    fi
  else
    return 1
  fi
}

check_nore_branch () {
  git -C "${ROOT}" rev-parse --abbrev-ref HEAD
}

upgrade_nore () {
  local b="`check_nore_branch`"
  [ -n "${b}" ] || return 1

  git -C "${ROOT}" reset --hard 1>/dev/null 2>&1 || return $?

  [ ${NORE_BRANCH} = ${b} ] || return $?
  git -C "${ROOT}" pull --rebase origin ${b} 1>/dev/null 2>&1
}

clone_nore () {
  git clone --depth=1 --branch=${NORE_BRANCH} ${GITHUB_H}/nore.git "${ROOT}" 1>/dev/null 2>&1
}


cat_configure () {
  local b="`check_nore_branch`"
  local conf="${NORE_WORK%/}/configure"
  local new_conf="${conf}.n"

  cat << END > "$new_conf"
#!/bin/sh
#------------------------------------------------
# target: configure
# author: Junjie Mars
# generated by Nore (${GITHUB_H}/nore)
#------------------------------------------------

check_echo_opt () {
  # check the echo's "-n" option and "\c" capability
  if echo "test\c" | grep -q c; then
    echo_c=
    if echo -n test | tr '\n' _ | grep -q _; then
      echo_n=
    else
      echo_n=-n
    fi
  else
    echo_n=
    echo_c='\c'
  fi
}
check_echo_opt

NORE_ROOT="${ROOT%/}"
NORE_BRANCH="${b}"
NORE_L_BOOT="\${NORE_ROOT}/bootstrap.sh"
NORE_R_BOOT="${GITHUB_R}/nore/\${NORE_BRANCH}/bootstrap.sh"
NORE_L_CONF="\${NORE_ROOT}/auto/configure"
NORE_L_CONF_OPTS=
NORE_L_CONF_TRACE="no"
NORE_L_CONF_COMMAND=


for option
do
  case "\$option" in
    -*=*)
      NORE_L_CONF_OPTS="\${NORE_L_CONF_OPTS:+\$NORE_L_CONF_OPTS }\$option"
      ;;

    -*)
      NORE_L_CONF_OPTS="\${NORE_L_CONF_OPTS:+\$NORE_L_CONF_OPTS }\$option"
      ;;

    *)
       NORE_L_CONF_COMMAND="\$option"
       ;;
  esac
done

case "\`echo \${NORE_L_CONF_COMMAND} | tr '[:upper:]' '[:lower:]'\`" in
  upgrade)
    if [ -f \${NORE_L_BOOT} ]; then
      \$NORE_L_BOOT --branch=\${NORE_BRANCH} upgrade
    else
      curl -sqL \${NORE_R_BOOT} \\
        | ROOT=\${NORE_ROOT} sh -s -- \\
        --branch=\${NORE_BRANCH} upgrade
    fi
    exit \$?
    ;;

  clone)
    if [ -f \${NORE_L_BOOT} ]; then
      \$NORE_L_BOOT --branch=\${NORE_BRANCH} --work=\$PWD
    else
      curl -sqL \${NORE_R_BOOT} \\
        | ROOT=\${NORE_ROOT} sh -s -- \\
        --branch=\${NORE_BRANCH} \\
        --work=\$PWD
    fi
    exit \$?
    ;;

  where)
    echo "NORE_ROOT=\${NORE_ROOT}"
    echo "NORE_BRANCH=\${NORE_BRANCH}"
    echo "configure=@\$0"
    echo "make=@\$(command -v make)"
`if on_darwin; then
    echo "    echo \\"shell=@\\\$(ps -p\\\$\\\$ -ocommand | tr ' ' '\\\\\n' | sed -n 2p)\\""
elif $(command -v readlink \&>/dev/null); then
    echo "    echo \\"shell=@\\\$(readlink /proc/\\\$\\\$/exe)\\""
else
    echo "    echo \\"shell=@\\\$(ls -l /proc/\\\$\\\$/exe | sed 's#.*->[ ]*\(.*\)#\\\1#g')\\""
fi`

    echo \$echo_n "cc-env.sh=@\$echo_c"
    if [ -f "\${HOME%/}/.nore/cc-env.sh" ]; then
      echo "\${HOME%/}/.nore/cc-env.sh"
    else
      echo ""
    fi
`if on_windows_nt; then
  echo "echo \\\$echo_n \\"cc-env.bat=@\\\$echo_c\\""
  echo "    if [ -f \"\\\${HOME%/}/.nore/cc-env.bat\\" ]; then"
  echo "      echo \"\\\${HOME%/}/.nore/cc-env.bat\\""
  echo "    else"
  echo "      echo \\"\\""
  echo "    fi"
fi`
    echo \$echo_n "cc-inc.lst=@\$echo_c"
    if [ -f "\${HOME%/}/.nore/cc-inc.lst" ]; then
      echo "\${HOME%/}/.nore/cc-inc.lst"
    else
      echo ""
    fi
    echo \$echo_n "cc-inc.vimrc=@\$echo_c"
    if [ -f "\${HOME%/}/.nore/cc-inc.vimrc" ]; then
      echo "\${HOME%/}/.nore/cc-inc.vimrc"
    else
      echo ""
    fi
    exit \$?
    ;;

  trace)
    NORE_L_CONF_TRACE="yes"
    ;;
esac


cd "\$(CDPATH= cd -- \$(dirname -- \$0) && echo \$PWD)"

if [ -f \${NORE_L_CONF} ]; then
  case "\${NORE_L_CONF_TRACE}" in
    no)
      \$NORE_L_CONF "\$@"
      ;;

    yes)
      sh -x \$NORE_L_CONF \${NORE_L_CONF_OPTS}
      ;;
  esac
else
  echo
  echo "!nore << no found, to fix >: configure clone"
  echo
fi

# eof

END

  chmod u+x "$new_conf"
  mv "$new_conf" "$conf"
}


cat_cc_env () {
  local cc_env_sh="${1:-${HOME%/}/.nore/cc-env.sh}"
  local env_dir="`dirname $cc_env_sh`"
  [ -d "$env_dir" ] || mkdir -p "$env_dir"

  cat << END > "$cc_env_sh"
#!/bin/sh
#------------------------------------------------
# target: .cc-env.sh
# author: Junjie Mars
# generated by Nore (${GITHUB_H}/nore)
#------------------------------------------------

CC_ENV_GEN="\$1"
`
if on_windows_nt; then
  echo "CC_ENV_BAT=\\"\\\${HOME%/}/.nore/cc-env.bat\\""
fi
`
CC_INC_LST="\${HOME%/}/.nore/cc-inc.lst"
CC_INC_VIMRC="\${HOME%/}/.nore/cc-inc.vimrc"
VIMRC="\${HOME%/}/.vimrc"


delete_vimrc_src () {
  local h="\$1"
  local lines="\$2"
  local f="\$3"
`if on_darwin; then
   echo "  local sed_opt_i=\\"-i .pre\\""
 else
   echo "  local sed_opt_i=\\"-i.pre\\""
 fi
`

  [ -f "\$f" ] || return 0

  local line_no=\`grep -m1 -n "^\${h}" \$f | cut -d':' -f1\`
  case \$line_no in
	  [0-9]*)
			if [ 0 -lt \$line_no ]; then
				if [ "yes" = "\$lines" ]; then
					sed \$sed_opt_i -e "\$line_no,\\\$d" "\$f"
				else
					sed \$sed_opt_i -e "\${line_no}d" "\$f"
				fi
			fi
			;;
		*) return 1 ;;
	esac

  if [ 0 -lt \$line_no ]; then
    if [ "yes" = "\$lines" ]; then
      sed \$sed_opt_i -e "\$line_no,\\\$d" "\$f"
    else
      sed \$sed_opt_i -e "\${line_no}d" "\$f"
    fi
  fi
}
`
if on_windows_nt; then
  echo ""
  echo "posix_path () { "
  echo "  echo \\\$@ | sed -e 's#\\\\\\\#\\\\\/#g'"
  echo "}"

  echo ""
  echo "find_vcvarsall () {"
  echo "	local vswhere=\\"\\\$(posix_path \\\${PROGRAMFILES}) (x86)/Microsoft Visual Studio/Installer/vswhere.exe\\""
  echo "	local vcvarsall="
  echo "	if [ -f \\"\\\$vswhere\\" ]; then"
  echo "		vcvarsall=\\"\\\$(\\"\\\$vswhere\\" -nologo -latest -property installationPath 2>/dev/null)\\""
  echo "		if [ -n \\"\\\$vcvarsall\\" ]; then"
  echo "			vcvarsall=\\"\\\$(posix_path \\\$vcvarsall)/VC/Auxiliary/Build/vcvarsall.bat\\""
  echo "			if [ -f \\"\\\$vcvarsall\\" ]; then"
  echo "				echo \\"\\\$vcvarsall\\""
  echo "				return 0"
  echo "			fi"
  echo "		fi"
  echo "	fi"
  echo ""
  echo "	vcvarsall=\\"\\\$(posix_path \\\${PROGRAMFILES}) (x86)/Microsoft Visual Studio\\""
  echo "	local ver=\\"\\\$(ls \\"\\\$vcvarsall\\" | grep -E '[0-9]+' | sort -gr | head -n1)\\""
  echo "	[ 0 -eq \\\$? ] && [ -n \\"\\\$ver\\" ] || return 1"
  echo ""
  echo "	vcvarsall=\\"\\\${vcvarsall}/\\\$ver/BuildTools/VC/Auxiliary/Build/vcvarsall.bat\\""
  echo "	if [ -f \\"\\\$vcvarsall\\" ]; then"
  echo "		echo \\"\\\$vcvarsall\\""
  echo "		return 0"
  echo "	fi"
  echo "  return 1"
  echo "}"

  echo ""
  echo "gen_cc_env_bat () {"
  echo "	local vcvarsall=\\"\\\$(find_vcvarsall)\\""
  echo "	[ 0 -eq \\\$? ] || return 1"
  echo "	local cc_env_bat=\\"\\\${CC_ENV_BAT}\\""
  echo ""
  echo "	cat << END > \\"\\\$cc_env_bat\\""
  echo "@if not \\"%VSCMD_DEBUG%\\" GEQ \\"3\\" echo off"
  echo "REM generated by Nore (${GITHUB_H}/nore)"
  echo "REM"
  echo ""
  echo "set vcvarsall=\\"\\\${vcvarsall}\\""
  echo ""
  echo "if \\"%1\\" == \\"\\" goto :\\\$(uname -m 2>/dev/null)"
  echo "if \\"%1\\" == \\"x86\\" goto :x86"
  echo "if \\"%1\\" == \\"x86_64\\" goto :x86_64"
  echo ""
  echo ":x86"
  echo "call %vcvarsall% x86"
  echo "set CC=cl"
  echo "set AS=ml"
  echo "goto :echo_inc"
  echo ""
  echo ":x86_64"
  echo "call %vcvarsall% x64"
  echo "set CC=cl"
  echo "set AS=ml64"
  echo "goto :echo_inc"
  echo ""
  echo ":echo_inc"
  echo "echo \\"%INCLUDE%\\" "
  echo "END"
  echo ""
  echo "	test -f \\"\\\$cc_env_bat\\""
  echo "}"
fi
`

gen_cc_inc_lst () {
`
if on_windows_nt; then
  echo "  [ -f \\"\\\${CC_ENV_BAT}\\" ] || return 1"
  echo "  local cc_inc=\\"\\\$(\\\${CC_ENV_BAT} | tail -n1)\\""
  echo "  [ 0 -eq \\\$? ] && [ -n \\"\\\${cc_inc}\\" ] || return 1"
else
  echo "  echo '' | cc -v -E 2>&1 >/dev/null - \\\\"
  echo "    | awk '/#include <...> search starts here:/,/End of search list./' \\\\"
  echo "    | sed '1 d' | sed '$ d' | sed 's/^ //' > \\"\\\${CC_INC_LST}\\""
  echo "  [ 0 -eq \\\$? ] || return 1"
fi
`

`
if on_windows_nt; then
  echo "  cc_inc=\\\$(echo \\\$cc_inc | sed 's#\\"##g')"
  echo "  cc_inc=\\"\\\$(posix_path \\\$cc_inc)\\""
  echo "  echo \\"\\\${cc_inc}\\" | tr ';' '\\\n' > \\"\\\${CC_INC_LST}\\""
elif on_darwin; then
  echo "  sed -i .pre 's/ (framework directory)//g' \\"\\\${CC_INC_LST}\\""
fi
`
}

src_cc_inc_vimrc () {
  command -v vim &>/dev/null || return 0
  [ -f "\${CC_INC_LST}" ] || return 1
  local cc_h="\\" nore cc inc"
  if [ ! -f "\$VIMRC" ]; then
    touch "\$VIMRC"
  else
    delete_vimrc_src "\$cc_h" "yes" "\$VIMRC"
    echo "\$cc_h" >> "\$VIMRC"
    echo "source \$CC_INC_VIMRC" >> "\$VIMRC"
  fi

  cat /dev/null > "\$CC_INC_VIMRC"
  while IFS= read -r inc; do
    local ln=\$(echo "\$inc" | sed 's_ _\\\\\\\\\\\ _g');
`
if on_windows_nt; then
  echo "    ln=\\\$(echo \\\$ln | sed 's_\\(^[a-zA-Z]\\):_\\/\\1_g')"
fi
`
    echo "set path+=\${ln}" >> "\$CC_INC_VIMRC"
  done < "\${CC_INC_LST}"
}

if test -n "\${CC_ENV_GEN}"; then
`
  if on_windows_nt; then
    echo "  gen_cc_env_bat && gen_cc_inc_lst && src_cc_inc_vimrc"
  else
    echo "  gen_cc_inc_lst && src_cc_inc_vimrc"
  fi
`
fi

END
  if ! on_windows_nt; then
    chmod u+x "$cc_env_sh"
  fi
}

echo_yes_or_no () {
  local c="$1"
  if [ 0 -eq $c ]; then
    echo "yes"
  else
    echo "no"
  fi
  return $c
}

echo_elapsed_seconds () {
  local begin=$1
  local end="`date +%s`"
  echo
  echo "... elpased $(( ${end}-${begin} )) seconds."
}

exit_checking () {
  local c="$1"
  local b="$2"
  if [ 0 -ne $c ]; then
    echo_elapsed_seconds "$b"
    exit $c
  fi
}

download_gmake () {
  local env_dir="${1:-${HOME%/}/.nore}"
  local ver="4.2.90"
  local tgz="gnumake-${ver}-`uname -m`.tar.gz"
  local url="${GITHUB_H}/make/releases/download/${ver}/${tgz}"
  local bin="${env_dir}/make.exe"
  local t=0

  [ -f "$env_dir" ] || mkdir -p "$env_dir"
  [ -f "$bin" -a "GNU Make 4.2.90" = "`$bin -v &> /dev/null | head -n1`" ] && return 0

  curl -fsL -o "${env_dir}/${tgz}" -C - "${url}" &> /dev/null
  t=$?
  if [ 33 -eq $t ]; then
    curl -fsL -o "${env_dir}/${tgz}" "${url}" &> /dev/null
  elif [ 60 -eq $t -o 22 -eq $t ]; then
    [ -f "${env_dir}/${tgz}" ] && rm "${env_dir}/${tgz}"
    curl -fskL -o "${env_dir}" "${url}" &> /dev/null
  fi
  [ 0 -eq $t ] || return $t

  tar xf "${env_dir}/${tgz}" -C "${env_dir}" --strip-components=1 &> /dev/null
}


BEGIN=`date +%s`
echo
echo "configure Nore on $PLATFORM ..."
echo

echo $echo_n " + checking make ... $echo_c"
if `make -v 1>/dev/null 2>&1`; then
  echo_yes_or_no $?
else
  echo_yes_or_no $?
  if `on_windows_nt`; then
    echo $echo_n " + downloading make ... $echo_c"
    echo_yes_or_no `download_gmake "${HOME%/}/.nore"; echo $?`
  fi
fi

[ -d "${ROOT}" ] || mkdir -p "${ROOT}"

echo $echo_n " + checking nore ... $echo_c"
if check_nore; then
  echo_yes_or_no $?
  if [ "yes" = "$NORE_UPGRADE" ]; then
    echo $echo_n " + upgrading nore ... $echo_c"
    echo_yes_or_no `upgrade_nore ; echo $?`
    exit_checking $? $BEGIN
  fi
else
  echo_yes_or_no $?
  echo $echo_n " + cloning nore ... $echo_c"
  echo_yes_or_no `clone_nore ; echo $?`
  exit_checking $? $BEGIN
fi

echo $echo_n " + generating configure ... $echo_c"
echo_yes_or_no `cat_configure ; echo $?`
exit_checking $? $BEGIN

echo $echo_n " + generating ~/.nore/cc-env.sh ... $echo_c"
echo_yes_or_no `cat_cc_env "${HOME%/}/.nore/cc-env.sh"; echo $?`
exit_checking $? $BEGIN

echo_elapsed_seconds $BEGIN

# eof
