#!/bin/sh

CONFIG_DIR=~/.x49gp/

mkdir -p $CONFIG_DIR

cp /usr/doc/x49gp/{flash-50g,sdcard,sram,s3c2410-sram,config} $CONFIG_DIR

sed -i "s|filename=flash-50g|filename=$CONFIG_DIR/flash-50g|" $CONFIG_DIR/config
sed -i "s|filename=sram|filename=$CONFIG_DIR/sram|" $CONFIG_DIR/config
sed -i "s|filename=s3c2410-sram|filename=$CONFIG_DIR/s3c2410-sram|" $CONFIG_DIR/config
sed -i "s|filename=sdcard.dmg|filename=$CONFIG_DIR/sdcard|" $CONFIG_DIR/config
