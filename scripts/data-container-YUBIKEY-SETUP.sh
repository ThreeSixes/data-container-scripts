#!/usr/bin/env bash
# Set a data container up to use a Yubikey to decrypt it. This script will delete your
# existing passphrase.

set -e

DATA_CONTAINER_FILE=$HOME/DataContainers/$1


if [ -f $DATA_CONTAINER_FILE ]; then
    echo "In order to force the use of a PIN you might need to set user verification"
    echo "to 'always' on your Yubikey: ykman fido config toggle-always-uv"
    echo ""
    echo "Setting data container $1 up for Yubikey..."
    echo ""
    echo "#####################################################"
    echo "# WARNING: THE LAST STEP OF THIS SCRIPT WILL DELETE #"
    echo "#          THE PASSPHRASE YOU ENTER!                #"
    echo "#####################################################"
    echo ""
    echo "Current data container status:"
    sudo systemd-cryptenroll $DATA_CONTAINER_FILE

    echo "Yubikeys:"
    sudo systemd-cryptenroll --fido2-device=list

    echo "Adding Yubikey..."
    sudo systemd-cryptenroll --fido2-with-client-pin=yes --fido2-device=auto  $DATA_CONTAINER_FILE

    echo "New status:"
    sudo systemd-cryptenroll $DATA_CONTAINER_FILE

    echo "Deleting existing passphrase..."
    sudo cryptsetup luksRemoveKey $DATA_CONTAINER_FILE

else
    echo "ERROR: Data container doesn't exit."
    exit 1
fi

