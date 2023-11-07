# netboot

Build netboot/webboot files using live-build tooling. My goal in this project is just to have a reference
on how to build a minimalist netboot image (near 100MB if possible. Currently a tiny bit over but that little
extra does had functionality in the image and a maintained build tools). I kept running into issues with ubuntu's live-build so I've switched to using 
Debian's. This is why packer is configured to use `debian:bookwork` as its container. This caused the image to increase in size some (20-30MB) but I'll
deal with it later.

## What gets built?
* ubuntu 22.04 netboot
  * netplan
    * renderer set to networkd
    * enable any onboard interface (ie en*)
  * systemd
    * systemd-sysv
  * dbus
    * required for systemd to work
  * iproute2
  * less

You can change what you want / need.

## Tools needed to build this
* packer
  * docker
* vagrant
* libvirt

## Build
* run `make`

## Testing
* run `vagrant up`
  * attach to the console (hint use virt-manager or configure serial output)

## TODO
List of things you might still need to address/fix/add/etc...
* locale error. missing /etc/default/locale
* set ntp client and/or servers
* config management
* sshd
* firmware package
  * will 3x size of generated squashfs image
* linux-modules
  * will 4x size of generated squashfs image
* Custom network drives
* Update netplan config
* Modify Vagrantfile to suit your build/test environment
* dmidecode
* ipmi tooling
  * look at freeipmi
