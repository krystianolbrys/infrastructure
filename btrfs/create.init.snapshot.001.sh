#!/bin/bash
set -euo pipefail

if [[ -z "${1:-}" ]]; then
    echo "Usage: $0 <block-device>"
    echo "Example: $0 /dev/vda3"
    exit 1
fi

DEVICE="$1"

TMP_MOUNT="/mnt"
ROOT_SUBVOL="@rootfs"
SNAPSHOTS_SUBVOL="@snapshots"

mount_root_subvol() {
    mount -o subvolid=5 "$DEVICE" "$TMP_MOUNT"
}

ensure_dir() {
    local path="$1"
    if [[ ! -d "$path" ]]; then
        mkdir -p "$path"
    fi
}

create_initial_snapshot() {
    local date_str
    date_str=$(date +%d.%m.%Y)

    local snapshot_name="snap.initial.${date_str}"
    local src="${TMP_MOUNT}/${ROOT_SUBVOL}"
    local dst="${TMP_MOUNT}/${SNAPSHOTS_SUBVOL}/${snapshot_name}"

    if [[ -d "$dst" ]]; then
        echo "Snapshot already exists: $snapshot_name"
        return
    fi

    btrfs subvolume snapshot -r "$src" "$dst"
    echo "Created readonly snapshot: $snapshot_name"
}

main() {
    mount_root_subvol

    ensure_dir "$TMP_MOUNT/$ROOT_SUBVOL"
    ensure_dir "$TMP_MOUNT/$SNAPSHOTS_SUBVOL"

    create_initial_snapshot
}

main