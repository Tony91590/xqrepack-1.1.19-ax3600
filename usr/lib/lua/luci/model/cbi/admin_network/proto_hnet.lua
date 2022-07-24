local a,t,e=...
local e=t:taboption("general",ListValue,"mode",translate("Category"))
e:value("auto",translate("Automatic"))
e:value("external",translate("External"))
e:value("internal",translate("Internal"))
e:value("leaf",translate("Leaf"))
e:value("guest",translate("Guest"))
e:value("adhoc",translate("Ad-Hoc"))
e:value("hybrid",translate("Hybrid"))
e.default="auto"
local e=t:taboption("advanced",Value,"ip6assign",translate("IPv6 assignment length"),
translate("Assign a part of given length of every public IPv6-prefix to this interface"))
e.datatype="max(128)"
e.default="64"
t:taboption("advanced",Value,"link_id",translate("IPv6 assignment hint"),
translate("Assign prefix parts using this hexadecimal subprefix ID for this interface."))
e=t:taboption("advanced",Value,"ip4assign",translate("IPv4 assignment length"))
e.datatype="max(32)"
e.default="24"
local e=t:taboption("advanced",Value,"dnsname",translate("DNS-Label / FQDN"))
e.default=a.name
luci.tools.proto.opt_macaddr(t,ifc,translate("Override MAC address"))
e=t:taboption("advanced",Value,"mtu",translate("Override MTU"))
e.placeholder="1500"
e.datatype="max(9200)"
