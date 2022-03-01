#!/bin/bash

WD=/home/installs/SlackBuilds
CAT=${CAT:-$1}

cd $WD
./what-s_installed.sh | grep -v "^❌.*" | cut -d\  -f2 | grep "^$CAT.*"

for p in $(./what-s_installed.sh | grep -v "^❌.*" | cut -d\  -f2 | grep "^$CAT.*"); do
    cd $p
    bash -e ./SlackBuild
    cd $WD
done
