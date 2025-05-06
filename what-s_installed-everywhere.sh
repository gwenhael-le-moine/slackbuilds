#!/bin/bash

cd "$(dirname "$0")" || exit 1

PKGs_local=$(find /var/lib/pkgtools/packages/ -name \*gwh | sed 's|/var/lib/pkgtools/packages/\(.*\)-.*-.*-.*$|\1|' | sort)

SHORT_HOSTNAME=$(hostname -s)

if [ "$SHORT_HOSTNAME" = "tibou" ]; then
    PKGs_tibou=$PKGs_local
else
    PKGs_tibou=$(ssh tibou "find /var/lib/pkgtools/packages/ -name \*gwh | sed 's|/var/lib/pkgtools/packages/\(.*\)-.*-.*-.*$|\1|' | sort")
fi
if [ "$SHORT_HOSTNAME" = "titplume" ]; then
    PKGs_titplume=$PKGs_local
else
    PKGs_titplume=$(ssh titplume "find /var/lib/pkgtools/packages/ -name \*gwh | sed 's|/var/lib/pkgtools/packages/\(.*\)-.*-.*-.*$|\1|' | sort")
fi
if [ "$SHORT_HOSTNAME" = "tibonom" ]; then
    PKGs_tibonom=$PKGs_local
else
    PKGs_tibonom=$(ssh tibonom "find /var/lib/pkgtools/packages/ -name \*gwh | sed 's|/var/lib/pkgtools/packages/\(.*\)-.*-.*-.*$|\1|' | sort")
fi
if [ "$SHORT_HOSTNAME" = "gwenhael" ]; then
    PKGs_gwenhael=$PKGs_local
else
    PKGs_gwenhael=$(ssh gwenhael "find /var/lib/pkgtools/packages/ -name \*gwh | sed 's|/var/lib/pkgtools/packages/\(.*\)-.*-.*-.*$|\1|' | sort")
fi
if [ "$SHORT_HOSTNAME" = "titrash" ]; then
    PKGs_titrash=$PKGs_local
else
    PKGs_titrash=$(ssh titrash "find /var/lib/pkgtools/packages/ -name \*gwh | sed 's|/var/lib/pkgtools/packages/\(.*\)-.*-.*-.*$|\1|' | sort")
fi

PKG_OK="|    x     "
PKG_KO="|          "
counter=0
echo "| tibou    | titplume | tibonom  | titrash  | gwenhael | NB |"
echo "|----------+----------+----------+----------+----------+----+-----"
for cat in a ap d fonts l n xap y; do
    for p in $(find "$cat" -type d -maxdepth 1 -not -name "$cat" | cut -d/ -f2); do
        if echo -n $PKGs_tibou | grep -q -e " $p " -e " $p+"; then
            echo -n "$PKG_OK";
            counter=$((counter + 1));
        else
            echo -n "$PKG_KO";
        fi
        if echo -n $PKGs_titplume | grep -q -e " $p " -e " $p+"; then
            echo -n "$PKG_OK";
            counter=$((counter + 1));
        else
            echo -n "$PKG_KO";
        fi
        if echo -n $PKGs_tibonom | grep -q -e " $p " -e " $p+"; then
            echo -n "$PKG_OK";
            counter=$((counter + 1));
        else
            echo -n "$PKG_KO";
        fi
        if echo -n $PKGs_titrash | grep -q -e " $p " -e " $p+"; then
            echo -n "$PKG_OK";
            counter=$((counter + 1));
        else
            echo -n "$PKG_KO";
        fi
        if echo -n $PKGs_gwenhael | grep -q -e " $p " -e " $p+"; then
            echo -n "$PKG_OK";
            counter=$((counter + 1));
        else
            echo -n "$PKG_KO";
        fi

        echo -n "| $counter  "
        echo "| $cat/$p"

        counter=0
    done | sort
done
