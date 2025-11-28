#!/usr/bin/env bash
# This script opens the data container and mounts it.

set -e

DATA_CONTAINER_ROOT=$HOME/DataContainers
DATA_CONTAINER_FILE=$DATA_CONTAINER_ROOT/$1
MOUNT_DEV_NODE=/dev/mapper/$1
MOUNT_DIR=/media/$USER/$1

echo "Opening data container $DATA_CONTAINER_FIRE..."
sudo cryptsetup open $DATA_CONTAINER_FILE $1
sudo mkdir -p $MOUNT_DIR
sudo mount $MOUNT_DEV_NODE $MOUNT_DIR
