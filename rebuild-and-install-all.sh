#!/bin/bash

WD=/home/installs/SlackBuilds
CAT=${CAT:-$1}
for p in $(./what-s_installed.sh | grep -v "^❌.*" | cut -d\  -f2 | grep "^$CAT.*"); do
    cd $p
    echo -n "$p : "
    ls
    ./SlackBuild
    cd $WD
done
