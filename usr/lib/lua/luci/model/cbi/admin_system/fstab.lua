require("luci.tools.webadmin")
local h=require"nixio.fs"
local t=require"nixio.util"
local a=require"luci.template.parser"
local r=io.popen("block info","r")
local t,i,n=nil,nil,{}
repeat
t=r:read("*l")
i=t and t:match("^/dev/(.-):")
if i then
local e,a,o,o={}
for o,t in t:gmatch([[(%w+)="(.-)"]])do
e[o:lower()]=t
n[t]=e
end
a=tonumber((h.readfile("/sys/class/block/%s/size"%i)))
e.dev="/dev/%s"%i
e.size=a and math.floor(a/2048)
n[e.dev]=e
end
until not t
r:close()
m=Map("fstab",translate("Mount Points"))
s=m:section(TypedSection,"global",translate("Global Settings"))
s.addremove=false
s.anonymous=true
detect=s:option(Button,"block_detect",translate("Generate Config"),translate("Find all currently attached filesystems and swap and replace configuration with defaults based on what was detected"))
detect.inputstyle="reload"
detect.write=function(e,e)
luci.sys.call("block detect >/etc/config/fstab")
luci.http.redirect(luci.dispatcher.build_url("admin/system","fstab"))
end
o=s:option(Flag,"anon_swap",translate("Anonymous Swap"),translate("Mount swap not specifically configured"))
o.default=o.disabled
o.rmempty=false
o=s:option(Flag,"anon_mount",translate("Anonymous Mount"),translate("Mount filesystems not specifically configured"))
o.default=o.disabled
o.rmempty=false
o=s:option(Flag,"auto_swap",translate("Automount Swap"),translate("Automatically mount swap on hotplug"))
o.default=o.enabled
o.rmempty=false
o=s:option(Flag,"auto_mount",translate("Automount Filesystem"),translate("Automatically mount filesystems on hotplug"))
o.default=o.enabled
o.rmempty=false
o=s:option(Flag,"check_fs",translate("Check filesystems before mount"),translate("Automatically check filesystem for errors before mounting"))
o.default=o.disabled
o.rmempty=false
local o=luci.sys.mounts()
local t={}
for a,e in pairs(o)do
if(string.find(e.mountpoint,"/tmp/.jail")==nil)then
repeat
e.umount=false
if(e.mountpoint=="/")then
break
elseif(e.mountpoint=="/overlay")then
break
elseif(e.mountpoint=="/rom")then
break
elseif(e.mountpoint=="/tmp")then
break
elseif(e.mountpoint=="/tmp/shm")then
break
elseif(e.mountpoint=="/tmp/upgrade")then
break
elseif(e.mountpoint=="/dev")then
break
end
e.umount=true
until true
t[a]=e
end
end
v=m:section(Table,t,translate("Mounted file systems"))
h=v:option(DummyValue,"fs",translate("Filesystem"))
mp=v:option(DummyValue,"mountpoint",translate("Mount Point"))
avail=v:option(DummyValue,"avail",translate("Available"))
function avail.cfgvalue(t,e)
return luci.tools.webadmin.byte_format(
(tonumber(o[e].available)or 0)*1024
).." / "..luci.tools.webadmin.byte_format(
(tonumber(o[e].blocks)or 0)*1024
)
end
used=v:option(DummyValue,"used",translate("Used"))
function used.cfgvalue(t,e)
return(o[e].percent or"0%").." ("..
luci.tools.webadmin.byte_format(
(tonumber(o[e].used)or 0)*1024
)..")"
end
unmount=v:option(Button,"unmount",translate("Unmount"))
unmount.render=function(e,a,o)
if t[a].umount then
e.title=translate("Unmount")
e.inputstyle="remove"
Button.render(e,a,o)
end
end
unmount.write=function(a,e)
if t[e].umount then
luci.sys.call("/bin/umount '%s'"%luci.util.shellstartsqescape(t[e].mountpoint))
return luci.http.redirect(luci.dispatcher.build_url("admin/system","fstab"))
end
end
mount=m:section(TypedSection,"mount",translate("Mount Points"),translate("Mount Points define at which point a memory device will be attached to the filesystem"))
mount.anonymous=true
mount.addremove=true
mount.template="cbi/tblsection"
mount.extedit=luci.dispatcher.build_url("admin/system/fstab/mount/%s")
mount.create=function(...)
local e=TypedSection.create(...)
if e then
luci.http.redirect(mount.extedit%e)
return
end
end
mount:option(Flag,"enabled",translate("Enabled")).rmempty=false
i=mount:option(DummyValue,"device",translate("Device"))
i.rawhtml=true
i.cfgvalue=function(i,o)
local e,t
e=m.uci:get("fstab",o,"uuid")
t=e and n[e:lower()]
if e and t and t.size then
return"UUID: %s (%s, %d MB)"%{a.pcdata(e),t.dev,t.size}
elseif e and t then
return"UUID: %s (%s)"%{a.pcdata(e),t.dev}
elseif e then
return"UUID: %s (<em>%s</em>)"%{a.pcdata(e),translate("not present")}
end
e=m.uci:get("fstab",o,"label")
t=e and n[e]
if e and t and t.size then
return"Label: %s (%s, %d MB)"%{a.pcdata(e),t.dev,t.size}
elseif e and t then
return"Label: %s (%s)"%{a.pcdata(e),t.dev}
elseif e then
return"Label: %s (<em>%s</em>)"%{a.pcdata(e),translate("not present")}
end
e=Value.cfgvalue(i,o)or"?"
t=e and n[e]
if e and t and t.size then
return"%s (%d MB)"%{a.pcdata(e),t.size}
elseif e and t then
return a.pcdata(e)
elseif e then
return"%s (<em>%s</em>)"%{a.pcdata(e),translate("not present")}
end
end
mp=mount:option(DummyValue,"target",translate("Mount Point"))
mp.cfgvalue=function(t,e)
if m.uci:get("fstab",e,"is_rootfs")=="1"then
return"/overlay"
else
return Value.cfgvalue(t,e)or"?"
end
end
h=mount:option(DummyValue,"fstype",translate("Filesystem"))
h.cfgvalue=function(e,t)
local e,a
e=m.uci:get("fstab",t,"uuid")
e=e and e:lower()or m.uci:get("fstab",t,"label")
e=e or m.uci:get("fstab",t,"device")
a=e and n[e]
return a and a.type or m.uci:get("fstab",t,"fstype")or"?"
end
op=mount:option(DummyValue,"options",translate("Options"))
op.cfgvalue=function(t,e)
return Value.cfgvalue(t,e)or"defaults"
end
rf=mount:option(DummyValue,"is_rootfs",translate("Root"))
rf.cfgvalue=function(t,e)
local e=m.uci:get("fstab",e,"target")
if e=="/"then
return translate("yes")
elseif e=="/overlay"then
return translate("overlay")
else
return translate("no")
end
end
ck=mount:option(DummyValue,"enabled_fsck",translate("Check"))
ck.cfgvalue=function(t,e)
return Value.cfgvalue(t,e)=="1"
and translate("yes")or translate("no")
end
swap=m:section(TypedSection,"swap","SWAP",translate("If your physical memory is insufficient unused data can be temporarily swapped to a swap-device resulting in a higher amount of usable <abbr title=\"Random Access Memory\">RAM</abbr>. Be aware that swapping data is a very slow process as the swap-device cannot be accessed with the high datarates of the <abbr title=\"Random Access Memory\">RAM</abbr>."))
swap.anonymous=true
swap.addremove=true
swap.template="cbi/tblsection"
swap.extedit=luci.dispatcher.build_url("admin/system/fstab/swap/%s")
swap.create=function(...)
local e=TypedSection.create(...)
if e then
luci.http.redirect(swap.extedit%e)
return
end
end
swap:option(Flag,"enabled",translate("Enabled")).rmempty=false
i=swap:option(DummyValue,"device",translate("Device"))
i.cfgvalue=function(o,a)
local t
t=m.uci:get("fstab",a,"uuid")
if t then return"UUID: %s"%t end
t=m.uci:get("fstab",a,"label")
if t then return"Label: %s"%t end
t=Value.cfgvalue(o,a)or"?"
e=t and n[t]
if t and e and e.size then
return"%s (%s MB)"%{t,e.size}
else
return t
end
end
return m
