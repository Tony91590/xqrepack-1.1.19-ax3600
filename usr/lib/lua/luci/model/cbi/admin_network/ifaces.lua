local e=require"nixio.fs"
local n=require"luci.util"
local t=require"luci.tools.proto"
local a=require"luci.model.network"
local i=require"luci.model.firewall"
arg[1]=arg[1]or""
local d=e.access("/etc/config/dhcp")
local h=e.access("/etc/config/firewall")
m=Map("network",translate("Interfaces").." - "..arg[1]:upper(),translate("On this page you can configure the network interfaces. You can bridge several interfaces by ticking the \"bridge interfaces\" field and enter the names of several network interfaces separated by spaces. You can also use <abbr title=\"Virtual Local Area Network\">VLAN</abbr> notation <samp>INTERFACE.VLANNR</samp> (<abbr title=\"for example\">e.g.</abbr>: <samp>eth0.1</samp>)."))
m.redirect=luci.dispatcher.build_url("admin","network","network")
m:chain("wireless")
if h then
m:chain("firewall")
end
a.init(m.uci)
i.init(m.uci)
local e=a:get_network(arg[1])
local function r(t)
if not e:is_floating()and not m:get(e:name(),"_orig_ifname")then
local a=e:get_interfaces()or{e:get_interface()}
if a then
local t,t
local t={}
for a,e in ipairs(a)do
t[#t+1]=e:name()
end
if#t>0 then
m:set(e:name(),"_orig_ifname",table.concat(t," "))
m:set(e:name(),"_orig_bridge",tostring(e:is_bridge()))
end
end
end
end
if not e then
luci.http.redirect(luci.dispatcher.build_url("admin/network/network"))
return
end
if m:formvalue("cbid.network.%s._switch"%e:name())then
local t=m:formvalue("cbid.network.%s.proto"%e:name())or"-"
local t=a:get_protocol(t,e:name())
if t then
r()
if not e:is_floating()and not t:is_floating()then
if e:is_bridge()and t:is_virtual()then
local t,t
local t=true
for o,a in ipairs(e:get_interfaces()or{e:get_interface()})do
if t then
t=false
else
e:del_interface(a)
end
end
m:del(e:name(),"type")
end
elseif e:is_floating()and not t:is_floating()then
local o=(m:get(e:name(),"_orig_bridge")=="true")
local i
local i={}
for e in n.imatch(m:get(e:name(),"_orig_ifname"))do
e=a:get_interface(e)
if e and not e:get_network()then
t:add_interface(e)
if not o then
break
end
end
end
if o then
m:set(e:name(),"type","bridge")
end
else
local t,t
for a,t in ipairs(e:get_interfaces()or{e:get_interface()})do
e:del_interface(t)
end
m:del(e:name(),"type")
end
local a,a
for t,a in pairs(m:get(e:name()))do
if t:sub(1,1)~="."and
t~="type"and
t~="ifname"and
t~="_orig_ifname"and
t~="_orig_bridge"
then
m:del(e:name(),t)
end
end
m:set(e:name(),"proto",t:proto())
m.uci:save("network")
m.uci:save("wireless")
luci.http.redirect(luci.dispatcher.build_url("admin/network/network",arg[1]))
return
end
end
if m:formvalue("cbid.dhcp._enable._enable")then
m.uci:section("dhcp","dhcp",arg[1],{
interface=arg[1],
start="100",
limit="150",
leasetime="12h"
})
m.uci:save("dhcp")
luci.http.redirect(luci.dispatcher.build_url("admin/network/network",arg[1]))
return
end
local t=e:get_interface()
s=m:section(NamedSection,arg[1],"interface",translate("Common Configuration"))
s.addremove=false
s:tab("general",translate("General Setup"))
s:tab("advanced",translate("Advanced Settings"))
s:tab("physical",translate("Physical Settings"))
if h then
s:tab("firewall",translate("Firewall Settings"))
end
st=s:taboption("general",DummyValue,"__status",translate("Status"))
local function t()
if not e:is_floating()and e:is_empty()then
st.template="cbi/dvalue"
st.network=nil
st.value=translate("There is no device assigned yet, please attach a network device in the \"Physical Settings\" tab")
else
st.template="admin_network/iface_status"
st.network=arg[1]
st.value=nil
end
end
m.on_init=t
m.on_after_save=t
p=s:taboption("general",ListValue,"proto",translate("Protocol"))
p.default=e:proto()
if not e:is_installed()then
p_install=s:taboption("general",Button,"_install")
p_install.title=translate("Protocol support is not installed")
p_install.inputtitle=translate("Install package %q"%e:opkg_package())
p_install.inputstyle="apply"
p_install:depends("proto",e:proto())
function p_install.write()
return luci.http.redirect(
luci.dispatcher.build_url("admin/system/packages")..
"?submit=1&install=%s"%e:opkg_package()
)
end
end
p_switch=s:taboption("general",Button,"_switch")
p_switch.title=translate("Really switch protocol?")
p_switch.inputtitle=translate("Switch protocol")
p_switch.inputstyle="apply"
local t,t
for a,t in ipairs(a:get_protocols())do
p:value(t:proto(),t:get_i18n())
if t:proto()~=e:proto()then
p_switch:depends("proto",t:proto())
end
end
auto=s:taboption("advanced",Flag,"auto",translate("Bring up on boot"))
auto.default=(e:proto()=="none")and auto.disabled or auto.enabled
delegate=s:taboption("advanced",Flag,"delegate",translate("Use builtin IPv6-management"))
delegate.default=delegate.enabled
force_link=s:taboption("advanced",Flag,"force_link",
translate("Force link"),
translate("Set interface properties regardless of the link carrier (If set, carrier sense events do not invoke hotplug handlers)."))
force_link.default=(e:proto()=="static")and force_link.enabled or force_link.disabled
if not e:is_virtual()then
br=s:taboption("physical",Flag,"type",translate("Bridge interfaces"),translate("creates a bridge over specified interface(s)"))
br.enabled="bridge"
br.rmempty=true
br:depends("proto","static")
br:depends("proto","dhcp")
br:depends("proto","none")
stp=s:taboption("physical",Flag,"stp",translate("Enable <abbr title=\"Spanning Tree Protocol\">STP</abbr>"),
translate("Enables the Spanning Tree Protocol on this bridge"))
stp:depends("type","bridge")
stp.rmempty=true
end
if not e:is_floating()then
ifname_single=s:taboption("physical",Value,"ifname_single",translate("Interface"))
ifname_single.template="cbi/network_ifacelist"
ifname_single.widget="radio"
ifname_single.nobridges=true
ifname_single.rmempty=false
ifname_single.network=arg[1]
ifname_single:depends("type","")
function ifname_single.cfgvalue(e,e)
return nil
end
function ifname_single.write(o,t,i)
local t
local a={}
local t={}
for a,e in ipairs(e:get_interfaces()or{e:get_interface()})do
t[#t+1]=e:name()
end
for e in n.imatch(i)do
a[#a+1]=e
if o.option=="ifname_single"then
break
end
end
table.sort(t)
table.sort(a)
for o=1,math.max(#t,#a)do
if t[o]~=a[o]then
r()
for a=1,#t do
e:del_interface(t[a])
end
for t=1,#a do
e:add_interface(a[t])
end
break
end
end
end
end
if not e:is_virtual()then
ifname_multi=s:taboption("physical",Value,"ifname_multi",translate("Interface"))
ifname_multi.template="cbi/network_ifacelist"
ifname_multi.nobridges=true
ifname_multi.rmempty=false
ifname_multi.network=arg[1]
ifname_multi.widget="checkbox"
ifname_multi:depends("type","bridge")
ifname_multi.cfgvalue=ifname_single.cfgvalue
ifname_multi.write=ifname_single.write
end
if h then
fwzone=s:taboption("firewall",Value,"_fwzone",
translate("Create / Assign firewall-zone"),
translate("Choose the firewall zone you want to assign to this interface. Select <em>unspecified</em> to remove the interface from the associated zone or fill out the <em>create</em> field to define a new zone and attach the interface to it."))
fwzone.template="cbi/firewall_zonelist"
fwzone.network=arg[1]
fwzone.rmempty=false
function fwzone.cfgvalue(t,e)
t.iface=e
local e=i:get_zone_by_network(e)
return e and e:name()
end
function fwzone.write(o,a,e)
local t=i:get_zone(e)
if not t and e=='-'then
e=m:formvalue(o:cbid(a)..".newzone")
if e and#e>0 then
t=i:add_zone(e)
else
i:del_network(a)
end
end
if t then
i:del_network(a)
t:add_network(a)
end
end
end
function p.write()end
function p.remove()end
function p.validate(o,t,a)
if t==e:proto()then
if not e:is_floating()and e:is_empty()then
local e=((br and(br:formvalue(a)=="bridge"))
and ifname_multi:formvalue(a)
or ifname_single:formvalue(a))
for e in n.imatch(e)do
return t
end
return nil,translate("The selected protocol needs a device assigned")
end
end
return t
end
local t,a=loadfile(
n.libpath().."/model/cbi/admin_network/proto_%s.lua"%e:proto()
)
if not t then
s:taboption("general",DummyValue,"_error",
translate("Missing protocol extension for proto %q"%e:proto())
).value=a
else
setfenv(t,getfenv(1))(m,s,e)
end
local t,t
for a,t in ipairs(s.children)do
if t~=st and t~=p and t~=p_install and t~=p_switch then
if next(t.deps)then
local a,a
for a,t in ipairs(t.deps)do
t.proto=e:proto()
end
else
t:depends("proto",e:proto())
end
end
end
if d and e:proto()=="static"then
m2=Map("dhcp","","")
local e=false
m2.uci:foreach("dhcp","dhcp",function(t)
if t.interface==arg[1]then
e=true
return false
end
end)
if not e and d then
s=m2:section(TypedSection,"dhcp",translate("DHCP Server"))
s.anonymous=true
s.cfgsections=function()return{"_enable"}end
x=s:option(Button,"_enable")
x.title=translate("No DHCP Server configured for this interface")
x.inputtitle=translate("Setup DHCP Server")
x.inputstyle="apply"
elseif e then
s=m2:section(TypedSection,"dhcp",translate("DHCP Server"))
s.addremove=false
s.anonymous=true
s:tab("general",translate("General Setup"))
s:tab("advanced",translate("Advanced Settings"))
s:tab("ipv6",translate("IPv6 Settings"))
function s.filter(t,e)
return m2.uci:get("dhcp",e,"interface")==arg[1]
end
local t=s:taboption("general",Flag,"ignore",
translate("Ignore interface"),
translate("Disable <abbr title=\"Dynamic Host Configuration Protocol\">DHCP</abbr> for "..
"this interface."))
local e=s:taboption("general",Value,"start",translate("Start"),
translate("Lowest leased address as offset from the network address."))
e.optional=true
e.datatype="or(uinteger,ip4addr)"
e.default="100"
local e=s:taboption("general",Value,"limit",translate("Limit"),
translate("Maximum number of leased addresses."))
e.optional=true
e.datatype="uinteger"
e.default="150"
local e=s:taboption("general",Value,"leasetime",translate("Lease time"),
translate("Expiry time of leased addresses, minimum is 2 minutes (<code>2m</code>)."))
e.rmempty=true
e.default="12h"
local e=s:taboption("advanced",Flag,"dynamicdhcp",
translate("Dynamic <abbr title=\"Dynamic Host Configuration Protocol\">DHCP</abbr>"),
translate("Dynamically allocate DHCP addresses for clients. If disabled, only "..
"clients having static leases will be served."))
e.default=e.enabled
s:taboption("advanced",Flag,"force",translate("Force"),
translate("Force DHCP on this network even if another server is detected."))
mask=s:taboption("advanced",Value,"netmask",
translate("<abbr title=\"Internet Protocol Version 4\">IPv4</abbr>-Netmask"),
translate("Override the netmask sent to clients. Normally it is calculated "..
"from the subnet that is served."))
mask.optional=true
mask.datatype="ip4addr"
s:taboption("advanced",DynamicList,"dhcp_option",translate("DHCP-Options"),
translate("Define additional DHCP options, for example \"<code>6,192.168.2.1,"..
"192.168.2.2</code>\" which advertises different DNS servers to clients."))
for a,e in ipairs(s.children)do
if e~=t then
e:depends("ignore","")
end
end
o=s:taboption("ipv6",ListValue,"ra",translate("Router Advertisement-Service"))
o:value("",translate("disabled"))
o:value("server",translate("server mode"))
o:value("relay",translate("relay mode"))
o:value("hybrid",translate("hybrid mode"))
o=s:taboption("ipv6",ListValue,"dhcpv6",translate("DHCPv6-Service"))
o:value("",translate("disabled"))
o:value("server",translate("server mode"))
o:value("relay",translate("relay mode"))
o:value("hybrid",translate("hybrid mode"))
o=s:taboption("ipv6",ListValue,"ndp",translate("NDP-Proxy"))
o:value("",translate("disabled"))
o:value("relay",translate("relay mode"))
o:value("hybrid",translate("hybrid mode"))
o=s:taboption("ipv6",ListValue,"ra_management",translate("DHCPv6-Mode"),
translate("Default is stateless + stateful"))
o:value("0",translate("stateless"))
o:value("1",translate("stateless + stateful"))
o:value("2",translate("stateful-only"))
o:depends("dhcpv6","server")
o:depends("dhcpv6","hybrid")
o.default="1"
o=s:taboption("ipv6",Flag,"ra_default",translate("Always announce default router"),
translate("Announce as default router even if no public prefix is available."))
o:depends("ra","server")
o:depends("ra","hybrid")
s:taboption("ipv6",DynamicList,"dns",translate("Announced DNS servers"))
s:taboption("ipv6",DynamicList,"domain",translate("Announced DNS domains"))
else
m2=nil
end
end
return m,m2
