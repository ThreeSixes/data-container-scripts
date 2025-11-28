#!/usr/bin/env bash
# Create a new data container. The files are owned by root with a mode of
# 600 to prevent accidental deleiton or overriding.

set -e

DATA_CONTAINER_FILE=$HOME/DataContainers/$1

if [ -f $DATA_CONTAINER_FILE ]; then
    echo "ERROR: Data container already exits."
    exit 1
fi

echo "Creating data container $1 in $DATA_CONTAINER_FIRE with size $2 MiB."
sudo dd if=/dev/urandom bs=1M count=$2 status=progress of=$DATA_CONTAINER_FILE

echo "Change data container file's owner to root and mode to 600..."
sudo chown root:root $DATA_CONTAINER_FILE
sudo chmod 600 $DATA_CONTAINER_FILE

echo "Setting up LUKS encryption on container and formatting as EXT4..."
echo "NOTE: You will create a passphrase for the data container here."
sudo luksformat -t ext4 $DATA_CONTAINER_FILE -L $1

echo "Re-opening the new data container..."
data-container-open.sh $1

echo "Changing owner of the data container filesystem $1 to $USER:$USER with 700 mode..."
sudo chown -R $USER:$USER /media/$USER/$1
sudo chmod -R 700 /media/$USER/$1

echo "Finalizing data container $1..."
data-container-close.sh $1
