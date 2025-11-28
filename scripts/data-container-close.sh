#!/usr/bin/env bash

# Close an open data container nicely.

set -e

DATA_CONTAINER_FILE=$HOME/DataContainers/$1

echo "Closing data container $1..."
sudo umount /dev/mapper/$1
sudo cryptsetup close $1
