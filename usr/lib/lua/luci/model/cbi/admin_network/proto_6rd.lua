local e,a,e=...
local r,h,n,e,e,e
local t,e,o,i
r=s:taboption("general",Value,"ipaddr",
translate("Local IPv4 address"),
translate("Leave empty to use the current WAN address"))
r.datatype="ip4addr"
h=s:taboption("general",Value,"peeraddr",
translate("Remote IPv4 address"),
translate("This IPv4 address of the relay"))
h.rmempty=false
h.datatype="ip4addr"
n=s:taboption("general",Value,"ip6prefix",
translate("IPv6 prefix"),
translate("The IPv6 prefix assigned to the provider, usually ends with <code>::</code>"))
n.rmempty=false
n.datatype="ip6addr"
ip6prefixlen=s:taboption("general",Value,"ip6prefixlen",
translate("IPv6 prefix length"),
translate("The length of the IPv6 prefix in bits"))
ip6prefixlen.placeholder="16"
ip6prefixlen.datatype="range(0,128)"
ip6prefixlen=s:taboption("general",Value,"ip4prefixlen",
translate("IPv4 prefix length"),
translate("The length of the IPv4 prefix in bits, the remainder is used in the IPv6 addresses."))
ip6prefixlen.placeholder="0"
ip6prefixlen.datatype="range(0,32)"
t=a:taboption("advanced",Flag,"defaultroute",
translate("Default gateway"),
translate("If unchecked, no default route is configured"))
t.default=t.enabled
e=a:taboption("advanced",Value,"metric",
translate("Use gateway metric"))
e.placeholder="0"
e.datatype="uinteger"
e:depends("defaultroute",t.enabled)
o=a:taboption("advanced",Value,"ttl",translate("Use TTL on tunnel interface"))
o.placeholder="64"
o.datatype="range(1,255)"
i=a:taboption("advanced",Value,"mtu",translate("Use MTU on tunnel interface"))
i.placeholder="1280"
i.datatype="max(9200)"
