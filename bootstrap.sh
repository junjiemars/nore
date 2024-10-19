#!/bin/sh
#------------------------------------------------
# target: bootstrap script of Nore
# url: https://github.com/junjiemars/nore.git
# author: Junjie Mars
#------------------------------------------------

HOME="${HOME}"
PATH="/usr/bin:/usr/sbin:/bin:/sbin"
unset -f command 2>/dev/null
# check env
# check commands
set -e
awk=$(command -v awk)
chmod=$(command -v chmod)
curl=$(command -v curl)
cut=$(command -v cut)
date=$(command -v date)
dirname=$(command -v dirname)
git=$(command -v git)
grep=$(command -v grep)
ls=$(command -v ls)
mkdir=$(command -v mkdir)
mv=$(command -v mv)
printf=$(command -v printf)
ps=$(command -v ps)
pwd=$(command -v pwd)
rm=$(command -v rm)
sed=$(command -v sed)
sort=$(command -v sort)
tar=$(command -v tar)
touch=$(command -v touch)
tr=$(command -v tr)
uname=$(command -v uname)
# check shell
PLATFORM=$($uname -s 2>/dev/null)
on_windows_nt () {
 case $PLATFORM in
   MSYS_NT*|MINGW*) return 0 ;;
   *) return 1 ;;
 esac
}
on_darwin () {
  case $PLATFORM in
    Darwin) return 0 ;;
    *) return 1 ;;
  esac
}
on_linux () {
  case $PLATFORM in
    Linux) return 0 ;;
    *) return 1 ;;
  esac
}
set +e

bootstrap_path () {
  local p="`$dirname $0`"
  local n="${PWD}/.nore"

  if [ -d "${p}" ]; then
    p="`( cd \"${p}\" && $pwd )`"
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

GITHUB_R="${GITHUB_R:-https://raw.githubusercontent.com/junjiemars}"
GITHUB_H="${GITHUB_H:-https://github.com/junjiemars}"

NORE_UPGRADE=no
NORE_BRANCH=master

for option
do
  case "$option" in
    -*=*) value=`echo "$option" | $sed -e 's/[-_a-zA-Z0-9]*=//'` ;;
    *) value="" ;;
  esac

  case "$option" in
    --help)                  help=yes                   ;;
    --branch=*)              NORE_BRANCH="$value"       ;;
    --work=*)                NORE_WORK="$value"         ;;

    *)
      command="`echo $option | $tr '[:upper:]' '[:lower:]'`"
      ;;
  esac
done

case ".$command" in
  .u|.upgrade)
    NORE_UPGRADE=yes
    ;;
esac

check_nore () {
  local r="junjiemars/nore"
  if $($git -C "${ROOT}" remote -v 2>/dev/null | $grep -q "${r}"); then
    if [ "`check_nore_branch`" != "${NORE_BRANCH}" ] \
         && [ "${ROOT}" != "${PWD}/.nore" ]; then
      ROOT="${PWD}/.nore"
      [ -d "${ROOT}" ] && $rm -rf "${ROOT}"
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
  $git -C "${ROOT}" rev-parse --abbrev-ref HEAD
}

upgrade_nore () {
  local b="`check_nore_branch`"
  [ -n "${b}" ] || return 1

  $git -C "${ROOT}" reset --hard 1>/dev/null 2>&1 || return $?

  [ ${NORE_BRANCH} = ${b} ] || return $?
  $git -C "${ROOT}" pull --rebase origin ${b} 1>/dev/null 2>&1
}

clone_nore () {
  $git clone --depth=1 --branch=${NORE_BRANCH} ${GITHUB_H}/nore.git "${ROOT}" 1>/dev/null 2>&1
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

case "\`echo \${NORE_L_CONF_COMMAND} | $tr '[:upper:]' '[:lower:]'\`" in
  upgrade)
    if [ -f \${NORE_L_BOOT} ]; then
      \$NORE_L_BOOT --branch=\${NORE_BRANCH} upgrade
    else
      $curl -sqL \${NORE_R_BOOT} \\
        | ROOT=\${NORE_ROOT} sh -s -- \\
        --branch=\${NORE_BRANCH} upgrade
    fi
    exit \$?
    ;;

  clone)
    if [ -f \${NORE_L_BOOT} ]; then
      \$NORE_L_BOOT --branch=\${NORE_BRANCH} --work=\$PWD
    else
      $curl -sqL \${NORE_R_BOOT} \\
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
$(if on_darwin; then
    echo "    echo \"shell=@\$($ps -p\$\$ -ocommand|$sed -n '2p'|$cut -d ' ' -f1)\""
elif $(command -v readlink \&>/dev/null); then
    echo "    echo \"shell=@\$(readlink /proc/\$\$/exe)\""
else
    echo "    echo \"shell=@\$($ls -l /proc/\$\$/exe | $sed 's#.*->[ ]*\(.*\)#\1#g')\""
fi)
    $printf "cc-env.sh=@"
    if [ -f "\${HOME}/.nore/cc-env.sh" ]; then
      $printf "\${HOME}/.nore/cc-env.sh\n"
    else
      $printf "\n"
    fi
