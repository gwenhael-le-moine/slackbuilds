#!/bin/bash

# set -e

cd "$(dirname "$0")" || exit 1
CWD=$(pwd)

for pkg in \
        l/fcft \
        l/fmt \
        l/libscfg \
        l/notcurses \
        l/spdlog \
        l/tllist \
        a/nct6687d \
        ap/aegis-rs \
        ap/bat \
        ap/fd \
        ap/getssl \
        ap/glow \
        ap/gopsuinfo \
        ap/jellyfin-tui \
        ap/just \
        ap/ledger \
        ap/lsd \
        ap/nvtop \
        ap/pastel \
        ap/ripgrep \
        ap/rkvm \
        ap/starship \
        ap/tinty \
        ap/vivid \
        ap/xdg-ninja \
        ap/zauth \
        e/emacs \
        xap/brightnessctl \
        xap/cmd-polkit \
        xap/dunst \
        xap/foot \
        xap/freetube \
        xap/fuzzel \
        xap/fuzzel-polkit-agent \
        xap/gammastep \
        xap/grim \
        xap/guile-swayer \
        xap/hpemung \
        xap/i3status-rust \
        xap/lswt \
        xap/nextcloud-desktop \
        xap/openrgb \
        xap/saturnng \
        xap/slurp \
        xap/swappy \
        xap/sway \
        xap/swayidle \
        xap/wbg \
        xap/wlopm \
        xap/wlr-randr \
        xap/x48ng \
        xap/x50ng \
        y/cboard \
        y/csol \
        y/solitaire-tui \
    ;
do
    cd $pkg || exit 1
    VERSION=trunk bash -e ./SlackBuild
    cd "$CWD" || exit 1
done
