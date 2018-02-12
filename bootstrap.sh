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

on_windows_nt () {
    case "$PLATFORM" in 
        MSYS_NT* | MINGW*)
            return 0
        ;;
        *)
            return 1
        ;;
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

cat_configure() {
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

# cd "\`dirname \${BASH_SOURCE}\`"

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

  debug)
    NORE_L_CONF_DEBUG="yes"
  ;;
esac

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


echo_elapsed_seconds $BEGIN

