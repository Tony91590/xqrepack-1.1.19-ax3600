local a=luci.model.network
local e,e
for t,e in ipairs({"6in4","6to4","6rd"})do
local t=a:register_protocol(e)
function t.get_i18n(t)
if e=="6in4"then
return luci.i18n.translate("IPv6-in-IPv4 (RFC4213)")
elseif e=="6to4"then
return luci.i18n.translate("IPv6-over-IPv4 (6to4)")
elseif e=="6rd"then
return luci.i18n.translate("IPv6-over-IPv4 (6rd)")
end
end
function t.ifname(t)
return e.."-"..t.sid
end
function t.opkg_package(t)
return e
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
a:register_pattern_virtual("^%s%%-%%w"%e)
end
