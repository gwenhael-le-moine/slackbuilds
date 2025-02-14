#!/bin/bash -e

# required from SBo: libspng re2

for pkg in \
    hyprwayland-scanner \
        hyprutils \
        aquamarine \
        hyprgraphics \
        hyprlang \
        hyprcursor \
        Hyprland \
        sdbus-cpp \
        hyprland-protocols \
        hypridle \
        hyprlock \
        hyprpaper \
        hyprsysteminfo \
        hyprsunset \
        hyprpolkitagent \
        hyprland-qtutils \
        hyprpicker \
        hyprland-contrib \
    ; do
    cd $pkg
    rm -f /tmp/$pkg*.txz
    ./SlackBuild
    upgradepkg --install-new --reinstall /tmp/$pkg*.txz
    cd ..
done
