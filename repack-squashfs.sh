#!/usr/bin/env bash
#
# unpack, modify and re-pack the Xiaomi R3600 firmware
# removes checks for release channel before starting dropbear
#
# 2020.07.20  darell tan
# 

set -e

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

# create /opt dir
mkdir "$FSDIR/opt"
chmod 755 "$FSDIR/opt"

# modify dropbear init
sed -i 's/channel=.*/channel=release2/' "$FSDIR/etc/init.d/dropbear"
sed -i 's/flg_ssh=.*/flg_ssh=1/' "$FSDIR/etc/init.d/dropbear"

# mark web footer so that users can confirm the right version has been flashed
sed -i 's/romVersion%>/& xqrepack/;' "$FSDIR/usr/lib/lua/luci/view/web/inc/footer.htm"

# stop resetting root password
sed -i '/set_user(/a return 0' "$FSDIR/etc/init.d/system"

# make sure our backdoors are always enabled by default
sed -i '/ssh_en/d;' "$FSDIR/usr/share/xiaoqiang/xiaoqiang-reserved.txt"
sed -i '/ssh_en=/d; /uart_en=/d; /boot_wait=/d;' "$FSDIR/usr/share/xiaoqiang/xiaoqiang-defaults.txt"
cat <<XQDEF >> "$FSDIR/usr/share/xiaoqiang/xiaoqiang-defaults.txt"
uart_en=1
ssh_en=1
boot_wait=on
XQDEF

# always reset our access nvram variables
grep -q -w enable_dev_access "$FSDIR/lib/preinit/31_restore_nvram" || \
 cat <<NVRAM >> "$FSDIR/lib/preinit/31_restore_nvram"
enable_dev_access() {
	nvram set uart_en=1
	nvram set ssh_en=1
	nvram set boot_wait=on
	nvram commit
}

boot_hook_add preinit_main enable_dev_access
NVRAM

# modify root password
sed -i "s@root:[^:]*@root:${ROOTPW}@" "$FSDIR/etc/shadow"

# stop phone-home in web UI
cat <<JS >> "$FSDIR/www/js/miwifi-monitor.js"
(function(){ if (typeof window.MIWIFI_MONITOR !== "undefined") window.MIWIFI_MONITOR.log = function(a,b) {}; })();
JS

# add xqflash tool into firmware for easy upgrades
cp xqflash "$FSDIR/sbin"
chmod 0755      "$FSDIR/sbin/xqflash"
chown root:root "$FSDIR/sbin/xqflash"

# dont start crap services
for SVC in stat_points statisticsservice \
		datacenter \
		xq_info_sync_mqtt \
		xiaoqiang_sync \
		plugincenter plugin_start_script.sh cp_preinstall_plugins.sh; do
	rm -f $FSDIR/etc/rc.d/[SK]*$SVC
done

# prevent stats phone home & auto-update
for f in StatPoints mtd_crash_log logupload.lua otapredownload; do > $FSDIR/usr/sbin/$f; done

sed -i '/start_service(/a return 0' $FSDIR/etc/init.d/messagingagent.sh

# cron jobs are mostly non-OpenWRT stuff
for f in $FSDIR/etc/crontabs/*; do
	sed -i 's/^/#/' $f
done

# as a last-ditch effort, change the *.miwifi.com hostnames to localhost
sed -i 's@\w\+.miwifi.com@localhost@g' $FSDIR/etc/config/miwifi

# apply patch from xqrepack repository
find patches -type f -exec bash -c "(cd "$FSDIR" && patch -p1) < {}" \;
find patches -type f -name \*.orig -delete

# copy the latest firmware of wifi
cp -R lib/* "$FSDIR/lib/"

>&2 echo "repacking squashfs..."
rm -f "$IMG.new"
mksquashfs "$FSDIR" "$IMG.new" -comp xz -b 256K -no-xattrs
