FIRMWARES:=$(shell cd orig-firmwares; ls *.bin | sed 's/\.bin$$//')

FIRMWARE_SLUG?=txpwr

TARGETS_SSH_MI:=$(patsubst %,%+SSH+MI+$(FIRMWARE_SLUG).bin,$(FIRMWARES))
TARGETS:=$(shell echo $(TARGETS_SSH_MI) | sed 's/ /\n/g' | sort)

all: $(TARGETS)

%+SSH+MI+$(FIRMWARE_SLUG).bin: orig-firmwares/%.bin repack-squashfs-mi.sh
	rm -f $@
	-rm -rf ubifs-root/$*.bin
	ubireader_extract_images -w orig-firmwares/$*.bin
	fakeroot -- ./repack-squashfs-mi.sh ubifs-root/$*.bin/img-*_vol-ubi_rootfs.ubifs
	./ubinize.sh ubifs-root/$*.bin/img-*_vol-kernel.ubifs ubifs-root/$*.bin/img-*_vol-ubi_rootfs.ubifs.new \
		$@ $(shell if [ -e ubifs-root/$*.bin/img-*_vol-rootfs_data.ubifs ]; then echo "--data"; fi)

