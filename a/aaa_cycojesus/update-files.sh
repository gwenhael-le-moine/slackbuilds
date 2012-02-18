#!/bin/sh

for i in $(find config -type f); do
	cp -a "${i#config}" config/ ;
done
