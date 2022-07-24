local e=require"luci.sys"
local s=require"luci.util"
local o=require"luci.dispatcher"
local e=require"nixio"
local i=require"luci.tools.firewall"
local n=require"luci.model.network"
local a,t,e,h,h
arg[1]=arg[1]or""
a=Map("firewall",
translate("Firewall - Traffic Rules"),
translate("This page allows you to change advanced properties of the \
	           traffic rule entry, such as matched source and destination \
			   hosts."))
a.redirect=o.build_url("admin/network/firewall/rules")
n.init(a.uci)
local o=a.uci:get("firewall",arg[1])
if o=="redirect"and a:get(arg[1],"target")~="SNAT"then
o=nil
end
if not o then
luci.http.redirect(a.redirect)
return
elseif o=="redirect"then
local o=a:get(arg[1],"name")or a:get(arg[1],"_name")
if not o or#o==0 then
o=translate("(Unnamed SNAT)")
else
o="SNAT %s"%o
end
a.title="%s - %s"%{translate("Firewall - Traffic Rules"),o}
local o=nil
a.uci:foreach("firewall","zone",
function(e)
local t=e.network or e.name
if t then
local a
for t in s.imatch(t)do
if t=="wan"then
o=e.name
return false
end
end
end
end)
t=a:section(NamedSection,arg[1],"redirect","")
t.anonymous=true
t.addremove=false
i.opt_enabled(t,Button)
i.opt_name(t,Value,translate("Name"))
e=t:option(Value,"proto",
translate("Protocol"),
translate("You may specify multiple by selecting \"-- custom --\" and \
		           then entering protocols separated by space."))
e:value("all","All protocols")
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
e=t:option(Value,"src_ip",translate("Source IP address"))
e.rmempty=true
e.datatype="neg(ipmask4)"
e.placeholder=translate("any")
luci.sys.net.ipv4_hints(function(t,a)
e:value(t,"%s (%s)"%{t,a})
end)
e=t:option(Value,"src_port",
translate("Source port"),
translate("Match incoming traffic originating from the given source \
			port or port range on the client host."))
e.rmempty=true
e.datatype="neg(portrange)"
e.placeholder=translate("any")
e=t:option(Value,"dest",translate("Destination zone"))
e.nocreate=true
e.default="lan"
e.template="cbi/firewall_zonelist"
e=t:option(Value,"dest_ip",translate("Destination IP address"))
e.datatype="neg(ipmask4)"
luci.sys.net.ipv4_hints(function(t,a)
e:value(t,"%s (%s)"%{t,a})
end)
e=t:option(Value,"dest_port",
translate("Destination port"),
translate("Match forwarded traffic to the given destination port or \
			port range."))
e.rmempty=true
e.placeholder=translate("any")
e.datatype="neg(portrange)"
e=t:option(Value,"src_dip",
translate("SNAT IP address"),
translate("Rewrite matched traffic to the given address."))
e.rmempty=false
e.datatype="ip4addr"
for t,a in ipairs(n:get_interfaces())do
local t
for o,t in ipairs(a:ipaddrs())do
e:value(t:host():string(),'%s (%s)'%{
t:host():string(),a:shortname()
})
end
end
e=t:option(Value,"src_dport",translate("SNAT port"),
translate("Rewrite matched traffic to the given source port. May be \
			left empty to only rewrite the IP address."))
