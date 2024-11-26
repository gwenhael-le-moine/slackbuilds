#!/bin/bash

cd $(dirname $0) || exit 1

PKGs_local=$(ls /var/lib/pkgtools/packages/ | sed 's|^\(.*\)-.*-.*-.*$|\1|')

SHORT_HOSTNAME=$(hostname -s)

if [ "$SHORT_HOSTNAME" == "tibou" ]; then
    PKGs_tibou=$PKGs_local
else
    PKGs_tibou=$(ssh tibou ls /var/lib/pkgtools/packages/ | sed 's|^\(.*\)-.*-.*-.*$|\1|')
fi
if [ "$SHORT_HOSTNAME" == "titplume" ]; then
    PKGs_titplume=$PKGs_local
else
    PKGs_titplume=$(ssh titplume ls /var/lib/pkgtools/packages/ | sed 's|^\(.*\)-.*-.*-.*$|\1|')
fi
if [ "$SHORT_HOSTNAME" == "tibonom" ]; then
    PKGs_tibonom=$PKGs_local
else
    PKGs_tibonom=$(ssh tibonom ls /var/lib/pkgtools/packages/ | sed 's|^\(.*\)-.*-.*-.*$|\1|')
fi
if [ "$SHORT_HOSTNAME" == "gwenhael" ]; then
    PKGs_gwenhael=$PKGs_local
else
    PKGs_gwenhael=$(ls /var/lib/pkgtools/packages/ | sed 's|^\(.*\)-.*-.*-.*$|\1|')
fi

echo "| tibou    | titplume | tibonom  | gwenhael |"
echo "|----------+----------+----------+----------+-------"
PKG_OK="|    x     "
PKG_KO="|          "
for cat in a ap d l lua n wayland xap y; do
    cd $cat
    for p in $(ls -1); do
        echo -n $PKGs_tibou | grep -q " $(echo $p | tr -d /) " && echo -n "$PKG_OK" || echo -n "$PKG_KO"
        echo -n $PKGs_titplume | grep -q " $(echo $p | tr -d /) " && echo -n "$PKG_OK" || echo -n "$PKG_KO"
        echo -n $PKGs_tibonom | grep -q " $(echo $p | tr -d /) " && echo -n "$PKG_OK" || echo -n "$PKG_KO"
        echo -n $PKGs_gwenhael | grep -q " $(echo $p | tr -d /) " && echo -n "$PKG_OK" || echo -n "$PKG_KO"

        echo "| $cat/$p"
    done | sort
    cd ..
done
