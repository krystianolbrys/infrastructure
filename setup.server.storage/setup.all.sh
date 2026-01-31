#!/usr/bin/env bash
set -e

# must be root
if [ "$EUID" -ne 0 ]; then
  echo "ERROR: run as root"
  exit 1
fi

# args
DEVICE1="$1"
CRYPTNAME1="$2"
DEVICE2="$3"
CRYPTNAME2="$4"

# usage
if [ "$#" -ne 4 ]; then
  echo "Usage:"
  echo "  $0 <device1> <cryptname1> <device2> <cryptname2>"
  echo
  echo "Example:"
  echo "  $0 /dev/vda3 crypt1 /dev/vdb3 crypt2"
  exit 1
fi

# basic validation
for DEV in "$DEVICE1" "$DEVICE2"; do
  if [ ! -b "$DEV" ]; then
    echo "ERROR: $DEV is not a block device"
    exit 1
  fi
done

# run steps
./install.packages.sh

./create.crypt.luks.device.sh "$DEVICE1"
./create.crypt.luks.device.sh "$DEVICE2"

./open.luks.device.sh "$DEVICE1" "$CRYPTNAME1"
./open.luks.device.sh "$DEVICE2" "$CRYPTNAME2"

./create.zfs.pool.sh \
  "/dev/mapper/$CRYPTNAME1" \
  "/dev/mapper/$CRYPTNAME2"
