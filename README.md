xqrepack fork
=========

These scripts allow you to modify the *Xiaomi R3600* firmware image to make sure SSH and UART access is always enabled.

The default root password is `password`. Please remember to login to the router and change that after the upgrade. Your router settings like IP address and SSIDs are stored in the nvram and should stay the same.

⚠ The script also tries its best to remove or disable phone-home binaries, and also the smart controller (AIoT) parts, leaving you with a (close to) OpenWRT router that you can configure via UCI or `/etc/config`.
Between preserving stock functionality and privacy concerns, I would err on the side of caution and rather that some functionality be sacrificed for a router that I have more confidence to connect to the Internet.

Note that in order to get SSH access to the router initially, you need to [downgrade to version 1.0.17 and exploit it first](https://forum.openwrt.org/t/adding-openwrt-support-for-ax3600/55049/123).
Once you have SSH, you can use this repacking method to maintain SSH access for newer versions.

Requirements
==============

You will need to install the following tools:

- [ubi_reader](https://github.com/jrspruitt/ubi_reader)
- ubinize
- unsquashfs / mksquashfs
- fakeroot

Usage
=======

1. Download the firmware(s) from miwifi.com.
   It should be something like `miwifi_r3600_firmware_xxx_yyy.bin`.
   Put it/them to `orig-firmwares` directory.

2. Run `make` to build archives of patched firmwares.
   Parallel build not supported!
   This will build patched images with following naming convention:
   - `<firmware_image_name>+SSH.zip`: patched with original `repack-squashfs.sh` script, which enables SSH and does its best to disable Xiaomi functions/bloatware
   - `<firmware_image_name>+SSH+MI.zip`: enables SSH, but leaves Xiaomi functions intact, only ota predownload is disabled
   - `<firmware_image_name>+SSH+opt.zip`, `<firmware_image_name>+SSH+MI+opt.zip`: same as the respective two above, with additionally `/opt` directory created

3. After extracting a generated archive of your liking, you will get `r3600-raw-img.bin` file.
   Flash this file directly into the router using SSH.
   You cannot use the web UI because this is a raw image, and more importantly has no signature.

   If you are using a recently xqrepack'ed firmware, you can use the `xqflash` utility on the router to flash an update image:

        xqflash /tmp/r3600-raw-img.bin

   After it completes successfully, you should be able to `reboot`.

   If the `xqflash` utility is not available, you can manually flash the update image described in the following section.


Manual Flashing
================

The R3600 firmware uses an A/B partition system, called `rootfs` and `rootfs_1`. This corresponds to `mtd12` and `mtd13`. Find the partition that is not the one in use and use `ubiformat` to write the raw image onto the partition:

    ubiformat /dev/mtd12 -f /tmp/r3600-raw-img.bin -s 2048 -O 2048

Set the nvram variable to re-initialize `/etc` (and I think to switch partitions also):

    nvram set flag_ota_reboot=1
    nvram commit
    reboot


A/B Partitions
===============

You can check the MTD partitions from `/proc/mtd`:

```
root@XiaoQiang:~# grep rootfs /proc/mtd
mtd12: 023c0000 00020000 "rootfs"
mtd13: 023c0000 00020000 "rootfs_1"
mtd17: 015cc000 0001f000 "ubi_rootfs"

root@XiaoQiang:~# nvram get flag_boot_rootfs
1
```

The `flag_boot_rootfs` nvram variable indicates which partition is booted, `0` or `1`.
You should pick the partition that is **not in use**, otherwise `ubiformat` will complain:

    ubiformat: error!: please, first detach mtd13 (/dev/mtd13) from ubi0


License
=========

**xqrepack** is licensed under **the 3-clause ("modified") BSD License**.

Copyright (C) 2020-2021 Darell Tan, 2021 Alex Potapenko

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of the author may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

