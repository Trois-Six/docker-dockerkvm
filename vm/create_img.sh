#!/bin/bash

NAME=kvm
PKGS=udev,linux-image-amd64
DISTRIB=buster
#APT_CACHER=http://127.0.0.1:3142
APT_CACHER=-
APT_MIRROR=httpredir.debian.org/debian/


#
# Function used to cleanup attached devices and mount at the end of the script or thank's to trap
#

function cleanup() {
    if [ -n ${TMP_DIR} ]; then
        umount ${TMP_DIR}/proc 2>/dev/null
        umount ${TMP_DIR}/sys 2>/dev/null
        rm -rf ${TMP_DIR}
    fi
    if [ ! $1 ]; then
        rm -f ${NAME}.img ${NAME}.vmlinuz ${NAME}.initrd ${NAME}.qcow2
        exit 3
    fi
}

trap cleanup INT


#
# Only root can do this
#

if [ $(id -u) -gt 0 ]; then
    echo "You must be root to execute this script"
    exit 1
fi


#
# Create temporary folder and empty qcow2 file
#

qemu-img create -f raw ${NAME}.img 10000000000
mkfs -t ext4 ${NAME}.img
qemu-img convert -O qcow2 -c ${NAME}.img ${NAME}.qcow2
rm -f ${NAME}.img
TMP_DIR=$(mktemp -d /tmp/tmpXXXXX)
if [ ! -d ${TMP_DIR} ]; then
     echo "Error: could not create temporary folder"
     exit 2
fi


#
# Debootstrap and post_create script
#

if [ "x${APT_CACHER}" != "x-" ]; then
	debootstrap --arch=amd64 --include=${PKGS} --variant=minbase ${DISTRIB} ${TMP_DIR} ${APT_CACHER}/${APT_MIRROR}
else
	debootstrap --arch=amd64 --include=${PKGS} --variant=minbase ${DISTRIB} ${TMP_DIR} http://${APT_MIRROR}
fi
cp post_create.sh ${TMP_DIR}/usr/local/bin/post_create.sh
PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' chroot ${TMP_DIR} /bin/sh /usr/local/bin/post_create.sh ${APT_CACHER} ${DISTRIB}


#
# Copy kernel and initrd locally
#

mv ${TMP_DIR}/boot/vmlinuz-* ${NAME}.vmlinuz
mv ${TMP_DIR}/boot/initrd.img-* ${NAME}.initrd


#
# Detach devices and umount
#

cleanup ok

