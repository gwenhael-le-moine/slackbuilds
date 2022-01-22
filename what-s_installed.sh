#!/bin/bash

for cat in a ap d l lua n wayland xap y; do
    cd $cat
    for p in $(ls -1); do
	ls /var/adm/packages/ | grep -q $(echo $p | tr -d /) && echo -n "✓: " || echo -n "❌: "
	echo "$cat/$p"
    done | sort
    cd ..
done
