local t,e,t=...
local i,h
local n,a,t,o,s
i=e:taboption("general",Value,"peeraddr",
translate("DS-Lite AFTR address"))
i.rmempty=false
i.datatype="or(hostname,ip6addr)"
h=e:taboption("general",Value,"ip6addr",
translate("Local IPv6 address"),
translate("Leave empty to use the current WAN address"))
h.datatype="ip6addr"
n=e:taboption("advanced",DynamicList,"tunlink",translate("Tunnel Link"))
n.template="cbi/network_netlist"
n.nocreate=true
a=e:taboption("advanced",Flag,"defaultroute",
translate("Default gateway"),
translate("If unchecked, no default route is configured"))
a.default=a.enabled
t=e:taboption("advanced",Value,"metric",
translate("Use gateway metric"))
t.placeholder="0"
t.datatype="uinteger"
t:depends("defaultroute",a.enabled)
o=e:taboption("advanced",Value,"ttl",translate("Use TTL on tunnel interface"))
o.placeholder="64"
o.datatype="range(1,255)"
s=e:taboption("advanced",Value,"mtu",translate("Use MTU on tunnel interface"))
s.placeholder="1280"
s.datatype="max(9200)"
