#!/bin/bash
set -x -e
export MKSQUASHFS_OPTIONS="-b 1048576 -comp xz -Xdict-size 100% -regex -e proc/.* -e sys/.* -e run/.* -e var/lib/apt/lists/.*"
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y live-config live-build gpgv1 gpgv2 xz-utils squashfs-tools
#sed -i 's/^find/#find/g' /usr/lib/live/build/lb_chroot_hacks
mkdir -p /workspace/live/
cd /workspace/live
lb clean --all
lb config \
--distribution jammy \
--parent-distribution jammy \
--bootstrap-flavour standard \
--archive-areas "main universe" \
--parent-archive-areas "main universe" \
--bootstrap debootstrap \
--architecture amd64 \
--parent-mirror-bootstrap "http://us.archive.ubuntu.com/ubuntu/" \
--mirror-bootstrap "http://us.archive.ubuntu.com/ubuntu/" \
--mirror-chroot "http://us.archive.ubuntu.com/ubuntu/" \
--mirror-chroot-security "http://us.archive.ubuntu.com/ubuntu/" \
--mirror-binary "http://us.archive.ubuntu.com/ubuntu/" \
--mirror-binary-security "http://us.archive.ubuntu.com/ubuntu/" \
--initsystem systemd \
--chroot-filesystem squashfs \
--mode ubuntu \
--initramfs live-boot \
--memtest none \
--system live  \
--bootloader none \
--binary-images none \
--apt-recommends false


#--zsync false 


#--apt-source-archives false
#--debian-installer false \
#--firmware-binary false \
#--firmware-chroot false \
#--updates true \
#--bootloader grub \

#lb config \
#	--debootstrap-options "--verbose --variant=minbase --include=gnupg,locales"


echo "user-setup sudo initramfs-tools" > config/package-lists/recommends.list.chroot

lb build
