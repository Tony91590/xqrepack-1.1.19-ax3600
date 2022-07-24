local t,e,t=...
local r,d,h
local t,a,i,n,o,s
r=e:taboption("general",Value,"server",translate("L2TP Server"))
r.datatype="or(host(1), hostport(1))"
d=e:taboption("general",Value,"username",translate("PAP/CHAP username"))
h=e:taboption("general",Value,"password",translate("PAP/CHAP password"))
h.password=true
if luci.model.network:has_ipv6()then
t=e:taboption("advanced",ListValue,"ipv6",
translate("Obtain IPv6-Address"),
translate("Enable IPv6 negotiation on the PPP link"))
t:value("auto",translate("Automatic"))
t:value("0",translate("Disabled"))
t:value("1",translate("Manual"))
t.default="auto"
end
a=e:taboption("advanced",Flag,"defaultroute",
translate("Use default gateway"),
translate("If unchecked, no default route is configured"))
a.default=a.enabled
i=e:taboption("advanced",Value,"metric",
translate("Use gateway metric"))
i.placeholder="0"
i.datatype="uinteger"
i:depends("defaultroute",a.enabled)
n=e:taboption("advanced",Flag,"peerdns",
translate("Use DNS servers advertised by peer"),
translate("If unchecked, the advertised DNS server addresses are ignored"))
n.default=n.enabled
o=e:taboption("advanced",DynamicList,"dns",
translate("Use custom DNS servers"))
o:depends("peerdns","")
o.datatype="ipaddr"
o.cast="string"
s=e:taboption("advanced",Value,"mtu",translate("Override MTU"))
s.placeholder="1500"
s.datatype="max(9200)"
