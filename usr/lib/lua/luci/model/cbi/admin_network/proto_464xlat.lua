local t,e,t=...
local i,t,a,o
e:taboption("general",Value,"ip6prefix",
translate("NAT64 Prefix"),translate("Leave empty to autodetect"))
i=e:taboption("advanced",DynamicList,"tunlink",translate("Tunnel Link"))
i.template="cbi/network_netlist"
i.nocreate=true
t=e:taboption("advanced",Flag,"defaultroute",
translate("Default gateway"),
translate("If unchecked, no default route is configured"))
t.default=t.enabled
a=e:taboption("advanced",Value,"metric",
translate("Use gateway metric"))
a.placeholder="0"
a.datatype="uinteger"
a:depends("defaultroute",t.enabled)
o=e:taboption("advanced",Value,"mtu",translate("Use MTU on tunnel interface"))
o.placeholder="1280"
o.datatype="max(9200)"
