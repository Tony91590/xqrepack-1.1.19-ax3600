local t,e,t=...
local h,n
local i,a,t,r,o
maptype=e:taboption("general",ListValue,"type",translate("Type"))
maptype:value("map-e","MAP-E")
maptype:value("map-t","MAP-T")
maptype:value("lw4o6","LW4over6")
h=e:taboption("general",Value,"peeraddr",
translate("BR / DMR / AFTR"))
h.rmempty=false
h.datatype="ip6addr"
ipaddr=e:taboption("general",Value,"ipaddr",
translate("IPv4 prefix"))
ipaddr.datatype="ip4addr"
ip4prefixlen=s:taboption("general",Value,"ip4prefixlen",
translate("IPv4 prefix length"),
translate("The length of the IPv4 prefix in bits, the remainder is used in the IPv6 addresses."))
ip4prefixlen.placeholder="32"
ip4prefixlen.datatype="range(0,32)"
n=s:taboption("general",Value,"ip6prefix",
translate("IPv6 prefix"),
translate("The IPv6 prefix assigned to the provider, usually ends with <code>::</code>"))
n.rmempty=false
n.datatype="ip6addr"
ip6prefixlen=s:taboption("general",Value,"ip6prefixlen",
translate("IPv6 prefix length"),
translate("The length of the IPv6 prefix in bits"))
ip6prefixlen.placeholder="16"
ip6prefixlen.datatype="range(0,64)"
s:taboption("general",Value,"ealen",
translate("EA-bits length")).datatype="range(0,48)"
s:taboption("general",Value,"psidlen",
translate("PSID-bits length")).datatype="range(0,16)"
s:taboption("general",Value,"offset",
translate("PSID offset")).datatype="range(0,16)"
i=e:taboption("advanced",DynamicList,"tunlink",translate("Tunnel Link"))
i.template="cbi/network_netlist"
i.nocreate=true
a=e:taboption("advanced",Flag,"defaultroute",
translate("Default gateway"),
translate("If unchecked, no default route is configured"))
a.default=a.enabled
t=e:taboption("advanced",Value,"metric",
translate("Use gateway metric"))
t.placeholder="0"
t.datatype="uinteger"
t:depends("defaultroute",a.enabled)
r=e:taboption("advanced",Value,"ttl",translate("Use TTL on tunnel interface"))
r.placeholder="64"
r.datatype="range(1,255)"
o=e:taboption("advanced",Value,"mtu",translate("Use MTU on tunnel interface"))
o.placeholder="1280"
o.datatype="max(9200)"
