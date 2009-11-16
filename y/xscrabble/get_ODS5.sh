#!/bin/sh
########################################################################
# This file is part of get_ODS5.sh.                                    #
# get_ODS5.sh is free software; you can redistribute it and/or modify  #
# it under the terms of the GNU General Public License as published    #
# by the Free Software Foundation; either version 3 of the License, or #
# (at your option) any later version.                                  #
# get_ODS5.sh is distributed in the hope that it will be useful,       #
# but WITHOUT ANY WARRANTY; without even the implied warranty of       #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        #
# GNU General Public License for more details.                         #
# You should have received a copy of the GNU General Public License    #
# along with get_ODS5.sh; if not, write to the Free Software           #
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 #
# USA                                                                  #
# Written and (c) by                                                   #
# Contact <gwenhael.le.moine@gmail.com> for comment & bug reports      #
########################################################################

rm ODS5 ODS5.gz
wget -c http://www.madfix.com/ods/ods5.txt
for i in $(seq 2 15) ; do
    echo "extraction des mots de $i lettres"
	grep "^$(for j in $(seq 1 $i) ; do echo -n "." ; done)$" ods5.txt | sort >> ODS5
done
gzip ODS5