e.datatype="portrange"
e.rmempty=true
e.placeholder=translate('Do not rewrite')
t:option(Value,"extra",
translate("Extra arguments"),
translate("Passes additional arguments to iptables. Use with care!"))
else
local o=a:get(arg[1],"name")or a:get(arg[1],"_name")
if not o or#o==0 then
o=translate("(Unnamed Rule)")
end
a.title="%s - %s"%{translate("Firewall - Traffic Rules"),o}
t=a:section(NamedSection,arg[1],"rule","")
t.anonymous=true
t.addremove=false
i.opt_enabled(t,Button)
i.opt_name(t,Value,translate("Name"))
e=t:option(ListValue,"family",translate("Restrict to address family"))
e.rmempty=true
e:value("",translate("IPv4 and IPv6"))
e:value("ipv4",translate("IPv4 only"))
e:value("ipv6",translate("IPv6 only"))
e=t:option(Value,"proto",translate("Protocol"))
e:value("all",translate("Any"))
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
e=t:option(DynamicList,"icmp_type",translate("Match ICMP type"))
e:value("","any")
e:value("echo-reply")
e:value("destination-unreachable")
e:value("network-unreachable")
e:value("host-unreachable")
e:value("protocol-unreachable")
e:value("port-unreachable")
e:value("fragmentation-needed")
e:value("source-route-failed")
e:value("network-unknown")
e:value("host-unknown")
e:value("network-prohibited")
e:value("host-prohibited")
e:value("TOS-network-unreachable")
e:value("TOS-host-unreachable")
e:value("communication-prohibited")
e:value("host-precedence-violation")
e:value("precedence-cutoff")
e:value("source-quench")
e:value("redirect")
e:value("network-redirect")
e:value("host-redirect")
e:value("TOS-network-redirect")
e:value("TOS-host-redirect")
e:value("echo-request")
e:value("router-advertisement")
e:value("router-solicitation")
e:value("time-exceeded")
e:value("ttl-zero-during-transit")
e:value("ttl-zero-during-reassembly")
e:value("parameter-problem")
e:value("ip-header-bad")
e:value("required-option-missing")
e:value("timestamp-request")
e:value("timestamp-reply")
e:value("address-mask-request")
e:value("address-mask-reply")
e=t:option(Value,"src",translate("Source zone"))
e.nocreate=true
e.allowany=true
e.default="wan"
e.template="cbi/firewall_zonelist"
e=t:option(Value,"src_mac",translate("Source MAC address"))
e.datatype="list(macaddr)"
e.placeholder=translate("any")
luci.sys.net.mac_hints(function(t,a)
e:value(t,"%s (%s)"%{t,a})
end)
e=t:option(Value,"src_ip",translate("Source address"))
e.datatype="neg(ipmask)"
e.placeholder=translate("any")
luci.sys.net.ipv4_hints(function(t,a)
e:value(t,"%s (%s)"%{t,a})
end)
e=t:option(Value,"src_port",translate("Source port"))
e.datatype="list(neg(portrange))"
e.placeholder=translate("any")
e=t:option(Value,"dest",translate("Destination zone"))
e.nocreate=true
e.allowany=true
e.allowlocal=true
e.template="cbi/firewall_zonelist"
e=t:option(Value,"dest_ip",translate("Destination address"))
e.datatype="neg(ipmask)"
e.placeholder=translate("any")
luci.sys.net.ipv4_hints(function(t,a)
e:value(t,"%s (%s)"%{t,a})
end)
e=t:option(Value,"dest_port",translate("Destination port"))
e.datatype="list(neg(portrange))"
e.placeholder=translate("any")
e=t:option(ListValue,"target",translate("Action"))
e.default="ACCEPT"
e:value("DROP",translate("drop"))
e:value("ACCEPT",translate("accept"))
e:value("REJECT",translate("reject"))
e:value("NOTRACK",translate("don't track"))
t:option(Value,"extra",
translate("Extra arguments"),
translate("Passes additional arguments to iptables. Use with care!"))
end
e=t:option(MultiValue,"weekdays",translate("Week Days"))
e.oneline=true
e.widget="checkbox"
e:value("Sun",translate("Sunday"))
e:value("Mon",translate("Monday"))
e:value("Tue",translate("Tuesday"))
e:value("Wed",translate("Wednesday"))
e:value("Thu",translate("Thursday"))
e:value("Fri",translate("Friday"))
e:value("Sat",translate("Saturday"))
e=t:option(MultiValue,"monthdays",translate("Month Days"))
e.oneline=true
e.widget="checkbox"
for t=1,31 do
e:value(translate(t))
end
e=t:option(Value,"start_time",translate("Start Time (hh:mm:ss)"))
e.datatype="timehhmmss"
e=t:option(Value,"stop_time",translate("Stop Time (hh:mm:ss)"))
e.datatype="timehhmmss"
e=t:option(Value,"start_date",translate("Start Date (yyyy-mm-dd)"))
e.datatype="dateyyyymmdd"
e=t:option(Value,"stop_date",translate("Stop Date (yyyy-mm-dd)"))
e.datatype="dateyyyymmdd"
e=t:option(Flag,"utc_time",translate("Time in UTC"))
e.default=e.disabled
return a
