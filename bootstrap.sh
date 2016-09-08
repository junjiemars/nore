#!/bin/bash
#------------------------------------------------
# target: bash env setup script	
# author: junjiemars@gmail.com
#------------------------------------------------

PREFIX=${PREFIX:-.}
NM_WORK=`pwd`

PLATFORM=`uname -s 2>/dev/null`
GITHUB_R=${GITHUB_R:-"https://raw.githubusercontent.com/junjiemars"}
GITHUB_H=${GITHUB_C:-"https://github.com/junjiemars"}


BEGIN=`date +%s`
echo 
echo "configure Nore on $PLATFORM ..."
echo

echo -n "checking bash environment ... "
if [ ! -f $HOME/.bash_paths -o ! -f $HOME/.bash_vars ]; then
	echo "no found"
	echo 
	curl -sqLo /tmp/setup-bash.sh ${GITHUB_R}/kit/master/ul/setup-bash.sh && \
		. /tmp/setup-bash.sh
	. $HOME/.bashrc
else
	echo "found"
fi

echo -n "checking make ... "
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

echo -n "checking Nore ... "
if [ -x $NM_CONFIGURE ]; then
	echo "found"
else
	echo "no found"
	cd ${PREFIX} && git clone --depth=1 --branch=master ${GITHUB_H}/nore.git
	cat << END > $NM_CONFIGURE
#!/bin/bash
${PREFIX%/}/nore/auto/configure \$@
END

	chmod u+x $NM_CONFIGURE

fi

END=`date +%s`
echo 
echo "... elpased $(( ${END}-${BEGIN} )) seconds, successed."

