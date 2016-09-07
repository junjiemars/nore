#!/bin/bash
#------------------------------------------------
# target: bash env setup script	
# author: junjiemars@gmail.com
#------------------------------------------------

PLATFORM=`uname -s 2>/dev/null`
GITHUB_R=${GITHUB_R:-"https://raw.githubusercontent.com/junjiemars"}
GITHUB_H=${GITHUB_C:-"https://github.com/junjiemars"}


BEGIN=`date +%s`
echo "configure Nore on $PLATFORM ..."

if [ ! -f $HOME/.bash_paths -o ! -f $HOME/.bash_vars ]; then
	bash <(curl ${GITHUB_R}/kit/master/ul/setup-bash.sh)
	. $HOME/.bashrc
fi

# setup gmake for windows
case ${PLATFORM} in
  MSYS_NT*)
		HAS_GMAKE=1 bash <(curl ${GITHUB_R}/kit/master/win/install-win-kits.sh)
		;;
  *)
    ;;
esac

# setup Nore env
if [ ! -x nore/auto/configue ]; then
	git clone --depth=1 --branch=master ${GITHUB_H}/nore.git
fi

END=`date +%s`
echo 
echo "... elpased $(( ${END}-${BEGIN} )) seconds, successed."

