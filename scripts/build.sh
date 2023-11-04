#!/bin/bash
set -x -e
export MKSQUASHFS_OPTIONS="-b 1048576 -comp xz -Xdict-size 100% -regex -e proc/.* -e sys/.* -e run/.* -e var/lib/apt/lists/.*"
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y live-config live-build gpgv1 gpgv2 xz-utils squashfs-tools
#sed -i 's/^find/#find/g' /usr/lib/live/build/lb_chroot_hacks

rm -rf /workspace/live/
mkdir /workspace/live/
chown --reference=/workspace /workspace/live/
cd /workspace/live
lb clean --all
lb config \
--distribution jammy \
--parent-distribution jammy \
--bootstrap-flavour minimal \
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
--apt-recommends false \
--apt-indices false \
--linux-packages "linux-image-5.15.0-88"

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
# if "--bootstrap-flavour minimal" is used, uncomment this. will work packages are missing still.
echo "user-setup sudo initramfs-tools systemd-sysv dbus iproute2 netplan.io less" > config/package-lists/recommends.list.chroot
mkdir -p config/includes.chroot/etc/netplan
cat << EOF > config/includes.chroot/etc/netplan/00-default.yaml
network:
  version: 2
  ethernets:
    all-eth:
      match:
        name: "en*"
      dhcp4: yes
      dhcp6: yes
EOF


lb build
chmod go+r /workspace/live/binary/live/*
