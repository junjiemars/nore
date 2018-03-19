#!/bin/bash
#------------------------------------------------
# target: bootstrap of Nore	
# url: https://github.com/junjiemars/nore.git
# author: junjiemars@gmail.com
#------------------------------------------------

bootstrap_path() {
	local p="`dirname $0`"
	local n="`pwd`/.nore"

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
NORE_WORK="`pwd`"

PLATFORM="`uname -s 2>/dev/null`"
GITHUB_R="${GITHUB_R:-https://raw.githubusercontent.com/junjiemars}"
GITHUB_H="${GITHUB_H:-https://github.com/junjiemars}"
GITHUB_BASH_ENV="${GITHUB_R}/kit/master/ul/setup-bash.sh"

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

on_windows_nt() {
 case "$PLATFORM" in
   MSYS_NT*|MINGW*) return 0 ;;
   *) return 1 ;;
 esac
}

on_darwin() {
  case "$PLATFORM" in
    Darwin) return 0 ;;
    *) return 1 ;;
  esac
}

on_linux() {
  case "$PLATFORM" in
    Linux) return 0 ;;
    *) return 1 ;;
  esac
}

check_nore() {
	cd ${ROOT} && git remote -v 2>/dev/null | grep 'nore\.git' &>/dev/null
}

check_nore_branch() {
  cd ${ROOT} && git rev-parse --abbrev-ref HEAD
}

upgrade_nore() {
  local b="`check_nore_branch`"
	[ -n "${b}" ] || return 1

  cd ${ROOT} && git reset --hard &>/dev/null || return $?
  
	[ ${NORE_BRANCH} = ${b} ] || return $?
  cd ${ROOT} && git pull --rebase origin ${b} &>/dev/null
}

clone_nore() {
	git clone --depth=1 --branch=${NORE_BRANCH} \
		${GITHUB_H}/nore.git ${ROOT} &>/dev/null
}

cat_configure () {
  local b="`check_nore_branch`"
  local conf="${NORE_WORK%/}/configure"
  local new_conf="${conf}.n"

	cat << END > "$new_conf"
#!/bin/bash
#------------------------------------------------
# target: configure
# author: junjiemars@gmail.com
# generated by Nore (${GITHUB_H}/nore)
#------------------------------------------------

NORE_ROOT="${ROOT%/}"
NORE_BRANCH="${b}"
NORE_L_BOOT="\${NORE_ROOT}/bootstrap.sh"
NORE_R_BOOT="${GITHUB_R}/nore/\${NORE_BRANCH}/bootstrap.sh"
NORE_L_CONF="\${NORE_ROOT}/auto/configure"
NORE_L_CONF_OPTS=()
NORE_L_CONF_DEBUG="no"
NORE_L_CONF_COMMAND=


for option
do
  case "\$option" in
    -*=*) NORE_L_CONF_OPTS+=("\$option")  ;;

    -*) NORE_L_CONF_OPTS+=("\$option")  ;;

    *) NORE_L_CONF_COMMAND="\$option"  ;;
  esac
done

