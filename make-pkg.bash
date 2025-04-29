#!/bin/bash

# set -e

cd "$(dirname "$0")" || exit 1
CWD=$(pwd)

cd $1 || exit 1
bash -e ./SlackBuild
cd "$CWD" || exit 1
