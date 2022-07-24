local a,e,t=...
local r=t:get_interface()
local s,t,t
local a,o,i,t,n,h,d
s=e:taboption("general",Value,"hostname",
translate("Hostname to send when requesting DHCP"))
s.placeholder=luci.sys.hostname()
s.datatype="hostname"
a=e:taboption("advanced",Flag,"broadcast",
translate("Use broadcast flag"),
translate("Required for certain ISPs, e.g. Charter with DOCSIS 3"))
a.default=a.disabled
o=e:taboption("advanced",Flag,"defaultroute",
translate("Use default gateway"),
translate("If unchecked, no default route is configured"))
o.default=o.enabled
i=e:taboption("advanced",Flag,"peerdns",
translate("Use DNS servers advertised by peer"),
translate("If unchecked, the advertised DNS server addresses are ignored"))
i.default=i.enabled
t=e:taboption("advanced",DynamicList,"dns",
translate("Use custom DNS servers"))
t:depends("peerdns","")
t.datatype="ipaddr"
t.cast="string"
n=e:taboption("advanced",Value,"metric",
translate("Use gateway metric"))
n.placeholder="0"
n.datatype="uinteger"
h=e:taboption("advanced",Value,"clientid",
translate("Client ID to send when requesting DHCP"))
d=e:taboption("advanced",Value,"vendorid",
translate("Vendor Class to send when requesting DHCP"))
luci.tools.proto.opt_macaddr(e,r,translate("Override MAC address"))
mtu=e:taboption("advanced",Value,"mtu",translate("Override MTU"))
mtu.placeholder="1500"
mtu.datatype="max(9200)"
