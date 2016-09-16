#!/bin/bash

USRSRC=/usr/src
GITSRC=/home/installs/linux-linus
KERNELSLACKBUILD=$(pwd)/$(basename $(pwd)).SlackBuild
PATCHFILE=/home/installs/patch

(cd $GITSRC
	git pull
)

CURRENT_VERSION=$(ls /usr/src/ | grep linux | tail -n1 | sed 's|^linux-||')
LATEST_TAG=$(cd $GITSRC; git tag | tail -n1 | sed 's|^v||')

if [[ $CURRENT_VERSION == $LATEST_TAG ]]; then
	echo "No new version"
	exit -1
else
	#make patch file
	(cd $GITSRC
		git diff v$CURRENT_VERSION v$LATEST_TAG > $PATCHFILE
	)
	(cd $USRSRC
		mv linux-$CURRENT_VERSION linux-$LATEST_TAG
		cd linux-$LATEST_TAG
		patch -p1 -i $PATCHFILE
	)
	cd $(dirname $KERNELSLACKBUILD)
	VERSION=$LATEST_TAG ./$(basename $KERNELSLACKBUILD)
fi
