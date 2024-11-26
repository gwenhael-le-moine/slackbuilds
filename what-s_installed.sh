#!/bin/bash

cd $(dirname $0) || exit 1

PKGs=$(ls /var/lib/pkgtools/packages/ | sed 's|^\(.*\)-.*-.*-.*$|\1|')

for cat in a ap d l lua n wayland xap y; do
    cd $cat
    for p in $(ls -1); do
        echo $PKGs | grep -q " $(echo $p | tr -d /) " && echo -n "✓: " || echo -n "❌: "
        echo "$cat/$p"
    done | sort
    cd ..
done