$(if on_windows_nt; then
  echo "    $printf \"cc-env.bat=@\""
  echo "    if [ -f \"\${HOME}/.nore/cc-env.bat\" ]; then"
  echo "      $printf \"\${HOME}/.nore/cc-env.bat\n\""
  echo "    else"
  echo "      $printf \"\\n\""
  echo "    fi"
fi)
    $printf "cc-inc.lst=@"
    if [ -f "\${HOME}/.nore/cc-inc.lst" ]; then
      $printf "\${HOME}/.nore/cc-inc.lst\n"
    else
      $printf "\n"
    fi
    $printf ".exrc=@"
    if [ -f "\${HOME}/.exrc" ]; then
      $printf "\${HOME}/.exrc\n"
    else
      $printf "\n"
    fi
    $printf "init.vim=@"
    if [ -f "\${HOME}/.config/nvim/init.vim" ]; then
      $printf "\${HOME}/.config/nvim/init.vim"
    fi
    exit \$?
    ;;

  trace)
    NORE_L_CONF_TRACE="yes"
    ;;
esac


cd "\$(CDPATH= cd -- \$($dirname -- \$0) && echo \$PWD)"

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

  $chmod u+x "$new_conf"
  $mv "$new_conf" "$conf"
}


cat_cc_env () {
  local cc_env_sh="${1:-${HOME}/.nore/cc-env.sh}"
  local env_dir="`$dirname $cc_env_sh`"
  [ -d "$env_dir" ] || $mkdir -p "$env_dir"

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
  echo "CC_ENV_BAT=\\"\\\${HOME}/.nore/cc-env.bat\\""
fi
`
CC_INC_LST="\${HOME}/.nore/cc-inc.lst"
CC_INC_EXRC="\${HOME}/.nore/cc-inc.exrc"
EXRC="\${HOME}/.exrc"


delete_exrc_src () {
  local h="\$1"
  local e="\$2"
  local f="\$3"
$(if on_darwin; then
   echo "  local sed_opt_i=\"-i .pre\""
 else
   echo "  local sed_opt_i=\"-i.pre\""
fi)
  [ -f "\$f" ] || return 0
  $sed \$sed_opt_i "/\$h/,/\$e/d" "\$f"
}
`
if on_windows_nt; then
  echo ""
  echo "posix_path () { "
  echo "  echo \\\$@ | $sed -e 's#\\\\\\\#\\\\\/#g'"
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
  echo "	local ver=\\"\\\$($ls \\"\\\$vcvarsall\\" | $grep -E '[0-9]+' | $sort -gr | $sed 1q)\\""
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
$(if on_windows_nt; then
  $printf "  [ -f \"\${CC_ENV_BAT}\" ] || return 1\n"
  $printf "  cat \"\${CC_ENV_BAT}\" | sed '\$d'\n"
else
  $printf "  local r='/#include <...> search starts here:/,/End of search list./p'\n"
  $printf "  $printf '' | cc -v -E 2>&1 >/dev/null - %s\n" "\\"
  $printf "     | $sed -n \"\$r\" %s\n" "\\"
  $printf "     | $sed '1d;\$d' %s\n" "\\"
  $printf "     | $sed -e '/.*(framework directory).*/d' -e 's/^ *//' %s\n" "\\"
  $printf "  > \"\${CC_INC_LST}\"\n"
fi)
}

src_cc_inc_exrc () {
  local cc_h="\\" nore cc inc"
  local cc_e="\\" eof cc inc"
  command -v vim >/dev/null 2>/dev/null || return 0
  [ -f "\${CC_INC_LST}" ] || return 1
  [ -f "\$EXRC" ] || $touch "\$EXRC"
  delete_exrc_src "\$cc_h" "\$cc_e" "\$EXRC"
  $printf "\${cc_h}\n" >> "\$EXRC"
  cat "\${CC_INC_LST}" | awk '{print "set path+=" \$0}' >> "\$EXRC"
#   while IFS= read -r inc; do
#     echo "abc_\$inc_abc
#     local ln=\$(echo "\$inc" | sed 's_ _\\\\\\\\\\\ _g');
# `
# if on_windows_nt; then
#   echo "    ln=\\\$(echo \\\$ln | sed 's_\\(^[a-zA-Z]\\):_\\/\\1_g')"
# fi
# `
#     echo "set path+=\${ln}" >> "\$CC_INC_EXRC"
#   done < "\${CC_INC_LST}"
  echo "\$cc_e" >> "\$EXRC"
}

