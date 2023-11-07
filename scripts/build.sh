#!/bin/bash
set -x -e
export UBUNTU_MIRROR='http://mirror.us-sc.kamatera.com/ubuntu/'
export IN_IMAGE_UBUNTU_MIRROR='http://us.archive.ubuntu.com/ubuntu/'
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
--archive-areas "main universe" \
--parent-archive-areas "main universe" \
--architecture amd64 \
--parent-mirror-bootstrap $UBUNTU_MIRROR \
--parent-mirror-binary $IN_IMAGE_UBUNTU_MIRROR \
--mirror-bootstrap $UBUNTU_MIRROR \
--mirror-chroot $UBUNTU_MIRROR \
--mirror-chroot-security $UBUNTU_MIRROR \
--mirror-binary $UBUNTU_MIRROR \
--mirror-binary-security $UBUNTU_MIRROR \
--initsystem systemd \
--chroot-filesystem squashfs \
--mode ubuntu \
--initramfs live-boot \
--memtest none \
--system live  \
--binary-image netboot \
--apt-recommends false \
--apt-indices false \
--mode ubuntu \
--updates true \
--linux-packages "linux-image-unsigned-5.15.0-88" \
--linux-flavours "generic"

#--zsync false 


#--bootstrap debootstrap \
#--bootstrap-flavour minimal \
#--apt-source-archives false
#--debian-installer false \
#--firmware-binary false \
#--firmware-chroot false \
#--bootloader grub \

#lb config \
#	--debootstrap-options "--verbose --variant=minbase --include=gnupg,locales"


echo "user-setup sudo initramfs-tools" > config/package-lists/recommends.list.chroot
# if "--bootstrap-flavour minimal" is used, uncomment this. will work packages are missing still.
echo "user-setup sudo initramfs-tools systemd-sysv dbus iproute2 netplan.io less locales" > config/package-lists/recommends.list.chroot
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
      dhcp4-overrides:
        use-hostname: true
EOF
chmod 600 config/includes.chroot/etc/netplan/00-default.yaml

gpg --keyid-format long --keyserver hkp://keyserver.ubuntu.com --recv-keys 0x871920D1991BC93C
gpg --export 871920D1991BC93C > /usr/share/keyrings/ubuntu-archive-keyring.gpg

lb build
chmod go+r /workspace/live/binary/live/*
mkdir -p /workspace/files/
rsync -rv --delete /workspace/live/binary/live/ /workspace/files/
cp /workspace/live/chroot/boot/*-generic  /workspace/files/
chown --reference=/ /workspace/files/
chmod go+r /workspace/files/*-generic
