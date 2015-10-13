# udev-block-notify - Notify about udev block events

CC	:= gcc
MD	:= markdown
INSTALL	:= install
RM	:= rm
CP	:= cp
CFLAGS	+= -std=c11 -O2 -Wall -Werror
CFLAGS	+= $(shell pkg-config --cflags --libs libudev)
CFLAGS	+= $(shell pkg-config --cflags --libs libnotify)
# this is just a fallback in case you do not use git but downloaded
# a release tarball...
VERSION := 0.7.9

all: udev-block-notify README.html

udev-block-notify: udev-block-notify.c config.h version.h
	$(CC) $(CFLAGS) -o udev-block-notify udev-block-notify.c

config.h: config.def.h
	$(CP) config.def.h config.h

version.h: $(wildcard .git/HEAD .git/index .git/refs/tags/*) Makefile
	echo "#ifndef VERSION" > $@
	echo "#define VERSION \"$(shell git describe --tags --long 2>/dev/null || echo ${VERSION})\"" >> $@
	echo "#endif" >> $@

README.html: README.md
	$(MD) README.md > README.html

install: install-bin install-doc

install-bin: udev-block-notify
	$(INSTALL) -D -m0755 udev-block-notify $(DESTDIR)/usr/bin/udev-block-notify
	$(INSTALL) -D -m0644 systemd/udev-block-notify.service $(DESTDIR)/usr/lib/systemd/user/udev-block-notify.service

install-doc: README.html
	$(INSTALL) -D -m0644 README.md $(DESTDIR)/usr/share/doc/udev-block-notify/README.md
	$(INSTALL) -D -m0644 README.html $(DESTDIR)/usr/share/doc/udev-block-notify/README.html
	$(INSTALL) -D -m0644 screenshots/usb.png $(DESTDIR)/usr/share/doc/udev-block-notify/screenshots/usb.png
	$(INSTALL) -D -m0644 screenshots/optical.png $(DESTDIR)/usr/share/doc/udev-block-notify/screenshots/optical.png

clean:
	$(RM) -f *.o *~ README.html udev-block-notify version.h

distclean:
	$(RM) -f *.o *~ README.html udev-block-notify config.h version.h

release:
	git archive --format=tar.xz --prefix=udev-block-notify-$(VERSION)/ $(VERSION) > udev-block-notify-$(VERSION).tar.xz
	gpg -ab udev-block-notify-$(VERSION).tar.xz
