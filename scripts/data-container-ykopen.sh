#!/usr/bin/env bash
# This script opens the data container and mounts it using a Yubikey.

set -e

DATA_CONTAINER_FILE=$HOME/DataContainers/$1
MOUNT_DEV_NODE=/dev/mapper/$1
MOUNT_DIR=/media/$USER/$1

echo "Opening data container w/yubkey: $DATA_CONTAINER_FILE..."
sudo cryptsetup open $DATA_CONTAINER_FILE $1 --token-only
sudo mkdir -p $MOUNT_DIR
sudo mount $MOUNT_DEV_NODE $MOUNT_DIR
