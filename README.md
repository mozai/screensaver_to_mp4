XScreenSaver to mp4
==========
To spontaneously record the xscreensaver hacks as video
files.  Thx to Albert Veli for giving me a clue, alexgran
for a Debian-bullseye patch, and of course Jamie Zawinski for
[XScreenSaver](https://jwz.org/xscreensaver/).

* remember to disable other screensavers while you're recording
  `xscreensaver-command -exit`
  How to detect it was running, and re-activate it when we're done here?

* which hack?
  Get a list `find /usr/lib/xscreensaver -type f -perm /001`


Prerequisites
-------------
I built it on my Debian workstation; should be easy to find these.

* bash
* ffmpeg
* xdotool & xwininfo
* Xscreensaver by jwz, who'd remind you to compile from 
  the latest sourcecode.


Usage
-----
It's a bash script.

* `record_xscreensaver.sh pong`
  record five minutes (300s) of the pong screensaver
* `duration=3600 record_xscreensaver.sh glmatrix -hexadecimal`
  record one hour (3600s) of the glmatrix screensaver's hex mode


TODO
----

* better way of detecting the XScreenSaver window than assuming
  the window title will always have a particular substring.  Too
  bad `xdotool search --pid` doesn't work.
* something that would work in Mac OSX

