#!/bin/sh

for i in $(find config -type f); do
	cp -a "${i#config}" $(dirname $i) ;
done
