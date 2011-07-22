#!/bin/sh

( cd emacs
	./emacs.SlackBuild \
		&& upgradepkg /tmp/emacs-trunk*.t?z \
		&& mv /tmp/emacs-trunk*.t?z /home/installs/PKGs/
)

for i in $(find . -type d -maxdepth 1 -not -name UNUSED -not -name . -not -name emacs); do
    (cd $i
        THIS=$(basename $i)
        sh $THIS.SlackBuild \
            && upgradepkg --install-new /tmp/$THIS*.t?z \
            && mv /tmp/$THIS*.t?z /home/installs/PKGs/
    )
done

rm -fr /tmp/{cyco,emacs-*,package-*,ruby-*}
