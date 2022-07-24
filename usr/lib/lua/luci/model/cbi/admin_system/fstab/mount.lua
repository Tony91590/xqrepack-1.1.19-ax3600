local n=require"nixio.fs"
local e=require"nixio.util"
local h=n.access("/usr/sbin/e2fsck")
local s=io.popen("block info","r")
local e,a,t=nil,nil,{}
repeat
e=s:read("*l")
a=e and e:match("^/dev/(.-):")
if a then
local o,i,s,s={}
for t,e in e:gmatch([[(%w+)="(.-)"]])do
o[t:lower()]=e
end
i=tonumber((n.readfile("/sys/class/block/%s/size"%a)))
o.dev="/dev/%s"%a
o.size=i and math.floor(i/2048)
t[#t+1]=o
end
until not e
s:close()
m=Map("fstab",translate("Mount Points - Mount Entry"))
m.redirect=luci.dispatcher.build_url("admin/system/fstab")
if not arg[1]or m.uci:get("fstab",arg[1])~="mount"then
luci.http.redirect(m.redirect)
return
end
mount=m:section(NamedSection,arg[1],"mount",translate("Mount Entry"))
mount.anonymous=true
mount.addremove=false
mount:tab("general",translate("General Settings"))
mount:tab("advanced",translate("Advanced Settings"))
mount:taboption("general",Flag,"enabled",translate("Enable this mount")).rmempty=false
o=mount:taboption("general",Value,"uuid",translate("UUID"),
translate("If specified, mount the device by its UUID instead of a fixed device node"))
o:value("",translate("-- match by uuid --"))
for t,e in ipairs(t)do
if e.uuid and e.size then
o:value(e.uuid,"%s (%s, %d MB)"%{e.uuid,e.dev,e.size})
elseif e.uuid then
o:value(e.uuid,"%s (%s)"%{e.uuid,e.dev})
end
end
o=mount:taboption("general",Value,"label",translate("Label"),
translate("If specified, mount the device by the partition label instead of a fixed device node"))
o:value("",translate("-- match by label --"))
o:depends("uuid","")
for t,e in ipairs(t)do
if e.label and e.size then
o:value(e.label,"%s (%s, %d MB)"%{e.label,e.dev,e.size})
elseif e.label then
o:value(e.label,"%s (%s)"%{e.label,e.dev})
end
end
o=mount:taboption("general",Value,"device",translate("Device"),
translate("The device file of the memory or partition (<abbr title=\"for example\">e.g.</abbr> <code>/dev/sda1</code>)"))
o:value("",translate("-- match by device --"))
o:depends({uuid="",label=""})
for t,e in ipairs(t)do
if e.size then
o:value(e.dev,"%s (%d MB)"%{e.dev,e.size})
else
o:value(e.dev)
end
end
o=mount:taboption("general",Value,"target",translate("Mount point"),
translate("Specifies the directory the device is attached to"))
o:value("/opt",translate("Use as Docker data (/opt)"))
o:value("/",translate("Use as root filesystem (/)"))
o:value("/overlay",translate("Use as external overlay (/overlay)"))
o=mount:taboption("general",DummyValue,"__notice",translate("Root preparation"))
o:depends("target","/")
o.rawhtml=true
o.default=[[
<p>%s</p><pre>mkdir -p /tmp/introot
mkdir -p /tmp/extroot
mount --bind / /tmp/introot
mount /dev/sda1 /tmp/extroot
tar -C /tmp/introot -cvf - . | tar -C /tmp/extroot -xf -
umount /tmp/introot
umount /tmp/extroot</pre>
]]%{
translate("Make sure to clone the root filesystem using something like the commands below:"),
}
o=mount:taboption("advanced",Value,"fstype",translate("Filesystem"),
translate("The filesystem that was used to format the memory (<abbr title=\"for example\">e.g.</abbr> <samp><abbr title=\"Third Extended Filesystem\">ext3</abbr></samp>)"))
o:value("","auto")
local e
for e in io.lines("/proc/filesystems")do
e=e:match("%S+")
if e~="nodev"then
o:value(e)
end
end
o=mount:taboption("advanced",Value,"options",translate("Mount options"),
translate("See \"mount\" manpage for details"))
o.placeholder="defaults"
if h then
o=mount:taboption("advanced",Flag,"enabled_fsck",translate("Run filesystem check"),
translate("Run a filesystem check before mounting the device"))
end
return m
