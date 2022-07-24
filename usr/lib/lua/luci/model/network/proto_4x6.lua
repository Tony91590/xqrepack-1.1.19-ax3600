local a=luci.model.network
local e,e
for t,e in ipairs({"dslite","map","464xlat"})do
local t=a:register_protocol(e)
function t.get_i18n(t)
if e=="dslite"then
return luci.i18n.translate("Dual-Stack Lite (RFC6333)")
elseif e=="map"then
return luci.i18n.translate("MAP / LW4over6")
elseif e=="464xlat"then
return luci.i18n.translate("464XLAT (CLAT)")
end
end
function t.ifname(t)
return e.."-"..t.sid
end
function t.opkg_package(t)
if e=="dslite"then
return"ds-lite"
elseif e=="map"then
return"map-t"
elseif e=="464xlat"then
return"464xlat"
end
end
function t.is_installed(t)
return nixio.fs.access("/lib/netifd/proto/"..e..".sh")
end
function t.is_floating(e)
return true
end
function t.is_virtual(e)
return true
end
function t.get_interfaces(e)
return nil
end
function t.contains_interface(e,t)
return(a:ifnameof(ifc)==e:ifname())
end
if e=="dslite"then
a:register_pattern_virtual("^ds%-%w")
elseif e=="map"then
a:register_pattern_virtual("^map%-%w")
elseif e=="464xlat"then
a:register_pattern_virtual("^464%-%w")
end
end
