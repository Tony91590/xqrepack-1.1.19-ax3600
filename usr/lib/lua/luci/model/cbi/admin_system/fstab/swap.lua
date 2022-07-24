local t=require"nixio.fs"
local a=require"nixio.util"
local e={}
a.consume((t.glob("/dev/sd*")),e)
a.consume((t.glob("/dev/hd*")),e)
a.consume((t.glob("/dev/scd*")),e)
a.consume((t.glob("/dev/mmc*")),e)
local a={}
for e,o in ipairs(e)do
local e=tonumber((t.readfile("/sys/class/block/%s/size"%o:sub(6))))
a[o]=e and math.floor(e/2048)
end
m=Map("fstab",translate("Mount Points - Swap Entry"))
m.redirect=luci.dispatcher.build_url("admin/system/fstab")
if not arg[1]or m.uci:get("fstab",arg[1])~="swap"then
luci.http.redirect(m.redirect)
return
end
mount=m:section(NamedSection,arg[1],"swap",translate("Swap Entry"))
mount.anonymous=true
mount.addremove=false
mount:tab("general",translate("General Settings"))
mount:tab("advanced",translate("Advanced Settings"))
mount:taboption("general",Flag,"enabled",translate("Enable this swap")).rmempty=false
o=mount:taboption("general",Value,"device",translate("Device"),
translate("The device file of the memory or partition (<abbr title=\"for example\">e.g.</abbr> <code>/dev/sda1</code>)"))
for t,e in ipairs(e)do
o:value(e,a[e]and"%s (%s MB)"%{e,a[e]})
end
o=mount:taboption("advanced",Value,"uuid",translate("UUID"),
translate("If specified, mount the device by its UUID instead of a fixed device node"))
o=mount:taboption("advanced",Value,"label",translate("Label"),
translate("If specified, mount the device by the partition label instead of a fixed device node"))
return m
