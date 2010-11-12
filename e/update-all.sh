#!/bin/sh

( cd emacs
	./emacs.SlackBuild
)
upgradepkg /tmp/emacs-trunk*.t?z
mv /tmp/emacs-trunk*.t?z /home/installs/PKGs/

for e in $(find . -type d -maxdepth 1 -not -name UNUSED -not -name . -not -name emacs); do
   (cd $e
      ./$(basename $e).SlackBuild && \
         upgradepkg /tmp/$(basename $e)*.t?z && \
         mv /tmp/$(basename $e)*.t?z /home/installs/PKGs/
    )
done

rm -fr /tmp/{cyco,emacs-*,package-*,ruby-*}
