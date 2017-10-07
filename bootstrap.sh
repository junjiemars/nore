#!/bin/bash
#------------------------------------------------
# target: bootstrap of Nore	
# url: https://github.com/junjiemars/nore.git
# author: junjiemars@gmail.com
#------------------------------------------------

bootstrap_path() {
	local p="`dirname $0`"
	local n="./.nore"

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

PREFIX="${PREFIX:-`bootstrap_path`}"
NORE_WORK="`pwd`"

PLATFORM="`uname -s 2>/dev/null`"
GITHUB_R="${GITHUB_R:-https://raw.githubusercontent.com/junjiemars}"
GITHUB_H="${GITHUB_H:-https://github.com/junjiemars}"
GITHUB_BASH_ENV="${GITHUB_R}/kit/master/ul/setup-bash.sh"

NORE_UPGRADE=no
NORE_BRANCH=master

for option
do
  opt="$opt `echo $option | sed -e \"s/\(--[^=]*=\)\(.* .*\)/\1'\2'/\"`"
  
  case "$option" in
    -*=*) value=`echo "$option" | sed -e 's/[-_a-zA-Z0-9]*=//'` ;;
    *) value="" ;;
  esac
  
  case "$option" in
    --help)                  help=yes                   ;;
    --branch=*)              NORE_BRANCH="$value"       ;;

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


BEGIN=`date +%s`
echo 
echo "configure Nore on $PLATFORM ..."
echo

echo -n " + checking bash environment ... "
if [ ! -f "$HOME/.bash_paths" -o ! -f "$HOME/.bash_vars" ]; then
	echo "no found"
	echo 
	$(curl -sqL $GITHUB_BASH_ENV | bash &>/dev/null)
else
	echo "found"
	[ "yes" = $NORE_UPGRADE ] && $(curl -sqL $GITHUB_BASH_ENV | bash &>/dev/null)
fi
. $HOME/.bashrc

echo -n " + checking make ... "
if `make -v &>/dev/null`; then
	echo "found"
else
	echo "no found"
	case ${PLATFORM} in
	  MSYS_NT*|MINGW*)
			HAS_GMAKE=1 bash <(curl ${GITHUB_R}/kit/master/win/install-win-kits.sh)
		;;
	  *)
		;;
	esac
fi


NORE_CONFIGURE="${NORE_WORK%/}/configure"

clone_nore() {
	local n="`( cd ${PREFIX} && git remote -v 2>/dev/null | \
						 		grep 'nore\.git' &>/dev/null; echo $? )`"
	if [ 0 -eq $n ]; then
		`( cd ${PREFIX} && git reset --hard &>/dev/null )`
		cd ${PREFIX} && git pull origin ${NORE_BRANCH} &>/dev/null
	else
		git clone --depth=1 --branch=${NORE_BRANCH} ${GITHUB_H}/nore.git ${PREFIX} &>/dev/null
	fi
}

cat_configure() {
	local conf="${NORE_CONFIGURE}.n"

	cat << END > "$conf"
#!/bin/bash
NORE_PREFIX=${PREFIX%/}
NORE_GITHUB=${GITHUB_H}/nore.git
NORE_L_BOOT=\$NORE_PREFIX/bootstrap.sh
NORE_R_BOOT=${GITHUB_R}/nore/master/bootstrap.sh
NORE_L_CONF=\${NORE_PREFIX}/auto/configure


cd "\`dirname \${BASH_SOURCE}\`"

for option
do
  opt="\$opt \`echo \$option | sed -e \"s/\(--[^=]*=\)\(.* .*\)/\1'\2'/\"\`"
  
  case "\$option" in
    -*=*) value=\`echo "\$option" | sed -e 's/[-_a-zA-Z0-9]*=//'\` ;;
    *) value="" ;;
  esac
  
  case "\$option" in
    *)
			command="\`echo \$option | tr '[:upper:]' '[:lower:]'\`"
    ;;
  esac
done

case ".\$command" in
	.upgrade)
		if [ -f \$NORE_L_BOOT ]; then
			\$NORE_L_BOOT upgrade
		else
			curl -sqL \${NORE_R_BOOT} | PREFIX=\$NORE_PREFIX bash -s -- upgrade
		fi
	;;
	
	.*)
		if [ -f \$NORE_L_CONF ]; then
			\$NORE_L_CONF "\$@"
		else
			echo
			echo "!nore << no found, to fix >: configure upgrade"
			echo 
		fi
	;;
esac

END

	chmod u+x "$conf"
	mv "$conf" "$NORE_CONFIGURE"
}


[ -d "${PREFIX}" ] || mkdir -p "${PREFIX}"	
echo -n " + checking nore ... "
if [ -x "$NORE_CONFIGURE" ]; then
	echo "found"
	if [ "yes" = "$NORE_UPGRADE" ]; then
		echo -n " + upgrading nore ... "
		if `clone_nore`; then
			echo "ok"
		else
			echo "failed"
		fi
		cat_configure
	fi
else
	echo "no found"
	echo -n " + cloning nore ... "
	if `clone_nore`; then
		echo "ok"
	else
		echo "failed"
	fi
	cat_configure
fi

END="`date +%s`"
echo 
echo "... elpased $(( ${END}-${BEGIN} )) seconds, successed."

