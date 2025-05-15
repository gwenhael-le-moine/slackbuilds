#!/bin/bash

cd "$(dirname "$0")" || exit 1
CWD=$(pwd)

DRYRUN="false"
INSTALL="true"

until [ -z "$1" ]
do
    case $1 in
        "--dry-run"|"--dryrun")
            DRYRUN="true"
            shift
            ;;
        "--no-install")
            INSTALL="false"
            shift
            ;;

        "-h"|"--help"|*)
            echo "$0 \\"
            echo "  --dry-run : only check but don't build packages"
            echo "  --no-install : don't install the packages after building"
            exit
    esac
done

for pkg in $("$CWD"/what-s_installed.sh | grep "^| x | " | sed 's/| x | //') ;
    do
        echo -n "$pkg > "
        if [ ! -e "$pkg"/SlackBuild ] || ! grep -q "PRINT_PACKAGE_NAME" "$pkg"/SlackBuild; then
            echo "INCOMPATIBLE"
            continue
        fi
        PKGNAM="$(PRINT_PACKAGE_NAME=yes "$CWD"/make-pkg.bash "$pkg" | tail -n1 2>&1)"

    if [ -e /home/installs/PKGs/x86_64/gwh/"$PKGNAM" ]; then
        echo "✅"
        continue
    fi

    echo -n "building /tmp/$PKGNAM > "

    if [ "$DRYRUN" = "true" ]; then
        echo "-"
        continue
    fi

    "$CWD"/make-pkg.bash "$pkg" > "$CWD/building_$PKGNAM.log" 2>&1

    if [ -e /tmp/"$PKGNAM" ]; then
        rm "$CWD/building_$PKGNAM.log"
        [ "$INSTALL" = "true" ] && upgradepkg --terse /tmp/"$PKGNAM"
        echo "✅"
    else
        echo "❌"
    fi
done
