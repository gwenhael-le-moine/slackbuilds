#!/bin/sh

BUILD_DIR=${BUILD_DIR:=/home/installs/slackware64-current/extra/google-chrome}

ARCH=${ARCH:=$(uname -m)}
case $ARCH in
    "i?86")
        ARCH=i386
        ;;
    "x86_64")
        ARCH=amd64
        ;;
esac
CHANNEL=${CHANNEL:=stable}

cd $BUILD_DIR
[ -e google-chrome-${CHANNEL}_current_$ARCH.deb ] && rm google-chrome-${CHANNEL}_current_$ARCH.deb
wget -c http://dl.google.com/linux/direct/google-chrome-${CHANNEL}_current_$ARCH.deb
RELEASE=$CHANNEL ./google-chrome.SlackBuild
[ " x$1" -eq "x--install" ] && upgradepkg --install-new $(ls -ut /tmp/google-chrome-*-$(uname -m)-*.txz | head -n1)
