#!/bin/bash
#    based on mkusbimg, modified to use syslinux 
#    by Tobias Powalowski <tpowa@archlinux.org>
# 
#    mkusbimg - creates a bootable disk image
#    Copyright (C) 2008  Simo Leone <simo@archlinux.org>
#    
#    makeusbimg - modified mkusbimg, for using partitions
#    Jens Pranaitis <jens@jenux.homelinux.org>#
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# usage(exitvalue)
# outputs a usage message and exits with value
APPNAME=$(basename "${0}")
usage()
{
    echo "usage: ${APPNAME} <imageroot> <imagefile>"
    exit $1
}

##################################################

if [ $# -ne 2 ]; then
    usage 1
fi

DISKIMG="${2}"
IMGROOT="${1}"
TMPDIR=$(mktemp -d)
FSIMG=$(mktemp)

# ext2 overhead's upper bound is 6%
# empirically tested up to 1GB
rootsize=$(du -bs ${IMGROOT}|cut -f1)
IMGSZ=$(( (${rootsize}*102)/100/512 + 1)) # image size in sectors

# create the filesystem image file
dd if=/dev/zero of="$FSIMG" bs=512 count="$IMGSZ"

# create a filesystem on the image
mkfs.vfat -F 16 -S 512 "$FSIMG"

# mount the filesystem and copy data
modprobe loop
mount -o loop "$FSIMG" "$TMPDIR"
cp -r "$IMGROOT"/* "$TMPDIR"

# unmount filesystem
umount "$TMPDIR"
dd if=/dev/zero of="$DISKIMG" bs=512 count=63
cat "$FSIMG" >> "$DISKIMG"
# create a partition table
# if this looks like voodoo, it's because it is
sfdisk -uS -f "$DISKIMG" << EOF
63,$IMGSZ,6,*
0,0,00
0,0,00
0,0,00
EOF

# install syslinux on the image
syslinux -o 32256 "$DISKIMG"
du -hs "$DISKIMG"
# no idea why this is needed, but it is ;)
dd if=/usr/lib/syslinux/mbr.bin of="$DISKIMG" conv=notrunc
# all done :)
rm -fr "$TMPDIR" "$FSIMG"
