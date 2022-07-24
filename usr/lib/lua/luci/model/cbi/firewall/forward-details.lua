local e=require"luci.sys"
local i=require"luci.dispatcher"
local o=require"luci.tools.firewall"
local a,t,e
arg[1]=arg[1]or""
a=Map("firewall",
translate("Firewall - Port Forwards"),
translate("This page allows you to change advanced properties of the port \
	           forwarding entry. In most cases there is no need to modify \
			   those settings."))
a.redirect=i.build_url("admin/network/firewall/forwards")
if a.uci:get("firewall",arg[1])~="redirect"then
luci.http.redirect(a.redirect)
return
else
local e=a:get(arg[1],"name")or a:get(arg[1],"_name")
if not e or#e==0 then
e=translate("(Unnamed Entry)")
end
a.title="%s - %s"%{translate("Firewall - Port Forwards"),e}
end
t=a:section(NamedSection,arg[1],"redirect","")
t.anonymous=true
t.addremove=false
o.opt_enabled(t,Button)
o.opt_name(t,Value,translate("Name"))
e=t:option(Value,"proto",translate("Protocol"))
e:value("tcp udp","TCP+UDP")
e:value("tcp","TCP")
e:value("udp","UDP")
e:value("icmp","ICMP")
function e.cfgvalue(...)
local t=Value.cfgvalue(...)
if not t or t=="tcpudp"then
return"tcp udp"
end
return t
end
e=t:option(Value,"src",translate("Source zone"))
e.nocreate=true
e.default="wan"
e.template="cbi/firewall_zonelist"
e=t:option(DynamicList,"src_mac",
translate("Source MAC address"),
translate("Only match incoming traffic from these MACs."))
e.rmempty=true
e.datatype="neg(macaddr)"
e.placeholder=translate("any")
luci.sys.net.mac_hints(function(t,a)
e:value(t,"%s (%s)"%{t,a})
end)
e=t:option(Value,"src_ip",
translate("Source IP address"),
translate("Only match incoming traffic from this IP or range."))
e.rmempty=true
e.datatype="neg(ipmask4)"
e.placeholder=translate("any")
luci.sys.net.ipv4_hints(function(t,a)
e:value(t,"%s (%s)"%{t,a})
end)
e=t:option(Value,"src_port",
translate("Source port"),
translate("Only match incoming traffic originating from the given source port or port range on the client host"))
e.rmempty=true
e.datatype="neg(portrange)"
e.placeholder=translate("any")
e=t:option(Value,"src_dip",
translate("External IP address"),
translate("Only match incoming traffic directed at the given IP address."))
luci.sys.net.ipv4_hints(function(t,a)
e:value(t,"%s (%s)"%{t,a})
end)
e.rmempty=true
e.datatype="neg(ipmask4)"
e.placeholder=translate("any")
e=t:option(Value,"src_dport",translate("External port"),
translate("Match incoming traffic directed at the given "..
"destination port or port range on this host"))
e.datatype="neg(portrange)"
e=t:option(Value,"dest",translate("Internal zone"))
e.nocreate=true
e.default="lan"
e.template="cbi/firewall_zonelist"
e=t:option(Value,"dest_ip",translate("Internal IP address"),
translate("Redirect matched incoming traffic to the specified \
		internal host"))
e.datatype="ipmask4"
luci.sys.net.ipv4_hints(function(t,a)
e:value(t,"%s (%s)"%{t,a})
end)
e=t:option(Value,"dest_port",
translate("Internal port"),
translate("Redirect matched incoming traffic to the given port on \
		the internal host"))
e.placeholder=translate("any")
e.datatype="portrange"
e=t:option(Flag,"reflection",translate("Enable NAT Loopback"))
e.rmempty=true
e.default=e.enabled
e.cfgvalue=function(...)
return Flag.cfgvalue(...)or"1"
end
t:option(Value,"extra",
translate("Extra arguments"),
translate("Passes additional arguments to iptables. Use with care!"))
return a
