#!/usr/bin/env bash
set -e

# must be root
if [ "$EUID" -ne 0 ]; then
  echo "ERROR: run as root"
  exit 1
fi

DEVICE="$1"
CRYPT_NAME="$2"

if [ -z "$DEVICE" ] || [ -z "$CRYPT_NAME" ]; then
  echo "Usage: $0 <device> <cryptName>"
  echo "Example: $0 /dev/disk/by-partuuid/abcd-1234 cryptvol1"
  exit 1
fi

if [ ! -b "$DEVICE" ]; then
  echo "ERROR: $DEVICE is not a block device"
  exit 1
fi

cryptsetup open "$DEVICE" "$CRYPT_NAME"