gen_nvim_init () {
  local d="\${HOME}/.config/nvim"
  command -v nvim &>/dev/null || return 1
  [ -f "\$EXRC" ] || return 1
  [ -f "\${d}/init.vim" ] || return 1
  [ -d "\$d" ] || mkdir -p "\$d"
  ln -s "\$EXRC" "\${d}/init.vim"
}

gen_cc_tags () {
  [ -f "\${CC_INC_LST}" ] || return 1
  command -v ctags &>/dev/null || return 1
  ctags -a -oTAGS --langmap=c:.h.c --c-kinds=+px -R -L "\${CC_INC_LST}"
}

if test -n "\${CC_ENV_GEN}"; then
$(if on_windows_nt; then
    $printf "  gen_cc_env_bat && gen_cc_inc_lst && src_cc_inc_exrc\n"
  else
    $printf "  gen_cc_inc_lst && src_cc_inc_exrc\n"
    $printf "  # gen_nvim_init\n"
    $printf "  # gen_cc_tags\n"
  fi)
fi

END
  if ! on_windows_nt; then
    $chmod u+x "$cc_env_sh"
  fi
}

echo_yes_or_no () {
  local c="$1"
  if [ 0 -eq $c ]; then
    $printf "yes\n"
  else
    $printf "no\n"
  fi
  return $c
}

echo_elapsed_seconds () {
  local begin=$1
  local end="$($date +%s)"
  $printf "\n... elpased %d seconds.\n" $(( ${end}-${begin} ))
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
  local env_dir="${1:-${HOME}/.nore}"
  local ver="4.2.90"
  local tgz="gnumake-${ver}-`$uname -m`.tar.gz"
  local url="${GITHUB_H}/make/releases/download/${ver}/${tgz}"
  local bin="${env_dir}/make.exe"
  local t=0

  [ -f "$env_dir" ] || $mkdir -p "$env_dir"
  [ -f "$bin" -a "GNU Make 4.2.90" = "`$bin -v &> /dev/null | $sed 1q`" ] && return 0

  $curl -fsL -o "${env_dir}/${tgz}" -C - "${url}" &> /dev/null
  t=$?
  if [ 33 -eq $t ]; then
    $curl -fsL -o "${env_dir}/${tgz}" "${url}" &> /dev/null
  elif [ 60 -eq $t -o 22 -eq $t ]; then
    [ -f "${env_dir}/${tgz}" ] && $rm "${env_dir}/${tgz}"
    $curl -fskL -o "${env_dir}" "${url}" &> /dev/null
  fi
  [ 0 -eq $t ] || return $t

  $tar xf "${env_dir}/${tgz}" -C "${env_dir}" --strip-components=1 &> /dev/null
}


BEGIN=`$date +%s`
echo
echo "configure Nore on $PLATFORM ..."
echo

$printf " + checking make ... "
if make -v 2>&1 1>/dev/null; then
  echo_yes_or_no $?
else
  echo_yes_or_no $?
  if `on_windows_nt`; then
    $printf " + downloading make ... "
    echo_yes_or_no `download_gmake "${HOME}/.nore"; echo $?`
  fi
fi

$printf " + checking nore ... "
if check_nore; then
  echo_yes_or_no $?
  if [ "yes" = "$NORE_UPGRADE" ]; then
    $printf " + upgrading nore ... "
    echo_yes_or_no $(upgrade_nore; echo $?)
    exit_checking $? $BEGIN
  fi
else
  echo_yes_or_no $?
  $printf " + cloning nore ... "
  echo_yes_or_no $(clone_nore; echo $?)
  exit_checking $? $BEGIN
fi

$printf " + generating configure ... "
echo_yes_or_no $(cat_configure; echo $?)
exit_checking $? $BEGIN

$printf " + generating ~/.nore/cc-env.sh ... "
echo_yes_or_no $(cat_cc_env "${HOME}/.nore/cc-env.sh"; echo $?)
exit_checking $? $BEGIN

echo_elapsed_seconds $BEGIN

# eof
