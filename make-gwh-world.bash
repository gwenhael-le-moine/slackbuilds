#!/bin/bash

cd "$(dirname "$0")" || exit 1
CWD=$(pwd)

for pkg in \
    a/nct6687d \
        ap/aegis-rs \
        ap/bat \
        ap/btop \
        ap/checkssl \
        ap/conty-bin \
        ap/delta \
        ap/fd \
        ap/getssl \
        ap/glow \
        ap/gopsuinfo \
        ap/hledger-bin \
        ap/jellyfin-tui \
        ap/just \
        ap/ledger \
        ap/libtree \
        ap/lsd \
        ap/ncdu \
        ap/nvtop \
        ap/pastel \
        ap/pandoc-bin \
        ap/ripgrep \
        ap/rkvm \
        ap/starship \
        ap/tinty \
        ap/vivid \
        ap/zauth \
        d/crystal-lang \
        d/factor-lang \
        d/luarocks \
        d/rpn-lang \
        d/uxn \
        d/zig-lang-bin \
        e/emacs \
        l/fcft \
        l/libscfg \
        l/notcurses \
        l/spdlog \
        l/tllist \
        n/forgejo-bin \
        n/jellyfin-bin \
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
        y/csol \
        y/solitaire-tui \
    ;
do
    echo -n "$pkg > "
    PKGNAM="$(PRINT_PACKAGE_NAME=yes "$CWD"/make-pkg.bash "$pkg" | tail -n1 2>&1)"

    if [ -e /home/installs/PKGs/x86_64/gwh/"$PKGNAM" ]; then
        echo "✅"
        continue
    fi

    echo -n "building /tmp/$PKGNAM > "

    "$CWD"/make-pkg.bash "$pkg" > "$CWD/building_$PKGNAM.log" 2>&1

    if [ -e /tmp/"$PKGNAM" ]; then
        rm "$CWD/building_$PKGNAM.log"
        echo "✅"
    else
        echo "❌"
    fi
done