case "\`echo \${NORE_L_CONF_COMMAND} | tr '[:upper:]' '[:lower:]'\`" in
	upgrade)
		if [ -f \${NORE_L_BOOT} ]; then
			\$NORE_L_BOOT --branch=\${NORE_BRANCH} upgrade
		else
			curl -sqL \${NORE_R_BOOT} \\
				| ROOT=\${NORE_ROOT} bash -s -- \\
        --branch=\${NORE_BRANCH} upgrade
		fi
    exit \$?
	;;

  clone)
		if [ -f \${NORE_L_BOOT} ]; then
			\$NORE_L_BOOT --branch=\${NORE_BRANCH} --work=\`pwd\`
		else
			curl -sqL \${NORE_R_BOOT} \\
				| ROOT=\${NORE_ROOT} bash -s -- \\
        --branch=\${NORE_BRANCH} \\
        --work=\`pwd\`
		fi
    exit \$?
  ;;

  where)
    echo -e "NORE_ROOT=\${NORE_ROOT}"
    echo -e "NORE_BRANCH=\${NORE_BRANCH}"
    echo -e "configure=\${BASH_SOURCE[0]}"
    echo -e "make=\$(command -v make)"
    echo -e "bash=\$(ps -s -p \$(echo \$\$) | tr ' ' '\n' | tail -n1)"
    echo -n ".cc-env.sh="
    if [ -f "\${HOME%/}/.cc-env.sh" ]; then
      echo -e "\${HOME%/}.cc-env.sh"
    fi
    echo -n ".cc-env.id"
    if [ -f "\${HOME%/}/.cc-env.id" ]; then
      echo -e "\${HOME%/}/.cc-env.id[\$(cat \${HOME%/}/.cc-env.id)]"
    fi
		`if on_windows_nt; then
       echo "    echo -n \".cc-end.bat=\""
       echo "    if [ -f \"\\${HOME%/}/.cc-env.bat\" ]; then"
       echo "      echo -e \"\\${HOME%/}/.cc-env.bat\""
       echo "    fi"
    fi`
    echo -n ".cc-inc.lst="
    if [ -f "\${HOME%/}/.cc-inc.lst" ]; then
      echo -e "\${HOME%/}/.cc-inc.lst"
    fi
    echo -n ".cc-inc.vimrc="
    if [ -f "\${HOME%/}/.cc-inc.vimrc" ]; then
      echo -e "\${HOME%/}/.cc-inc.vimrc"
    fi
    exit \$?
  ;;

  debug)
    NORE_L_CONF_DEBUG="yes"
  ;;
esac

cd "\`dirname \${BASH_SOURCE}\`"

if [ -f \${NORE_L_CONF} ]; then
  case "\${NORE_L_CONF_DEBUG}" in
	  no)
      \$NORE_L_CONF "\$@"
    ;;
    yes)  
      bash -x \$NORE_L_CONF "\${NORE_L_CONF_OPTS[@]}"
    ;;
  esac
else
	echo
	echo "!nore << no found, to fix >: configure upgrade"
	echo 
fi

END

	chmod u+x "$new_conf"
	mv "$new_conf" "$conf"
}


cat_cc_env() {
	local cc_env_sh="${1:-${HOME%/}/.cc-env.sh}"
	cat << END > "$cc_env_sh"
#!/bin/bash
#------------------------------------------------
# target: .cc-env.sh
# author: junjiemars@gmail.com
# generated by Nore (${GITHUB_H}/nore)
#------------------------------------------------

CC_ENV_ID="\${HOME%/}/.cc-env.id"
`
if on_windows_nt; then
  echo "CC_ENV_BAT=\"\\${HOME%/}/.cc-env.bat\""
fi
`
CC_INC_LST="\${HOME%/}/.cc-inc.lst"
CC_INC_VIMRC="\${HOME%/}/.cc-inc.vimrc"
VIMRC="\${HOME%/}/.vimrc"


delete_vimrc_src () {
  local h="\$1"
  local lines="\$2"
  local f="\$3"
`if on_darwin; then
	 echo "  local sed_opt_i=\"-i .pre\""
 else
   echo "  local sed_opt_i=\"-i.pre\""
 fi
