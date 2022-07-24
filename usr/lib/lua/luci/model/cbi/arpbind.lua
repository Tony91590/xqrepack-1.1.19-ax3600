local e=require"luci.sys"
local t=e.net:devices()
m=Map("arpbind",translate("IP/MAC Binding"),
translatef("ARP is used to convert a network address (e.g. an IPv4 address) to a physical address such as a MAC address.Here you can add some static ARP binding rules."))
s=m:section(TypedSection,"arpbind",translate("Rules"))
s.template="cbi/tblsection"
s.anonymous=true
s.addremove=true
a=s:option(Value,"ipaddr",translate("IP Address"))
a.optional=false
a.datatype="ipaddr"
luci.ip.neighbors({family=4},function(e)
if e.reachable then
a:value(e.dest:string())
end
end)
a=s:option(Value,"macaddr",translate("MAC Address"))
a.datatype="macaddr"
a.optional=false
luci.ip.neighbors({family=4},function(e)
if e.reachable then
a:value(e.mac,"%s (%s)"%{e.mac,e.dest:string()})
end
end)
a=s:option(ListValue,"ifname",translate("Interface"))
for t,e in ipairs(t)do
if e~="lo"then
a:value(e)
end
end
a.default="br-lan"
a.rmempty=false
return m
