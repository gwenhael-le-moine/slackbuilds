#!/bin/sh

BUILD_DIR=${BUILD_DIR:=/home/installs/mirrors/slackware64-current/extra/google-chrome}

ARCH=${ARCH:=$(uname -m)}
case $ARCH in
    "i?86")
        DEBARCH=i386
        ;;
    "x86_64")
        DEBARCH=amd64
        ;;
esac
CHANNEL=${CHANNEL:=stable}

#cd $BUILD_DIR
[ -e google-chrome-${CHANNEL}_current_$ARCH.deb ] && rm google-chrome-${CHANNEL}_current_$DEBARCH.deb
wget -c --no-check-certificate https://dl.google.com/linux/direct/google-chrome-${CHANNEL}_current_$DEBARCH.deb
cp $BUILD_DIR/google-chrome.SlackBuild .

RELEASE=$CHANNEL BUILD=1gwh ./google-chrome.SlackBuild

upgradepkg --install-new --reinstall /tmp/google-chrome-*-$ARCH-*.txz

sed -i "s|Exec=/usr/bin/google-chrome\([a-z-]*\)|Exec=/usr/bin/google-chrome\1 --enable-features=UseOzonePlatform --ozone-platform=wayland|g" /usr/share/applications/google-chrome.desktop

rm google-chrome.SlackBuild google-chrome-${CHANNEL}_current_$DEBARCH.deb

#/root/clean-tmp.sh
