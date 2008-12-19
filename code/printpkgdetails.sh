#!/bin/bash
PKGBUILDSDIR="/home/jens/build/livecd/pkgbuilds"
getarchver() {
pkgver=0
pkgrel=0
eval $(curl -s "http://repos.archlinux.org/viewvc.cgi/"${pkgname}"/trunk/PKGBUILD?view=co" |egrep '(^pkgver|^pkgrel)')
if [[ $pkgver == 0 && $pkgrel == 0 ]]
then
	eval $(curl -s "http://aur.archlinux.org/packages/"${pkgname}"/"${pkgname}"/PKGBUILD" |egrep '(^pkgver|^pkgrel)')
fi
_archpkgver=$pkgver
_archpkgrel=$pkgrel
}
parseargs() {
	case $1 in
		checknew) export checknew=1;;
		checkold) export checkold=1;;
		checksame) export checksame=1;;
		checkall) export checknew=1 && checkold=1 && checksame=1;;
	esac
}
if [ "$1" ]
then
	parseargs $1
	for x in $(find "${PKGBUILDSDIR}" -maxdepth 3 -name PKGBUILD)
	do
		source $x
		_chaoxpkgver=$pkgver
		_chaoxpkgrel=$pkgrel
		getarchver $pkgname
		if [[ $pkgver == 0 && $pkgrel == 0 ]]
		then
			echo "$pkgname doesn't exist in arch linux"
		else
			case $(vercmp $_archpkgver-$_archpkgrel $_chaoxpkgver-$_chaoxpkgrel) in
				-1) if [[ $checknew == 1 ]];then echo "$pkgname in chaox newer than in arch linux";fi;;
				0) if [[ $checksame == 1 ]];then echo "$pkgname in chaox same as in arch linux";fi;;
				1) if [[ $checkold == 1 ]];then echo "$pkgname in arch linux newer than in chaox, check $url for the current version, the arch linux version is $_archpkgver-$_archpkgrel";fi;;
			esac
		fi
	done
else
	echo "One of the following arguments has to be supplied: checkall, checknew, checkold, checksame"
fi
