#!/usr/bin/env bash
# Destroy an existing data container.

set -e

DATA_CONTAINER_FILE=$HOME/DataContainers/$1

if [ -f $DATA_CONTAINER_FILE ]; then
    echo "Destroying data container $1..."
    SIZE_BYTES=$(stat --printf="%s" $DATA_CONTAINER_FILE)
    SIZE_MIB=$(expr $SIZE_BYTES / 1048576)
    dd if=/dev/urandom bs=1M count=$SIZE_MIB conv=notrunc,noerror status=progress of=$DATA_CONTAINER_FILE
    rm $DATA_CONTAINER_FILE

else
    echo "ERROR: Data container doesn't exist: $1"
fi

