local e="/etc/opkg.conf"
local o="/etc/opkg/distfeeds.conf"
local a="/etc/opkg/customfeeds.conf"
f=SimpleForm("ipkgconf",translate("OPKG-Configuration"),translate("General options for opkg"))
f:append(Template("admin_system/ipkg"))
t=f:field(TextValue,"lines")
t.wrap="off"
t.rows=10
function t.cfgvalue()
return nixio.fs.readfile(e)or""
end
function t.write(a,a,t)
return nixio.fs.writefile(e,t:gsub("\r\n","\n"))
end
function f.handle(e,e,e)
return true
end
g=SimpleForm("distfeedconf",translate("Distribution feeds"),
translate("Build/distribution specific feed definitions. This file will NOT be preserved in any sysupgrade."))
d=g:field(TextValue,"lines2")
d.wrap="off"
d.rows=10
function d.cfgvalue()
return nixio.fs.readfile(o)or""
end
function d.write(t,t,e)
return nixio.fs.writefile(o,e:gsub("\r\n","\n"))
end
function g.handle(e,e,e)
return true
end
h=SimpleForm("customfeedconf",translate("Custom feeds"),
translate("Custom feed definitions, e.g. private feeds. This file can be preserved in a sysupgrade."))
c=h:field(TextValue,"lines3")
c.wrap="off"
c.rows=10
function c.cfgvalue()
return nixio.fs.readfile(a)or""
end
function c.write(t,t,e)
return nixio.fs.writefile(a,e:gsub("\r\n","\n"))
end
function h.handle(e,e,e)
return true
end
return f,g,h
