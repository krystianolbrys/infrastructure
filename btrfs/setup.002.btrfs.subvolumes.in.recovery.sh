#!/bin/bash
set -e

if [[ -z "$1" ]]; then
    echo "Usage: $0 <block-device>"
    echo "Example: $0 /dev/vda3"
    exit 1
fi

DEVICE="$1"

FSTAB_PATH="/etc/fstab"
TMP_MOUNT="/mnt"
DATA_VOLUME_MOUNT_PATH="/data.volume"
SUBVOL_DATA_NAME="data"
SUBVOL_SNAPSHOTS_NAME="snapshots"

mount_root_subvol() {
    mount -o subvolid=5 "$DEVICE" "$TMP_MOUNT"
}

create_subvolume_if_missing() {
    local name="$1"
    if [[ ! -d "$TMP_MOUNT/@$name" ]]; then
        btrfs subvolume create "$TMP_MOUNT/@$name"
        echo "Created subvolume @$name"
    else
        echo "Subvolume @$name already exists"
    fi
}

get_rootfs_uuid() {
    awk '/subvol=@rootfs/ {print $1}' "$FSTAB_PATH" | sed 's/UUID=//'
}

add_fstab_entry_if_missing() {
    local uuid="$1"
    local subvol="$2"
    local mount_point="$3"

    if ! grep -q "subvol=@$subvol" "$FSTAB_PATH"; then
        echo "UUID=$uuid  $mount_point  btrfs  defaults,subvol=@$subvol  0  0" >> "$FSTAB_PATH"
        echo "Added fstab entry for subvol=@$subvol"
    else
        echo "fstab entry for subvol=@$subvol already exists"
    fi
}

prepare_nocow_directories() {
    local dirs=(
        "/var/lib/machines"
        "/var/lib/portables"
    )

    for dir in "${dirs[@]}"; do
        if [[ -e "$dir" ]]; then
            rm -rf "$dir"
            echo "Removed existing $dir"
        fi

        mkdir -p "$dir"
        chattr +C "$dir"
        echo "Prepared nocow directory $dir"
    done
}

main() {
    prepare_nocow_directories
    
    mount_root_subvol

    create_subvolume_if_missing "$SUBVOL_DATA_NAME"
    create_subvolume_if_missing "$SUBVOL_SNAPSHOTS_NAME"

    UUID=$(get_rootfs_uuid)
    if [[ -z "$UUID" ]]; then
        echo "ERROR: UUID for subvol=@rootfs not found"
        exit 1
    fi

    mkdir -p "$DATA_VOLUME_MOUNT_PATH"
    add_fstab_entry_if_missing "$UUID" "$SUBVOL_DATA_NAME" "$DATA_VOLUME_MOUNT_PATH"
}

main
