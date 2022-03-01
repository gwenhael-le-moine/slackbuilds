#!/bin/bash

for i in $(ls /var/adm/packages/*_gwh ); do
    PRGNAM=$(echo $i | cut -d- -f2) ./generic-python.SlackBuild
done
