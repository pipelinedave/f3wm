#!/bin/bash

# Define your encrypted partitions and their intended mount points
declare -A partitions=( ["/dev/nvme0n1p4"]="/backup" ["/dev/nvme0n1p6"]="/secrets" )

# Create options for the dmenu
OPTIONS=""
for part in "${!partitions[@]}"; do
    MOUNT_POINT="${partitions[$part]}"
    # Check if the partition is already mounted using /proc/mounts
    if grep -qs " $MOUNT_POINT " /proc/mounts; then
        OPTIONS+="[mounted] $MOUNT_POINT\n"
    else
        OPTIONS+="[unmounted] $MOUNT_POINT\n"
    fi
done

# Use dmenu to get the user selection
CHOSEN=$(echo -e "$OPTIONS" | dmenu -i -fn 'Source Code Pro-14' -nb '#000000' -nf '#C5C8C6' -sb '#F0C674' -sf '#000000' -p "Select mount point:")

# Parse the selection
STATUS=$(echo "$CHOSEN" | awk '{print $1}' | tr -d '[]')
MOUNT_POINT=$(echo "$CHOSEN" | awk '{print $2}')

# Find the corresponding partition
for part in "${!partitions[@]}"; do
    if [ "${partitions[$part]}" == "$MOUNT_POINT" ]; then
        TARGET_PART=$part
        break
    fi
done

# Act based on the status and selection
if [ -n "$TARGET_PART" ]; then
    MAPPER_NAME=$(basename "$MOUNT_POINT")
    if [ "$STATUS" == "unmounted" ]; then
        # Open the encrypted volume in a new terminal window for password input
        alacritty --class cryptsetuphelper -e bash -c "echo 'Opening $MOUNT_POINT ($TARGET_PART)'; sudo cryptsetup luksOpen $TARGET_PART $MAPPER_NAME; sleep 2"
        # Mount the filesystem
        sudo mount /dev/mapper/$MAPPER_NAME $MOUNT_POINT
        echo "$MOUNT_POINT mounted successfully."
    else
        # Unmount the filesystem and close the LUKS container
        alacritty --class cryptsetup -e bash -c "echo 'Unmounting $MOUNT_POINT ($TARGET_PART)'; sudo umount $MOUNT_POINT; sudo cryptsetup luksClose $MAPPER_NAME; sleep 2"
        echo "$MOUNT_POINT unmounted successfully."
    fi
else
    echo "No selection made."
fi
