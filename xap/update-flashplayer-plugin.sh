#!/bin/sh

LATEST_VERSION=$(wget -c "https://get.adobe.com/fr/flashplayer/download/?installer=Flash_Player_11.2_for_other_Linux_(.tar.gz)_64-bit&standalone=1" -O - | grep -o "https://fpdownload.adobe.com/get/flashplayer/pdc/[0-9.]*/install_flash_player_11_linux.x86_64.tar.gz" | grep -o "/[0-9.]*/" | tr -d / | grep -v "^$")

cd /home/installs/mirrors/slackware64-current/extra/flashplayer-plugin
VERSION=$LATEST_VERSION ./flashplayer-plugin.SlackBuild
rm install_flash_player_11_linux.x86_64.tar.gz

upgradepkg --install-new --reinstall /tmp/flashplayer-plugin-$LATEST_VERSION-x86_64-1alien.txz
/root/clean-tmp.sh
