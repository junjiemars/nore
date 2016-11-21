#!/bin/bash
#------------------------------------------------
# target: bootstrap of Nore	
# author: junjiemars@gmail.com
#------------------------------------------------

bootstrap_path() {
	local p="`dirname $0`"
	local n="./.nore"

	if [ -d \"${p}\" ]; then
		p="`( cd \"${p}\" && pwd )`"
		if [ -z "$p" -o "/dev/fd" = "$p" ]; then
			echo "$n"
		else
			echo "$p"
		fi
	else
		echo "$n"
	fi
}

PREFIX=${PREFIX:-"`bootstrap_path`"}
NM_WORK=`pwd`

PLATFORM=`uname -s 2>/dev/null`
GITHUB_R=${GITHUB_R:-"https://raw.githubusercontent.com/junjiemars"}
GITHUB_H=${GITHUB_C:-"https://github.com/junjiemars"}


case ".$1" in
	.-u|.--update)
		NORE_UPDATE=0
		;;
	*)
		NORE_UPDATE=1
		;;
esac


BEGIN=`date +%s`
echo 
echo "configure Nore on $PLATFORM ..."
echo

setup_bash() {
	local setup="$1"
	curl -sqLo $setup ${GITHUB_R}/kit/master/ul/setup-bash.sh && $setup
}

echo -n " + checking bash environment ... "
if [ ! -f $HOME/.bash_paths -o ! -f $HOME/.bash_vars ]; then
	echo "no found"
	echo 
	`setup_bash /tmp/setup-bash.sh`
else
	echo "found"
	[ 0 -eq $NORE_UPDATE ] && `setup-bash /tmp/setup-bash.sh`
fi
. $HOME/.bashrc

echo -n " + checking make ... "
if `make -v &>/dev/null`; then
	echo "found"
else
	echo "no found"
	case ${PLATFORM} in
	  MSYS_NT*)
			HAS_GMAKE=1 bash <(curl ${GITHUB_R}/kit/master/win/install-win-kits.sh)
			;;
	  *)
	    ;;
	esac
fi


NM_CONFIGURE=${NM_WORK%/}/configure

clone_nore() {
	local n=`( cd ${PREFIX} && git remote -v 2>/dev/null | \
						 		grep 'nore\.git' &>/dev/null; echo $?)`
	if [ 0 -eq $n ]; then
		`( cd ${PREFIX} && git reset --hard &>/dev/null )`
		cd ${PREFIX} && git pull origin master &>/dev/null
	else
		git clone --depth=1 --branch=master ${GITHUB_H}/nore.git ${PREFIX} &>/dev/null
	fi
}

cat_configure() {
	local conf="${NM_CONFIGURE}.n"

	cat << END > $conf
#!/bin/bash
NORE_PREFIX=${PREFIX%/}
NORE_ARGS=\$@
NORE_GITHUB=${GITHUB_H}/nore.git
NORE_L_BOOT=\$NORE_PREFIX/bootstrap.sh
NORE_R_BOOT=${GITHUB_R}/nore/master/bootstrap.sh
NORE_L_CONF=\${NORE_PREFIX}/auto/configure


cd "\`dirname \${BASH_SOURCE}\`" && \\
if [ 1 -le \$# ]; then
	case ".\$1" in
	  .-u*|.--update*)
			if [ -f \$NORE_L_BOOT ]; then
				\$NORE_L_BOOT -u
			else
				curl -sqL \${NORE_R_BOOT} | PREFIX=\$NORE_PREFIX bash -s -- -u
			fi
	
	    #NORE_ARGS=\${@:2}
	  	;;
		.*)
			if [ -f \$NORE_L_CONF ]; then
				\$NORE_L_CONF \$NORE_ARGS
			else
				echo
				echo "!nore << no found, to fix >: configure --update"
				echo 
			fi
			;;
	esac
fi

END

	chmod u+x $conf
	mv $conf $NM_CONFIGURE
}


[ -d ${PREFIX} ] || mkdir -p ${PREFIX}	
echo -n " + checking nore ... "
if [ -x $NM_CONFIGURE ]; then
	echo "found"
	if [ 0 -eq $NORE_UPDATE ]; then
		echo -n " + updating nore ... "
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

END=`date +%s`
echo 
echo "... elpased $(( ${END}-${BEGIN} )) seconds, successed."

