#!/bin/bash

# Define your encrypted partitions and their intended mount points
declare -A partitions=( ["/dev/nvme0n1p4"]="/backup" ["/dev/nvme0n1p6"]="/secrets" )

# Create options for the dmenu
OPTIONS=""
for part in "${!partitions[@]}"; do
    OPTIONS+="${partitions[$part]}\n"
done

# Use dmenu to get the user selection
CHOSEN=$(echo -e "$OPTIONS" | dmenu -i -fn 'Source Code Pro-14' -nb '#000000' -nf '#C5C8C6' -sb '#F0C674' -sf '#000000' -p "Select partition to mount:")

# Get the corresponding partition
for part in "${!partitions[@]}"; do
    if [ "${partitions[$part]}" == "$CHOSEN" ]; then
        TARGET_PART=$part
        break
    fi
done

# If a selection was made (not empty)
if [ -n "$TARGET_PART" ]; then
    # Get the mapper name from the chosen mount point for consistency
    MAPPER_NAME=$(basename "$CHOSEN")
    
    # Open the encrypted volume (cryptsetup will prompt for the passphrase)
    sudo cryptsetup luksOpen $TARGET_PART $MAPPER_NAME

    # Now mount the filesystem
    sudo mount /dev/mapper/$MAPPER_NAME $CHOSEN
    echo "$CHOSEN mounted successfully."
else
    echo "No selection made."
fi
