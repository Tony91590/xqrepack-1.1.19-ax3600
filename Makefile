FIRMWARES:=$(shell cd orig-firmwares; ls *.bin | sed 's/\.bin$$//')

FIRMWARE_SLUG?=txpwr

TARGETS_SSH:=$(patsubst %,%+SSH+$(FIRMWARE_SLUG).bin,$(FIRMWARES))
TARGETS:=$(shell echo $(TARGETS_SSH) | sed 's/ /\n/g' | sort)

all: $(TARGETS)

%+SSH+$(FIRMWARE_SLUG).bin: orig-firmwares/%.bin repack-squashfs.sh
	rm -f $@
	-rm -rf ubifs-root/$*.bin
	ubireader_extract_images -w orig-firmwares/$*.bin
	fakeroot -- ./repack-squashfs.sh ubifs-root/$*.bin/img-*_vol-ubi_rootfs.ubifs
	./ubinize.sh ubifs-root/$*.bin/img-*_vol-kernel.ubifs ubifs-root/$*.bin/img-*_vol-ubi_rootfs.ubifs.new \
		$@ $(shell if [ -e ubifs-root/$*.bin/img-*_vol-rootfs_data.ubifs ]; then echo "--data"; fi)

