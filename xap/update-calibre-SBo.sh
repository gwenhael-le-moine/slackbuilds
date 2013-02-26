#!/bin/sh

LOCATION=/var/lib/sbopkg/SBo/14.0/office/calibre

cd $LOCATION

OLD_VERSION=$(grep VERSION= calibre.SlackBuild.sbopkg | grep -o "[0-9.]*")

NEW_VERSION=$(echo $(echo $OLD_VERSION | grep -o "[0-9]\+.[0-9]\+.")$(echo $(expr $(echo $OLD_VERSION | cut -d. -f 3) + 1)))

sed -i "s|$OLD_VERSION|$NEW_VERSION|g" *.sbopkg

sbopkg -i calibre
