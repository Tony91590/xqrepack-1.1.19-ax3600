local a,e,t=...
local u=t:get_interface()
local l,t,d,r,h,o,o,n,a
local o,i
l=e:taboption("general",Value,"ipaddr",translate("IPv4 address"))
l.datatype="ip4addr"
t=e:taboption("general",Value,"netmask",
translate("IPv4 netmask"))
t.datatype="ip4addr"
t:value("255.255.255.0")
t:value("255.255.0.0")
t:value("255.0.0.0")
d=e:taboption("general",Value,"gateway",translate("IPv4 gateway"))
d.datatype="ip4addr"
r=e:taboption("general",Value,"broadcast",translate("IPv4 broadcast"))
r.datatype="ip4addr"
h=e:taboption("general",DynamicList,"dns",
translate("Use custom DNS servers"))
h.datatype="ipaddr"
h.cast="string"
if luci.model.network:has_ipv6()then
local t=e:taboption("general",Value,"ip6assign",translate("IPv6 assignment length"),
translate("Assign a part of given length of every public IPv6-prefix to this interface"))
t:value("",translate("disabled"))
t:value("64")
t.datatype="max(64)"
local t=e:taboption("general",Value,"ip6hint",translate("IPv6 assignment hint"),
translate("Assign prefix parts using this hexadecimal subprefix ID for this interface."))
for e=33,64 do t:depends("ip6assign",e)end
n=e:taboption("general",Value,"ip6addr",translate("IPv6 address"))
n.datatype="ip6addr"
n:depends("ip6assign","")
a=e:taboption("general",Value,"ip6gw",translate("IPv6 gateway"))
a.datatype="ip6addr"
a:depends("ip6assign","")
local e=s:taboption("general",Value,"ip6prefix",translate("IPv6 routed prefix"),
translate("Public prefix routed to this device for distribution to clients."))
e.datatype="ip6addr"
e:depends("ip6assign","")
local e=s:taboption("general",Value,"ip6ifaceid",translate("IPv6 suffix"),
translate("Optional. Allowed values: 'eui64', 'random', fixed value like '::1' "..
"or '::1:2'. When IPv6 prefix (like 'a:b:c:d::') is received from a "..
"delegating server, use the suffix (like '::1') to form the IPv6 address "..
"('a:b:c:d::1') for the interface."))
e.datatype="ip6hostid"
e.placeholder="::1"
e.rmempty=true
end
luci.tools.proto.opt_macaddr(e,u,translate("Override MAC address"))
o=e:taboption("advanced",Value,"mtu",translate("Override MTU"))
o.placeholder="1500"
o.datatype="max(9200)"
i=e:taboption("advanced",Value,"metric",
translate("Use gateway metric"))
i.placeholder="0"
i.datatype="uinteger"