`

  [ -f "\$f" ] || return 0

  local line_no=\`grep -m1 -n "^\${h}" \$f | cut -d':' -f1\`
  [[ \$line_no =~ ^[0-9]+\$ ]] || return 1

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
  echo "  echo \\$@ | sed -e 's#\\\\\#\\\/#g'"
  echo "}"

  echo ""
  echo "find_vcvarsall () {"
  echo "	local vswhere=\"\\$(posix_path \\${PROGRAMFILES}) (x86)/Microsoft Visual Studio/Installer/vswhere.exe\""
  echo "	local vcvarsall="
  echo "	if [ -f \"\\$vswhere\" ]; then"
  echo "		vcvarsall=\"\\$(\"\\$vswhere\" -nologo -latest -property installationPath 2>/dev/null)\""
  echo "		if [ -n \"\\$vcvarsall\" ]; then"
  echo "			vcvarsall=\"\\$(posix_path \\$vcvarsall)/VC/Auxiliary/Build/vcvarsall.bat\""
  echo "			if [ -f \"\\$vcvarsall\" ]; then"
  echo "				echo \"\\$vcvarsall\""
  echo "				return 0"
  echo "			fi"
  echo "		fi"
  echo "	fi"
  echo ""
  echo "	vcvarsall=\"\\$(posix_path \\${PROGRAMFILES}) (x86)/Microsoft Visual Studio\""
  echo "	local ver=\"\\$(ls \"\\$vcvarsall\" | grep -E '[0-9]+' | sort -gr | head -n1)\""
  echo "	[ 0 -eq \\$? ] && [ -n \"\\$ver\" ] || return 1"
  echo ""
  echo "	vcvarsall=\"\\${vcvarsall}/\\$ver/BuildTools/VC/Auxiliary/Build/vcvarsall.bat\""
  echo "	if [ -f \"\\$vcvarsall\" ]; then"
  echo "		echo \"\\$vcvarsall\""
  echo "		return 0"
  echo "	fi"
  echo "  return 1"
  echo "}"

  echo ""
  echo "gen_cc_env_bat () {"
  echo "	local vcvarsall=\"\\$(find_vcvarsall)\""
  echo "	[ 0 -eq \\$? ] || return 1"
  echo "	local cc_env_bat=\"\\${CC_ENV_BAT}\""
  echo ""
  echo "	cat << END > \"\\$cc_env_bat\""
  echo "@echo off"
  echo "REM generated by Nore (${GITHUB_H}/nore)"
  echo "REM"
  echo ""
  echo "set vcvarsall=\"\\${vcvarsall}\""
  echo ""
  echo "if \"%1\" == \"\" goto :\\$(uname -m 2>/dev/null)"
  echo "if \"%1\" == \"x86\" goto :x86"
  echo "if \"%1\" == \"x86_64\" goto :x86_64"
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
  echo "echo \"%INCLUDE%\" "
  echo "END"
  echo ""
  echo "	test -f \"\\$cc_env_bat\""
  echo "}"
fi
`

