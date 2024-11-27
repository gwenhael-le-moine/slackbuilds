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
    PKGs_gwenhael=$(ssh gwenhael ls /var/lib/pkgtools/packages/ | sed 's|^\(.*\)-.*-.*-.*$|\1|')
fi

PKG_OK="|    x     "
PKG_KO="|          "
counter=0
echo "| tibou    | titplume | tibonom  | gwenhael | NB |"
echo "|----------+----------+----------+----------+----+-----"
for cat in a ap d fonts l n xap y; do
    cd $cat
    for p in $(ls -1); do
        if echo -n $PKGs_tibou | grep -q " $(echo $p | tr -d /) "; then
            echo -n "$PKG_OK";
            counter=$((counter + 1));
        else
            echo -n "$PKG_KO";
        fi
        if echo -n $PKGs_titplume | grep -q " $(echo $p | tr -d /) "; then
            echo -n "$PKG_OK";
            counter=$((counter + 1));
        else
            echo -n "$PKG_KO";
        fi
        if echo -n $PKGs_tibonom | grep -q " $(echo $p | tr -d /) "; then
            echo -n "$PKG_OK";
            counter=$((counter + 1));
        else
            echo -n "$PKG_KO";
        fi
        if echo -n $PKGs_gwenhael | grep -q " $(echo $p | tr -d /) "; then
            echo -n "$PKG_OK";
            counter=$((counter + 1));
        else
            echo -n "$PKG_KO";
        fi

        echo -n "| $counter  "
        echo "| $cat/$p"

        counter=0
    done | sort
    cd ..
done
