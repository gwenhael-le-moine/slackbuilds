#!/bin/sh

if [ ! "x$1" == "x--not-emacs" ]; then
	( cd emacs
		./emacs.SlackBuild \
			&& upgradepkg /tmp/emacs-trunk*.t?z \
			&& mv /tmp/emacs-trunk*.t?z /home/installs/PKGs/
	)
fi

for i in $(find . -type d -maxdepth 1 -not -name UNUSED -not -name . -not -name emacs); do
    (cd $i
        THIS=$(basename $i)
        sh $THIS.SlackBuild \
            && upgradepkg /tmp/$THIS*.t?z \
            && mv /tmp/$THIS*.t?z /home/installs/PKGs/
    )
done

rm -fr /tmp/{cyco,emacs-*,package-*,ruby-*}
