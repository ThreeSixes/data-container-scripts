# data-container-scripts

Create LUKS-encrypted files that mount as volumes on Linux systems.

## Background

These scripts are designed to make management of enrypted filesystems stored on-disk easier to work with. The conecept is that each individual `data container` allows a user to add additional protection to files on a local system using LUKS encryption and supports encrypting and decrypting data containers using a device such as a Yubikey.

## Requirements

* BASH, but these scripts can be modified to run using any shell easily.
* A linux system with LUKS support.
* The following CLI utilities must be installed:
  * `chown`
  * `chmod`
  * `cryptsetup`
  * `dd`
  * `mkfs.ext4`
  * `luksformat`
  * `sudo`
* The user running the scripts should have the ability to run commands using `sudo`.
* For Yubikey support you need a Yubikey and the `systemd-cryptenroll` utility installed.
  * In order to force the Yubikey to prompt for a pin you might need to change the Yubikey's settings using a command like: `ykman fido config toggle-always-uv`

## Installation

* Clone this repo
* Get the scripts in your `$PATH`:
  * By copying them to a folder already set in your `$PATH`.
  * Add the `scripts` subdirectory of this repo to your `$PATH`.
* Ensure the scripts are executable by running `chmod *.sh` on them.

## Workflow

This portion of the document describes how to interact create and interact with data containers. Scripts that can perform destructive operations have part of the script name capitalized.

### Data container creation

* If you haven't already create a `DataContainer` folder in your home folder. It's recommended that this folder's mode should be set to `700` to allow your user access to the container.
* To create a new data container run the `data-container-create.sh` script with two arguments: the name of the data container you wish to create and a container file size in MiB which should be large enough for files you want to store, LUKS header, and EXT4 filesystem overhead. The name is used by all scripts to identify a specific data container file, is used to create filesystem labels, mapper endpoints under `/dev/mapper/`, and for mountpoint names.
  * You will be repeatedly prompted for the passphrase of the LUKS filesystem. This should be a strong password and will be used to open the data container for use or to configure a Yubikey to decrypt the data.
  * The script will change the ownership of the data container's filesystem to the current user with a mode of `700` at the root of the filesystem.
* All data container files are owned by root with a mode of `600`. This is done to prevent accidental deletion or overwriting of the data containers.

### Opening and closing a data container

* There are two scripts that can be used to open a data container. The first is `data-container-open.sh` which is used to open a data container encrypted using a pasphrase. `data-container-ykopen.sh` is used for volumes that have been locked using a Yubikey. Once a valid credential has been provided the volume should be available under `/media/<current user>/<data container name>/`. Both scripts take a single argument: the name of the data container that you wish to open.
* When you're ready to close the data container use the `data-container-close.sh` script with the data container's name as the only argument. This will unmount the data container's filesystem and close the LUKS-encrypted device.

### Destroying a data container

* A data container can simply be deleted using `rm` or destroyed. Destruction makes it more difficult to recover data from the data container.
* To destroy a data container you can use the `data-container-DESTROY.sh` script with the name of the data container to destroy.

### Using a Yubieky to unlock a data container

* To configure a data container to be unlocked using a Yubikey run the `data-container-YUBIKEY-SETUP.sh` script with the data container's name as the only argument. Unlock the data container with an existing passphrase and then follow the instructions to enroll the Yubikey. If you type a correct passphrase after running the setup that passphrase will be deleted and the Yubikey will be the only way to unlock the data container unless you have made a recovery key or have additional passphrases.

## Theory of operation

During the creation of a data container random bytes from `/dev/urandom` are used to create a file for the data container that is populated with random data. This is meant to make it more difficult for an attacker to determine where the start and end of encrypted data is in the volume. Once the file has been created and populated with random data it's formatted as a LUKS block device with and EXT4 filesystem and is secured with a user-supplied passphrase. The filesystem label for the EXT4 volume is set to the data container's name. The data container file itself is then set to an owner of `root:root` and a mode of `600` to help prevent accidental deletion. The filesystem contained in the file has its root ownership set to the user running the script's username and a mode of `700` is set for the root of the filesystem.

When opening a data container `cryptsetup open` is run against the data container file with the name of the mapped device under `/dev/mapper/` being set to the data container's name. That mapped device is then mounted under `/media/<USER>/<DATA CONTAINER NAME>` to allow the user to access the contents of the data container.

When closing a data container the container's volume is umounted and `cryptsetup close` is run against the data container file to shut down the LUKS device created during the opening process.

When a data container is destroyed the script will overwrite the contents of the data container with random bytes from `/dev/uramdom` and then delete the data container file once it's done. Overwriting the contents of the file with random data destroys the LUKS headers containing encryption keys and all data in the container before the file itself is deleted. This makes it difficult to recover any data from a deleted container.

## Working with data containers using LUKS utilities

Since the data container files are LUKS formatted volumes all the standard cryptsetup and LUKS utilities should work on them. This includes having the ability to manipulate and change passphrases, backing up LUKS headers, creating recovery keys, etc.

## Known limitations

* These scripts don't protect memory.
* Data stored in these volumes may have other copies of it stored in temporary locations on your filesystem by applications handling the data. Whole disk encryption is recommended in addition to data containers.
* These data containers can't protect against the theft of data when containers are open or attacks that encryption keys from memory such as trojans, rootkits, keyloggers, etc. or attacks that can retrieve data from unencrypted or decrypted filesystem slack space.
