#!/bin/sh

cp -a /home/installs/mirrors/slackware64-current/extra/flashplayer-plugin/ /tmp/
( cd /tmp/flashplayer-plugin
  ./flashplayer-plugin.SlackBuild
)
rm -r /tmp/flashplayer-plugin

upgradepkg --install-new --reinstall /tmp/flashplayer-plugin-*.txz
/root/clean-tmp.sh
