module("luci.controller.admin.network",package.seeall)
function index()
local t=require("luci.model.uci").cursor()
local e
e=node("admin","network")
e.target=firstchild()
e.title=_("Network")
e.order=50
e.index=true
local a=false
t:foreach("network","switch",
function(e)
a=true
return false
end)
if a then
e=node("admin","network","vlan")
e.target=cbi("admin_network/vlan")
e.title=_("Switch")
e.order=20
e=entry({"admin","network","switch_status"},call("switch_status"),nil)
e.leaf=true
end
local a=false
t:foreach("wireless","wifi-device",
function(e)
a=true
return false
end)
if a then
e=entry({"admin","network","wireless_join"},post("wifi_join"),nil)
e.leaf=true
e=entry({"admin","network","wireless_add"},post("wifi_add"),nil)
e.leaf=true
e=entry({"admin","network","wireless_delete"},post("wifi_delete"),nil)
e.leaf=true
e=entry({"admin","network","wireless_status"},call("wifi_status"),nil)
e.leaf=true
e=entry({"admin","network","wireless_reconnect"},post("wifi_reconnect"),nil)
e.leaf=true
e=entry({"admin","network","wireless_shutdown"},post("wifi_shutdown"),nil)
e.leaf=true
e=entry({"admin","network","wireless"},arcombine(template("admin_network/wifi_overview"),cbi("admin_network/wifi")),_("Wireless"),15)
e.leaf=true
e.subindex=true
if e.inreq then
local e
local e=require"luci.model.network".init(t)
for t,e in ipairs(e:get_wifidevs())do
local t
for a,t in ipairs(e:get_wifinets())do
entry(
{"admin","network","wireless",t:id()},
alias("admin","network","wireless"),
e:name()..": "..t:shortname()
)
end
end
end
end
e=entry({"admin","network","iface_add"},cbi("admin_network/iface_add"),nil)
e.leaf=true
e=entry({"admin","network","iface_delete"},post("iface_delete"),nil)
e.leaf=true
e=entry({"admin","network","iface_status"},call("iface_status"),nil)
e.leaf=true
e=entry({"admin","network","iface_reconnect"},post("iface_reconnect"),nil)
e.leaf=true
e=entry({"admin","network","iface_shutdown"},post("iface_shutdown"),nil)
e.leaf=true
e=entry({"admin","network","network"},arcombine(cbi("admin_network/network"),cbi("admin_network/ifaces")),_("Interfaces"),10)
e.leaf=true
e.subindex=true
if e.inreq then
t:foreach("network","interface",
function(e)
local e=e[".name"]
if e~="loopback"then
entry({"admin","network","network",e},
true,e:upper())
end
end)
end
if nixio.fs.access("/etc/config/dhcp")then
e=node("admin","network","dhcp")
e.target=cbi("admin_network/dhcp")
e.title=_("DHCP and DNS")
e.order=30
e=entry({"admin","network","dhcplease_status"},call("lease_status"),nil)
e.leaf=true
e=node("admin","network","hosts")
e.target=cbi("admin_network/hosts")
e.title=_("Hostnames")
e.order=40
end
e=node("admin","network","routes")
e.target=cbi("admin_network/routes")
e.title=_("Static Routes")
e.order=50
e=node("admin","network","diagnostics")
e.target=template("admin_network/diagnostics")
e.title=_("Diagnostics")
e.order=60
e=entry({"admin","network","diag_ping"},post("diag_ping"),nil)
e.leaf=true
e=entry({"admin","network","diag_nslookup"},post("diag_nslookup"),nil)
e.leaf=true
e=entry({"admin","network","diag_traceroute"},post("diag_traceroute"),nil)
e.leaf=true
e=entry({"admin","network","diag_ping6"},post("diag_ping6"),nil)
e.leaf=true
e=entry({"admin","network","diag_traceroute6"},post("diag_traceroute6"),nil)
e.leaf=true
end
function wifi_join()
local t=require"luci.template"
local e=require"luci.http"
local a=e.formvalue("device")
local o=e.formvalue("join")
if a and o then
local e=(e.formvalue("cancel")or e.formvalue("cbi.cancel"))
if not e then
local a=require"luci.cbi"
local e=luci.cbi.load("admin_network/wifi_add")[1]
if e:parse()~=a.FORM_DONE then
t.render("header")
e:render()
t.render("footer")
end
return
end
end
t.render("admin_network/wifi_join")
end
function wifi_add()
local e=luci.http.formvalue("device")
local t=require"luci.model.network".init()
e=e and t:get_wifidev(e)
if e then
local e=e:add_wifinet({
mode="ap",
ssid="OpenWrt",
encryption="none"
})
t:save("wireless")
luci.http.redirect(e:adminlink())
end
end
function wifi_delete(a)
local e=require"luci.model.network".init()
local t=e:get_wifinet(a)
if t then
local o=t:get_device()
local t=t:get_networks()
if o then
e:del_wifinet(a)
e:commit("wireless")
local a,a
for a,t in ipairs(t)do
if t:is_empty()then
e:del_network(t:name())
e:commit("network")
end
end
luci.sys.call("env -i /bin/ubus call network reload >/dev/null 2>/dev/null")
end
end
luci.http.redirect(luci.dispatcher.build_url("admin/network/wireless"))
end
function iface_status(e)
local n=require"luci.model.network".init()
local a={}
local t
for o in e:gmatch("[%w%.%-_]+")do
local e=n:get_network(o)
local t=e and e:get_interface()
if t then
local i=t:mac()
if(i=="00:00:00:00:00:00"and e:proto()=="pppoe")then
i=(n.interface(e:_ubus("device"),e)):mac()or"00:00:00:00:00:00"
end
local t={
id=o,
proto=e:proto(),
uptime=e:uptime(),
gwaddr=e:gwaddr(),
ipaddrs=e:ipaddrs(),
ip6addrs=e:ip6addrs(),
dnsaddrs=e:dnsaddrs(),
ip6prefix=e:ip6prefix(),
name=t:shortname(),
type=t:type(),
ifname=t:name(),
macaddr=i,
is_up=t:is_up(),
rx_bytes=t:rx_bytes(),
tx_bytes=t:tx_bytes(),
rx_packets=t:rx_packets(),
tx_packets=t:tx_packets(),
subdevices={}
}
for o,e in ipairs(e:get_interfaces()or{})do
t.subdevices[#t.subdevices+1]={
name=e:shortname(),
type=e:type(),
ifname=e:name(),
macaddr=e:mac(),
macaddr=e:mac(),
is_up=e:is_up(),
rx_bytes=e:rx_bytes(),
tx_bytes=e:tx_bytes(),
rx_packets=e:rx_packets(),
tx_packets=e:tx_packets(),
}
end
a[#a+1]=t
else
a[#a+1]={
id=o,
name=o,
type="ethernet"
}
end
end
if#a>0 then
luci.http.prepare_content("application/json")
luci.http.write_json(a)
return
end
luci.http.status(404,"No such device")
end
function iface_reconnect(e)
local t=require"luci.model.network".init()
local t=t:get_network(e)
if t then
luci.sys.call("env -i /sbin/ifup %q >/dev/null 2>/dev/null"%e)
luci.http.status(200,"Reconnected")
return
end
luci.http.status(404,"No such interface")
end
function iface_shutdown(e)
local t=require"luci.model.network".init()
local t=t:get_network(e)
if t then
luci.sys.call("env -i /sbin/ifdown %q >/dev/null 2>/dev/null"%e)
luci.http.status(200,"Shutdown")
return
end
luci.http.status(404,"No such interface")
end
function iface_delete(t)
local e=require"luci.model.network".init()
local a=e:del_network(t)
if a then
luci.sys.call("env -i /sbin/ifdown %q >/dev/null 2>/dev/null"%t)
luci.http.redirect(luci.dispatcher.build_url("admin/network/network"))
e:commit("network")
e:commit("wireless")
return
end
luci.http.status(404,"No such interface")
end
function wifi_status(t)
local a=require"luci.tools.status"
local e={}
local o
for t in t:gmatch("[%w%.%-]+")do
e[#e+1]=a.wifi_network(t)
end
if#e>0 then
luci.http.prepare_content("application/json")
luci.http.write_json(e)
return
end
luci.http.status(404,"No such device")
end
local function i(o,e)
local t=require"luci.model.network".init()
local e=t:get_wifinet(e)
local a=e:get_device()
if a and e then
a:set("disabled",nil)
e:set("disabled",o and 1 or nil)
t:commit("wireless")
luci.sys.call("env -i /bin/ubus call network reload >/dev/null 2>/dev/null")
luci.http.status(200,o and"Shutdown"or"Reconnected")
return
end
luci.http.status(404,"No such radio")
end
function wifi_reconnect(e)
i(false,e)
end
function wifi_shutdown(e)
i(true,e)
end
function lease_status()
local e=require"luci.tools.status"
luci.http.prepare_content("application/json")
luci.http.write('[')
luci.http.write_json(e.dhcp_leases())
luci.http.write(',')
luci.http.write_json(e.dhcp6_leases())
luci.http.write(']')
end
function switch_status(e)
local t=require"luci.tools.status"
luci.http.prepare_content("application/json")
luci.http.write_json(t.switch_status(e))
end
function diag_command(t,e)
if e and e:match("^[a-zA-Z0-9%-%.:_]+$")then
luci.http.prepare_content("text/plain")
local e=io.popen(t%e)
if e then
while true do
local e=e:read("*l")
if not e then break end
luci.http.write(e)
luci.http.write("\n")
end
e:close()
end
return
end
luci.http.status(500,"Bad address")
end
function diag_ping(e)
diag_command("ping -c 5 -W 1 %q 2>&1",e)
end
function diag_traceroute(e)
diag_command("traceroute -q 1 -w 1 -n %q 2>&1",e)
end
function diag_nslookup(e)
diag_command("nslookup %q 2>&1",e)
end
function diag_ping6(e)
diag_command("ping6 -c 5 %q 2>&1",e)
end
function diag_traceroute6(e)
diag_command("traceroute6 -q 1 -w 2 -n %q 2>&1",e)
end
