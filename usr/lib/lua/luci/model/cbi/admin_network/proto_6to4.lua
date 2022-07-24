local t,e,t=...
local n,t,a,o,i
n=e:taboption("general",Value,"ipaddr",
translate("Local IPv4 address"),
translate("Leave empty to use the current WAN address"))
n.datatype="ip4addr"
t=e:taboption("advanced",Flag,"defaultroute",
translate("Use default gateway"),
translate("If unchecked, no default route is configured"))
t.default=t.enabled
a=e:taboption("advanced",Value,"metric",
translate("Use gateway metric"))
a.placeholder="0"
a.datatype="uinteger"
a:depends("defaultroute",t.enabled)
o=e:taboption("advanced",Value,"ttl",translate("Use TTL on tunnel interface"))
o.placeholder="64"
o.datatype="range(1,255)"
i=e:taboption("advanced",Value,"mtu",translate("Use MTU on tunnel interface"))
i.placeholder="1280"
i.datatype="max(9200)"
