#!/bin/bash
# vim: ts=4:sw=4:expandtab

# Copyright (C) 2010 by Andrew Ziem.  All rights reserved.
# License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.
#
# Download and unpack Windows binaries from openSUSE Build Service
#


CACHEDIR=/tmp/gtk-obs/cache/
EXTRACTDIR=/tmp/gtk-obs/extract/

[[ -d "$EXTRACTDIR" ]] && rm -rf $EXTRACTDIR
mkdir -p $EXTRACTDIR

for f in `ls "$CACHEDIR"`
do
    echo "extracting $f"
    cd "$EXTRACTDIR"
    rpm2cpio "$CACHEDIR$f" | cpio -id
done

mv "${EXTRACTDIR}"usr/i686-pc-mingw32/sys-root/mingw/* "$EXTRACTDIR"
rm -rf "${EXTRACTDIR}usr"

echo

echo removing unnecessary
rm -f "${EXTRACTDIR}"bin/*exe
rm -f "${EXTRACTDIR}"bin/*manifest
rm -f "${EXTRACTDIR}"bin/autopoint
rm -f "${EXTRACTDIR}"bin/gettext.sh
rm -f "${EXTRACTDIR}"bin/gettextize
rm -f "${EXTRACTDIR}"bin/gtk-builder-convert
rm -f "${EXTRACTDIR}"bin/libasprintf-0.dll
rm -f "${EXTRACTDIR}"bin/libgettext*dll
rm -rf "${EXTRACTDIR}"etc/fonts/
rm -rf "${EXTRACTDIR}"include/
rm -f "${EXTRACTDIR}"lib/*\.a
rm -rf "${EXTRACTDIR}"lib/gettext/
rm -f lib/gtk-2.0/2.10.0/engines/libpixmap.dll
rm -rf "${EXTRACTDIR}"lib/pango/
rm -rf "${EXTRACTDIR}"share/themes/{Default,Emacs,Raleigh}/
rm -rf "${EXTRACTDIR}"share/{aclocal,doc,gettext,info,man}/


echo

echo striping
# warning: do not strip zlib1.dll or *.pyd
# do not strip (?) sqlite3.dll because of http://bleachbit.sourceforge.net/forum/074-fails-errors
i686-pc-mingw32-strip --preserve-dates "${EXTRACTDIR}"bin/lib*dll
find "${EXTRACTDIR}"lib \( -iname '*dll' -o -iname '*exe' \) -exec i686-pc-mingw32-strip --strip-debug --discard-all --preserve-dates  -v \{\} \+

echo compress UPX
find "${EXTRACTDIR}" \( -iname '*dll' -o -iname '*exe' \) -exec upx --best --crp-ms=999999 --nrv2e \{\} \+

