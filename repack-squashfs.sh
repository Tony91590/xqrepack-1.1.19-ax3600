#!/bin/sh
#
# unpack, modify and re-pack the Xiaomi R3600 firmware
# removes checks for release channel before starting dropbear
#
# 2020.07.20  darell tan
# 

IMG=$1
ROOTPW='$1$qtLLI4cm$c0v3yxzYPI46s28rbAYG//'  # "password"

[ -e "$IMG" ] || { echo "rootfs img not found $IMG"; exit 1; }

# verify programs exist
command -v unsquashfs &>/dev/null || { echo "install unsquashfs"; exit 1; }
mksquashfs -version >/dev/null || { echo "install mksquashfs"; exit 1; }

FSDIR=`mktemp -d /tmp/resquash-rootfs.XXXXX`
trap "rm -rf $FSDIR" EXIT

# test mknod privileges
mknod "$FSDIR/foo" c 0 0 2>/dev/null || { echo "need to be run with fakeroot"; exit 1; }
rm -f "$FSDIR/foo"

>&2 echo "unpacking squashfs..."
unsquashfs -f -d "$FSDIR" "$IMG"

>&2 echo "patching squashfs..."

rm -f $FSDIR/etc/*
rm -f $FSDIR/lib/*
rm -f $FSDIR/bin/*
rm -f $FSDIR/data/*
rm -f $FSDIR/ini/*
rm -f $FSDIR/rom/*
rm -f $FSDIR/sbin/*
rm -f $FSDIR/usr/*
rm -f $FSDIR/www/*
rm -f $FSDIR/var/*

cp -R bin/* "$FSDIR/bin/"
cp -R data/* "$FSDIR/data/"
cp -R dev/* "$FSDIR/dev/"
cp -R etc/* "$FSDIR/etc/"
cp -R ini/* "$FSDIR/ini/"
cp -R mnt/* "$FSDIR/mnt/"
cp -R overlay/* "$FSDIR/overlay/"
cp -R proc/* "$FSDIR/proc/"
cp -R rom/* "$FSDIR/rom/"
cp -R usr/* "$FSDIR/usr/"
cp -R www/* "$FSDIR/www/"
cp -R init/* "$FSDIR/init/"
cp -R lib64/* "$FSDIR/lib64/"
cp -R var/* "$FSDIR/var/"








>&2 echo "repacking squashfs..."
rm -f "$IMG.new"
mksquashfs "$FSDIR" "$IMG.new" -comp xz -b 256K -no-xattrs
