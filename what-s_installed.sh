#!/bin/bash

cd "$(dirname "$0")" || exit 1

PKGs=$(find /var/lib/pkgtools/packages/ -name \*gwh | sed 's|/var/lib/pkgtools/packages/\(.*\)-.*-.*-.*$|\1|' | sort)

PKG_OK="| x "
PKG_KO="|   "

cats=${1:-a ap d fonts l n xap y}
for cat in $cats; do
    for p in $(find "$cat" -type d -maxdepth 1 -not -name "$cat" | cut -d/ -f2); do
        echo $PKGs | grep -q -e " $p " -e " $p+" && echo -n "$PKG_OK" || echo -n "$PKG_KO"
        echo "| $cat/$p"
    done | sort
done
