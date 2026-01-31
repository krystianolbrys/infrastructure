#!/usr/bin/env bash
set -e

# must be root
if [ "$EUID" -ne 0 ]; then
  echo "ERROR: run as root"
  exit 1
fi

DEV1="$1"
DEV2="$2"
POOL_NAME="pool.storage.mirror"

if [ -z "$DEV1" ] || [ -z "$DEV2" ]; then
  echo "Usage: $0 <device1> <device2>"
  echo "Example: $0 /dev/mapper/crypt1 /dev/mapper/crypt2"
  exit 1
fi

if [ ! -b "$DEV1" ]; then
  echo "ERROR: $DEV1 is not a block device"
  exit 1
fi

if [ ! -b "$DEV2" ]; then
  echo "ERROR: $DEV2 is not a block device"
  exit 1
fi

zpool create "$POOL_NAME" mirror "$DEV1" "$DEV2"
