#!/usr/bin/env bash
set -e

# must be root
if [ "$EUID" -ne 0 ]; then
  echo "ERROR: run as root"
  exit 1
fi

# param check
DEVICE="$1"

if [ -z "$DEVICE" ]; then
  echo "Usage: $0 as block device
  exit 1
fi

if [ ! -b "$DEVICE" ]; then
  echo "ERROR: $DEVICE is not a block device"
  exit 1
fi

# do it
cryptsetup luksFormat "$DEVICE"
