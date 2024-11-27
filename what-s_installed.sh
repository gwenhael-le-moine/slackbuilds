#!/bin/bash

cd $(dirname $0) || exit 1

PKGs=$(ls /var/lib/pkgtools/packages/ | sed 's|^\(.*\)-.*-.*-.*$|\1|')

PKG_OK="| x "
PKG_KO="|   "

for cat in a ap d fonts l n xap y; do
    cd $cat
    for p in $(ls -1); do
        echo $PKGs | grep -q " $(echo $p | tr -d /) " && echo -n "$PKG_OK" || echo -n "$PKG_KO"
        echo "| $cat/$p"
    done | sort
    cd ..
done
