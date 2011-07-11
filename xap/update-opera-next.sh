#!/bin/sh

ARCH=${ARCH:=$(uname -m)} #i386 for 32 bits
PKGs_ARCHIVE=${PKGs_ARCHIVE:=/home/installs/PKGs}
LATEST_PKG_NAME=$(lftp http://people.opera.com/ruario/snapshot/ -e "ls ; bye" | grep -o "opera-next-.*-x86_64-1ro.tlz")

if [ -e $PKGs_ARCHIVE/$LATEST_PKG_NAME ]; then
	echo "Latest package already installed."
else
	wget -c http://people.opera.com/ruario/snapshot/$LATEST_PKG_NAME -O $PKGs_ARCHIVE/$LATEST_PKG_NAME \
		&& upgradepkg --install-new $PKGs_ARCHIVE/$LATEST_PKG_NAME
fi
