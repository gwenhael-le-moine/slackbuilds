#!/bin/sh

# "Fix" compilation on a multilib system
export LDFLAGS="-L/usr/lib64 "
