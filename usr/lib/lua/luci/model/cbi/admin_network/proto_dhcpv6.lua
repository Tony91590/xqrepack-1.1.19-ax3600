local e,t,e=...
local e=t:taboption("general",ListValue,"reqaddress",
translate("Request IPv6-address"))
e:value("try")
e:value("force")
e:value("none","disabled")
e.default="try"
e=t:taboption("general",Value,"reqprefix",
translate("Request IPv6-prefix of length"))
e:value("auto",translate("Automatic"))
e:value("no",translate("disabled"))
e:value("48")
e:value("52")
e:value("56")
e:value("60")
e:value("64")
e.default="auto"
e=t:taboption("advanced",Flag,"defaultroute",
translate("Use default gateway"),
translate("If unchecked, no default route is configured"))
e.default=e.enabled
e=t:taboption("advanced",Flag,"peerdns",
translate("Use DNS servers advertised by peer"),
translate("If unchecked, the advertised DNS server addresses are ignored"))
e.default=e.enabled
e=t:taboption("advanced",Value,"ip6prefix",
translate("Custom delegated IPv6-prefix"))
e.dataype="ip6addr"
e=t:taboption("advanced",DynamicList,"dns",
translate("Use custom DNS servers"))
e:depends("peerdns","")
e.datatype="list(ip6addr)"
e.cast="string"
e=t:taboption("advanced",Value,"clientid",
translate("Client ID to send when requesting DHCP"))
luci.tools.proto.opt_macaddr(t,ifc,translate("Override MAC address"))
e=t:taboption("advanced",Value,"mtu",translate("Override MTU"))
e.placeholder="1500"
e.datatype="max(9200)"
