module("luci.controller.admin.system",package.seeall)
function index()
local e=require"nixio.fs"
entry({"admin","system"},alias("admin","system","system"),_("System"),30).index=true
entry({"admin","system","system"},cbi("admin_system/system"),_("System"),1)
entry({"admin","system","clock_status"},post_on({set=true},"action_clock_status"))
entry({"admin","system","admin"},cbi("admin_system/admin"),_("Administration"),2)
if e.access("/bin/opkg")then
entry({"admin","system","packages"},post_on({exec="1"},"action_packages"),_("Software"),10)
entry({"admin","system","packages","ipkg"},form("admin_system/ipkg"))
end
entry({"admin","system","startup"},form("admin_system/startup"),_("Startup"),45)
entry({"admin","system","crontab"},arcombine(cbi("admin_system/crontab"),cbi("admin_system/crontab-details")),_("Scheduled Tasks"),46).leaf=true
if e.access("/sbin/block")and e.access("/etc/config/fstab")then
entry({"admin","system","fstab"},cbi("admin_system/fstab"),_("Mount Points"),50)
entry({"admin","system","fstab","mount"},cbi("admin_system/fstab/mount"),nil).leaf=true
entry({"admin","system","fstab","swap"},cbi("admin_system/fstab/swap"),nil).leaf=true
end
local t,e=nixio.fs.glob("/sys/class/leds/*")
if e>0 then
entry({"admin","system","leds"},cbi("admin_system/leds"),_("<abbr title=\"Light Emitting Diode\">LED</abbr> Configuration"),60)
end
entry({"admin","system","flashops"},call("action_flashops"),_("Backup / Flash Firmware"),70)
entry({"admin","system","flashops","reset"},post("action_reset"))
entry({"admin","system","flashops","backup"},post("action_backup"))
entry({"admin","system","flashops","backupmtdblock"},post("action_backupmtdblock"))
entry({"admin","system","flashops","backupfiles"},form("admin_system/backupfiles"))
entry({"admin","system","flashops","restore"},call("action_restore"))
entry({"admin","system","flashops","sysupgrade"},call("action_sysupgrade"))
entry({"admin","system","reboot"},template("admin_system/reboot"),_("Reboot"),90)
entry({"admin","system","reboot","call"},post("action_reboot"))
end
function action_clock_status()
local e=tonumber(luci.http.formvalue("set"))
if e~=nil and e>0 then
local e=os.date("*t",e)
if e then
luci.sys.call("date -s '%04d-%02d-%02d %02d:%02d:%02d'"%{
e.year,e.month,e.day,e.hour,e.min,e.sec
})
luci.sys.call("/etc/init.d/sysfixtime restart")
end
end
luci.http.prepare_content("application/json")
luci.http.write_json({timestring=os.date("%c")})
end
function action_packages()
local d=require"nixio.fs"
local n=require"luci.model.ipkg"
local f=(luci.http.formvalue("exec")=="1")
local l,h
local s=false
local u={}
local c={}
local e={""}
local t={""}
local a,o
local m=luci.http.formvalue("display")or"installed"
local i=string.byte(luci.http.formvalue("letter")or"A",1)
i=(i==35 or(i>=65 and i<=90))and i or 65
local r=luci.http.formvalue("query")
r=(r~='')and r or nil
if f then
local r=luci.http.formvalue("install")
local i=nil
local d=luci.http.formvalue("url")
if d and d~=''then
i=d
end
if r then
u[r],a,o=n.install(r)
e[#e+1]=a
t[#t+1]=o
s=true
end
if i then
local h
for h in luci.util.imatch(i)do
u[i],a,o=n.install(h)
e[#e+1]=a
t[#t+1]=o
s=true
end
end
local i=luci.http.formvalue("remove")
if i then
c[i],a,o=n.remove(i)
e[#e+1]=a
t[#t+1]=o
s=true
end
l=luci.http.formvalue("update")
if l then
l,a,o=n.update()
e[#e+1]=a
t[#t+1]=o
end
h=luci.http.formvalue("upgrade")
if h then
h,a,o=n.upgrade()
e[#e+1]=a
t[#t+1]=o
end
end
local o=true
local a=false
if d.access("/var/opkg-lists/")then
local e
for e in d.dir("/var/opkg-lists/")do
o=false
if(d.stat("/var/opkg-lists/"..e,"mtime")or 0)<(os.time()-(24*60*60))then
a=true
break
end
end
end
luci.template.render("admin_system/packages",{
display=m,
letter=i,
query=r,
install=u,
remove=c,
update=l,
upgrade=h,
no_lists=o,
old_lists=a,
stdout=table.concat(e,""),
stderr=table.concat(t,"")
})
if s then
d.unlink("/tmp/luci-indexcache")
end
end
local function s(e)
return(os.execute("sysupgrade -T %q >/dev/null"%e)==0)
end
local function h(e)
return(luci.sys.exec("md5sum %q"%e):match("^([^%s]+)"))
end
local function r(e)
return(luci.sys.exec("sha256sum %q"%e):match("^([^%s]+)"))
end
local function n()
return nixio.fs.access("/lib/upgrade/platform.sh")
end
local function i()
return(os.execute([[grep -sq "^overlayfs:/overlay / overlay " /proc/mounts]])==0)
end
local function d()
local e=0
if nixio.fs.access("/proc/mtd")then
for t in io.lines("/proc/mtd")do
local o,a,o,t=t:match('^([^%s]+)%s+([^%s]+)%s+([^%s]+)%s+"([^%s]+)"')
if t=="linux"or t=="firmware"then
e=tonumber(a,16)
break
end
end
elseif nixio.fs.access("/proc/partitions")then
for t in io.lines("/proc/partitions")do
local o,o,a,t=t:match('^%s*(%d+)%s+(%d+)%s+([^%s]+)%s+([^%s]+)')
if a and t and not t:match('[0-9]')then
e=tonumber(a)*1024
break
end
end
end
return e
end
function action_flashops()
luci.template.render("admin_system/flashops",{
reset_avail=i(),
upgrade_avail=n()
})
end
function action_sysupgrade()
local o=require"nixio.fs"
local t=require"luci.http"
local e="/tmp/firmware.img"
local a
t.setfilehandler(
function(o,t,i)
if not a and o and o.name=="image"then
a=io.open(e,"w")
end
if a and t then
a:write(t)
end
if a and i then
a:close()
end
end
)
if not luci.dispatcher.test_post_security()then
o.unlink(e)
return
end
if t.formvalue("cancel")then
o.unlink(e)
t.redirect(luci.dispatcher.build_url('admin/system/flashops'))
return
end
local a=tonumber(t.formvalue("step")or 1)
if a==1 then
if s(e)then
luci.template.render("admin_system/upgrade",{
checksum=h(e),
sha256ch=r(e),
storage=d(),
size=(o.stat(e,"size")or 0),
keep=(not not t.formvalue("keep"))
})
else
o.unlink(e)
luci.template.render("admin_system/flashops",{
reset_avail=i(),
upgrade_avail=n(),
image_invalid=true
})
end
elseif a==2 then
local t=(t.formvalue("keep")=="1")and""or"-n"
luci.template.render("admin_system/applyreboot",{
title=luci.i18n.translate("Flashing..."),
msg=luci.i18n.translate("The system is flashing now.<br /> DO NOT POWER OFF THE DEVICE!<br /> Wait a few minutes before you try to reconnect. It might be necessary to renew the address of your computer to reach the device again, depending on your settings."),
addr=(#t>0)and"192.168.1.1"or nil
})
fork_exec("sleep 1; killall dropbear uhttpd; sleep 1; /sbin/sysupgrade %s %q"%{t,e})
end
end
function action_backup()
local e=ltn12_popen("sysupgrade --create-backup - 2>/dev/null")
luci.http.header(
'Content-Disposition','attachment; filename="backup-%s-%s.tar.gz"'%{
luci.sys.hostname(),
os.date("%Y-%m-%d")
})
luci.http.prepare_content("application/x-targz")
luci.ltn12.pump.all(e,luci.http.write)
end
function action_backupmtdblock()
local e=require"luci.http"
local e=e.formvalue("mtdblockname")
local e,a,t=e:match('^([^%s]+)/([^%s]+)/([^%s]+)')
local t=ltn12_popen("cat /dev/mtd%s"%t)
luci.http.header(
'Content-Disposition','attachment; filename="backup-%s-%s-%s.bin"'%{
luci.sys.hostname(),e,
os.date("%Y-%m-%d")
})
luci.http.prepare_content("application/octet-stream")
luci.ltn12.pump.all(t,luci.http.write)
end
function action_restore()
local i=require"nixio.fs"
local a=require"luci.http"
local t="/tmp/restore.tar.gz"
local e
a.setfilehandler(
function(a,o,i)
if not e and a and a.name=="archive"then
e=io.open(t,"w")
end
if e and o then
e:write(o)
end
if e and i then
e:close()
end
end
)
if not luci.dispatcher.test_post_security()then
i.unlink(t)
return
end
local e=a.formvalue("archive")
if e and#e>0 then
luci.template.render("admin_system/applyreboot")
os.execute("tar -C / -xzf %q >/dev/null 2>&1"%t)
luci.sys.reboot()
return
end
a.redirect(luci.dispatcher.build_url('admin/system/flashops'))
end
function action_reset()
if i()then
luci.template.render("admin_system/applyreboot",{
title=luci.i18n.translate("Erasing..."),
msg=luci.i18n.translate("The system is erasing the configuration partition now and will reboot itself when finished."),
addr="192.168.1.1"
})
fork_exec("sleep 1; killall dropbear uhttpd; sleep 1; jffs2reset -y && reboot")
return
end
http.redirect(luci.dispatcher.build_url('admin/system/flashops'))
end
function action_passwd()
local t=luci.http.formvalue("pwd1")
local a=luci.http.formvalue("pwd2")
local e=nil
if t or a then
if t==a then
e=luci.sys.user.setpasswd("root",t)
else
e=10
end
end
luci.template.render("admin_system/passwd",{stat=e})
end
function action_reboot()
luci.sys.reboot()
end
function fork_exec(t)
local e=nixio.fork()
if e>0 then
return
elseif e==0 then
nixio.chdir("/")
local e=nixio.open("/dev/null","w+")
if e then
nixio.dup(e,nixio.stderr)
nixio.dup(e,nixio.stdout)
nixio.dup(e,nixio.stdin)
if e:fileno()>2 then
e:close()
end
end
nixio.exec("/bin/sh","-c",t)
end
end
function ltn12_popen(i)
local a,t=nixio.pipe()
local e=nixio.fork()
if e>0 then
t:close()
local t
return function()
local o=a:read(2048)
local i,e=nixio.waitpid(e,"nohang")
if not t and i and e=="exited"then
t=true
end
if o and#o>0 then
return o
elseif t then
a:close()
return nil
end
end
elseif e==0 then
nixio.dup(t,nixio.stdout)
a:close()
t:close()
nixio.exec("/bin/sh","-c",i)
end
end
