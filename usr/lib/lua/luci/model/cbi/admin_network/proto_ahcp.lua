local e,e,e=...
local e,e,e,e,e,e
local e,e,e,e,e,e,
e,e,e
mca=s:taboption("ahcp",Value,"multicast_address",translate("Multicast address"))
mca.optional=true
mca.placeholder="ff02::cca6:c0f9:e182:5359"
mca.datatype="ip6addr"
mca:depends("proto","ahcp")
port=s:taboption("ahcp",Value,"port",translate("Port"))
port.optional=true
port.placeholder=5359
port.datatype="port"
port:depends("proto","ahcp")
fam=s:taboption("ahcp",ListValue,"_family",translate("Protocol family"))
fam:value("",translate("IPv4 and IPv6"))
fam:value("ipv4",translate("IPv4 only"))
fam:value("ipv6",translate("IPv6 only"))
fam:depends("proto","ahcp")
function fam.cfgvalue(t,e)
local t=m.uci:get_bool("network",e,"ipv4_only")
local e=m.uci:get_bool("network",e,"ipv6_only")
if t then
return"ipv4"
elseif e then
return"ipv6"
end
return""
end
function fam.write(a,e,t)
if t=="ipv4"then
m.uci:set("network",e,"ipv4_only","true")
m.uci:delete("network",e,"ipv6_only")
elseif t=="ipv6"then
m.uci:set("network",e,"ipv6_only","true")
m.uci:delete("network",e,"ipv4_only")
end
end
function fam.remove(t,e)
m.uci:delete("network",e,"ipv4_only")
m.uci:delete("network",e,"ipv6_only")
end
nodns=s:taboption("ahcp",Flag,"no_dns",translate("Disable DNS setup"))
nodns.optional=true
nodns.enabled="true"
nodns.disabled="false"
nodns.default=nodns.disabled
nodns:depends("proto","ahcp")
ltime=s:taboption("ahcp",Value,"lease_time",translate("Lease validity time"))
ltime.optional=true
ltime.placeholder=3666
ltime.datatype="uinteger"
ltime:depends("proto","ahcp")
