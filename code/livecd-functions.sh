makesqfs() {
	mount-chroot
	chroot source /bin/bash --login <<CHROOTED
	sed -i "s/ftp:\/\/localhost\/livecd-pkg/http:\/\/dev-jenux.homelinux.org\/chaox-repo/" /etc/pacman.conf
	depmod -a $(ls /pub/livecd/source/lib/modules/)
	pacman -Q > package.lst
	yes |hwd -u
	localepurge
CHROOTED
	umount-chroot
	mv source/package.lst target/
	bzip2 -f -9 target/package.lst
	cd source
	time mksquashfs . ../target/archlive.sqfs -ef ../exclude -wildcards -noappend -sort ../load.order.new
	sed -i "s/http:\/\/dev-jenux.homelinux.org\/chaox-repo/ftp:\/\/localhost\/livecd-pkg/" etc/pacman.conf
}
makelivecd() {
	mount-chroot
	chroot source /bin/bash --login <<CHROOTED
	mkinitcpio -k $(ls /pub/livecd/source/lib/modules/) -v -g /boot/initramfs -c /etc/mkinitcpio-cdrom.conf
CHROOTED
	umount-chroot
	cp -R /pub/livecd/source/boot/{initramfs,memtest86+,System.map26,vmlinuz26,isolinux} /pub/livecd/target/boot/
	time mkisofs -b boot/isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -iso-level 4 -c boot/isolinux/boot.cat -o /pub/livecd/chaoxcd-$(date +%F-%H-%M).iso -x files /pub/livecd/target/
}
makeliveusb() {
	mount-chroot
        chroot source /bin/bash --login <<CHROOTED
        mkinitcpio -k $(ls /pub/livecd/source/lib/modules) -v -g /boot/initramfs -c /etc/mkinitcpio-usb.conf
CHROOTED
	umount-chroot
        cp -R /pub/livecd/source/boot/isolinux /pub/livecd/target/boot/syslinux
	cp -R /pub/livecd/source/boot/{initramfs,memtest86+,System.map26,vmlinuz26} /pub/livecd/target/boot/
	modprobe loop
	# archboot script from git, adjust path
	/home/jens/downloads/usr_bin_archboot-usbimage-helper.sh /pub/livecd/target /pub/livecd/chaoxusb-$(date +%F-%H-%M).img
}	
mount-chroot() {
	cd /pub/livecd
	mount -o bind /dev/ /pub/livecd/source/dev/
	mount -o bind /var/cache/pacman/pkg /pub/livecd/source/var/cache/pacman/pkg
	mount -o bind /sys /pub/livecd/source/sys
	mount -t proc none /pub/livecd/source/proc
}
umount-chroot() {
        cd /pub/livecd
        umount /pub/livecd/source/dev/
        umount /pub/livecd/source/var/cache/pacman/pkg
        umount /pub/livecd/source/proc
	umount /pub/livecd/source/sys
	if mount |grep -q /pub/livecd/source
	then
		echo "umount failed"
		return 1
	fi
}