gen_cc_inc_lst () {
`
if on_windows_nt; then
  echo "  [ -f \"\\${CC_ENV_BAT}\" ] || return 1"
  echo "  local cc_inc=\"\\$(\\${CC_ENV_BAT} | tail -n1)\""
  echo "  [ 0 -eq \\$? ] && [ -n \"\\${cc_inc}\" ] || return 1"
else
  echo "  echo '' | cc -v -E 2>&1 >/dev/null - \\\"
  echo "    | awk '/#include <...> search starts here:/,/End of search list./' \\\"
  echo "    | sed '1 d' | sed '$ d' | sed 's/^ //' > \"\\${CC_INC_LST}\""
  echo "  [ 0 -eq \\$? ] || return 1"
fi
`
	
`
if on_windows_nt; then
  echo "  cc_inc=\\$(echo \\$cc_inc | sed 's#\\"##g')"
  echo "  cc_inc=\"\\$(posix_path \\$cc_inc)\""
  echo "  echo \"\\${cc_inc}\" | tr ';' '\n' > \"\\${CC_INC_LST}\""
elif on_darwin; then
  echo "  sed -i .pre 's/ (framework directory)//g' \"\\${CC_INC_LST}\""
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
    echo -e "\$cc_h" >> "\$VIMRC"
    echo "source \$CC_INC_VIMRC" >> "\$VIMRC"
  fi

  cat /dev/null > "\$CC_INC_VIMRC"
  while IFS= read -r inc; do
    local ln=\$(echo "\$inc" | sed 's_ _\\\\\\\\\\\ _g');
`
if on_windows_nt; then
  echo "    ln=\\$(echo \\$ln | sed 's_\(^[a-zA-Z]\):_\/\1_g')"
fi
`
    echo "set path+=\${ln}" >> "\$CC_INC_VIMRC"
  done < "\${CC_INC_LST}"
}

if test ! -f "\${CC_ENV_ID}" || test "0" != "\`cat \${CC_ENV_ID}\`"; then
`
  if on_windows_nt; then
    echo "  gen_cc_env_bat && gen_cc_inc_lst && src_cc_inc_vimrc"
  else
    echo "  gen_cc_inc_lst && src_cc_inc_vimrc"
  fi
`
  echo \$? > "\${CC_ENV_ID}"
fi

END
  if ! on_windows_nt; then
    chmod u+x "$cc_env_sh"
  fi
}

echo_found_or_not() {
  local c="$1"
  if [ 0 -eq $c ]; then
    echo "found"
  else
    echo "no found"
  fi
  return $c
}

echo_ok_or_failed() {
	local c=$1
	if [ 0 -eq $c ]; then
		echo "ok"
	else
		echo "failed"
	fi
	return $c
}

echo_elapsed_seconds() {
	local begin=$1
	local end="`date +%s`"
	echo 
	echo "... elpased $(( ${end}-${begin} )) seconds."
}

exit_checking() {
	local c="$1"
  local b="$2"
	if [ 0 -ne $c ]; then
    echo_elapsed_seconds "$b"
		exit $c
	fi
}


BEGIN=`date +%s`
echo 
echo "configure Nore on $PLATFORM ..."
echo

echo -n " + checking make ... "
if `make -v &>/dev/null`; then
	echo_found_or_not $?
else
  echo_found_or_not $?
	if `on_windows_nt`; then
		echo -n " + checking bash environment ... "
		if `echo $INSIDE_KIT_BASH_ENV | grep 'junjiemars/kit' &>/dev/null`; then
      echo_found_or_not $?
			if [ "yes" = $NORE_UPGRADE ]; then
        echo -n " + upgrading bash environement ... "
        $(curl -sqL $GITHUB_BASH_ENV | bash &>/dev/null)
        echo_ok_or_failed $?
        exit_checking $? $BEGIN
      fi
		else
			echo_found_or_not $?
			echo 
			$(curl -sqL $GITHUB_BASH_ENV | bash &>/dev/null)
		fi
		exit_checking $? $BEGIN
		. $HOME/.bashrc

		echo -n " + installing make ... "
		HAS_GMAKE=1 ECHO_QUIET=YES bash <(curl -sqL ${GITHUB_R}/kit/master/win/install-win-kits.sh)
		echo_ok_or_failed $?
		exit_checking $? $BEGIN
	fi
fi

[ -d "${ROOT}" ] || mkdir -p "${ROOT}"

echo -n " + checking nore ... "
if `check_nore`; then
 echo_found_or_not $?
 if [ "yes" = "$NORE_UPGRADE" ]; then
   echo -n " + upgrading nore ... "
	 echo_ok_or_failed `upgrade_nore ; echo $?`
	 exit_checking $? $BEGIN
 fi
else
 echo_found_or_not $?
 echo -n " + cloning nore ... "
 echo_ok_or_failed `clone_nore ; echo $?`
 exit_checking $? $BEGIN
fi

echo -n " + generating configure ... "
echo_ok_or_failed `cat_configure ; echo $?`
exit_checking $? $BEGIN

if on_windows_nt; then
	echo -n " + generating %userprofile%/.cc-env.sh ... "
else
	echo -n " + generating ~/.cc-env.sh ... "
fi
echo_ok_or_failed `cat_cc_env "${HOME%/}/.cc-env.sh"; echo $?`
exit_checking $? $BEGIN

echo_elapsed_seconds $BEGIN

