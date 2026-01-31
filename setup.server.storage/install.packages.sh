#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "Run as root"
  exit 1
fi

echo "Set DEBIAN_FRONTEND=noninteractive ..."
export DEBIAN_FRONTEND=noninteractive

echo "Adding /etc/apt/sources.list.d/trixie-backports.list ..."
echo "deb http://deb.debian.org/debian trixie-backports main contrib non-free-firmware" > /etc/apt/sources.list.d/trixie-backports.list
echo "deb-src http://deb.debian.org/debian trixie-backports main contrib non-free-firmware" >> /etc/apt/sources.list.d/trixie-backports.list

echo "Adding /etc/apt/preferences.d/90_zfs ..."
echo "Package: src:zfs-linux" > /etc/apt/preferences.d/90_zfs
echo "Pin: release n=trixie-backports" >> /etc/apt/preferences.d/90_zfs
echo "Pin-Priority: 990" >> /etc/apt/preferences.d/90_zfs

apt update -y
apt install -y dpkg-dev linux-headers-generic linux-image-generic
apt install -y zfs-dkms zfsutils-linux cryptsetup htop lm-sensors tree unzip xxd
modprobe zfs
