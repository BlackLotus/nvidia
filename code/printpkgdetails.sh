#!/bin/bash
PKGBUILDSDIR="/home/jens/build/livecd/pkgbuilds"
getarchver() {
eval $(curl -s "http://repos.archlinux.org/viewvc.cgi/"${pkgname}"/trunk/PKGBUILD?view=co" |egrep '(^pkgver|^pkgrel)')
}
for x in $(find "${PKGBUILDSDIR}" -maxdepth 3 -name PKGBUILD)
do
	source $x
	echo $pkgname:$pkgver-$pkgrel - $url
	getarchver $pkgname
	echo Arch Linux version: $pkgver:$pkgrel
done
