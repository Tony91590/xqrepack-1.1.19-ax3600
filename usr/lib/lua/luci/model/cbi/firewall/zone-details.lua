local e=require"luci.model.network"
local l=require"luci.model.firewall"
local y=require"luci.dispatcher"
local f=require"luci.util"
local a,w,t,t
local t,r,n,d,h,s,m,c
local u,o,i
a=Map("firewall",translate("Firewall - Zone Settings"))
a.redirect=luci.dispatcher.build_url("admin/network/firewall/zones")
l.init(a.uci)
e.init(a.uci)
local e=l:get_zone(arg[1])
if not e then
luci.http.redirect(y.build_url("admin/network/firewall/zones"))
return
else
a.title="%s - %s"%{
translate("Firewall - Zone Settings"),
translatef("Zone %q",e:name()or"?")
}
end
t=a:section(NamedSection,e.sid,"zone",
translatef("Zone %q",e:name()),
translatef("This section defines common properties of %q. \
		The <em>input</em> and <em>output</em> options set the default \
		policies for traffic entering and leaving this zone while the \
		<em>forward</em> option describes the policy for forwarded traffic \
		between different networks within the zone. \
		<em>Covered networks</em> specifies which available networks are \
		members of this zone.",e:name()))
t.anonymous=true
t.addremove=false
a.on_commit=function(e)
local e=l:get_zone(arg[1])
if e then
t.section=e.sid
u.section=e.sid
end
end
t:tab("general",translate("General Settings"))
t:tab("advanced",translate("Advanced Settings"))
r=t:taboption("general",Value,"name",translate("Name"))
r.optional=false
r.forcewrite=true
r.datatype="and(uciname,maxlength(11))"
function r.write(a,a,t)
if e:name()~=t then
l:rename_zone(e:name(),t)
o.exclude=t
i.exclude=t
end
end
w={
t:taboption("general",ListValue,"input",translate("Input")),
t:taboption("general",ListValue,"output",translate("Output")),
t:taboption("general",ListValue,"forward",translate("Forward"))
}
for a,e in ipairs(w)do
e:value("REJECT",translate("reject"))
e:value("DROP",translate("drop"))
e:value("ACCEPT",translate("accept"))
end
t:taboption("general",Flag,"masq",translate("Masquerading"))
t:taboption("general",Flag,"mtu_fix",translate("MSS clamping"))
n=t:taboption("general",Value,"network",translate("Covered networks"))
n.template="cbi/network_netlist"
n.widget="checkbox"
n.cast="string"
function n.formvalue(t,e)
return Value.formvalue(t,e)or"-"
end
function n.cfgvalue(t,e)
return Value.cfgvalue(t,e)or r:cfgvalue(e)
end
function n.write(a,a,t)
e:clear_networks()
local a
for t in f.imatch(t)do
e:add_network(t)
end
end
d=t:taboption("advanced",ListValue,"family",
translate("Restrict to address family"))
d.rmempty=true
d:value("",translate("IPv4 and IPv6"))
d:value("ipv4",translate("IPv4 only"))
d:value("ipv6",translate("IPv6 only"))
h=t:taboption("advanced",DynamicList,"masq_src",
translate("Restrict Masquerading to given source subnets"))
h.optional=true
h.datatype="list(neg(or(uciname,hostname,ipmask4)))"
h.placeholder="0.0.0.0/0"
h:depends("family","")
h:depends("family","ipv4")
s=t:taboption("advanced",DynamicList,"masq_dest",
translate("Restrict Masquerading to given destination subnets"))
s.optional=true
s.datatype="list(neg(or(uciname,hostname,ipmask4)))"
s.placeholder="0.0.0.0/0"
s:depends("family","")
s:depends("family","ipv4")
t:taboption("advanced",Flag,"conntrack",
translate("Force connection tracking"))
m=t:taboption("advanced",Flag,"log",
translate("Enable logging on this zone"))
m.rmempty=true
m.enabled="1"
c=t:taboption("advanced",Value,"log_limit",
translate("Limit log messages"))
c.placeholder="10/minute"
c:depends("log","1")
u=a:section(NamedSection,e.sid,"fwd_out",
translate("Inter-Zone Forwarding"),
translatef("The options below control the forwarding policies between \
		this zone (%s) and other zones. <em>Destination zones</em> cover \
		forwarded traffic <strong>originating from %q</strong>. \
		<em>Source zones</em> match forwarded traffic from other zones \
		<strong>targeted at %q</strong>. The forwarding rule is \
		<em>unidirectional</em>, e.g. a forward from lan to wan does \
		<em>not</em> imply a permission to forward from wan to lan as well.",
e:name(),e:name(),e:name()
))
o=u:option(Value,"out",
translate("Allow forward to <em>destination zones</em>:"))
o.nocreate=true
o.widget="checkbox"
o.exclude=e:name()
o.template="cbi/firewall_zonelist"
i=u:option(Value,"in",
translate("Allow forward from <em>source zones</em>:"))
i.nocreate=true
i.widget="checkbox"
i.exclude=e:name()
i.template="cbi/firewall_zonelist"
function o.cfgvalue(t,t)
local t={}
local a
for a,e in ipairs(e:get_forwardings_by("src"))do
t[#t+1]=e:dest()
end
return table.concat(t," ")
end
function i.cfgvalue(t,t)
local t={}
local a
for a,e in ipairs(e:get_forwardings_by("dest"))do
t[#t+1]=e:src()
end
return t
end
function o.formvalue(e,t)
return Value.formvalue(e,t)or"-"
end
function i.formvalue(t,e)
return Value.formvalue(t,e)or"-"
end
function o.write(a,a,t)
e:del_forwardings_by("src")
local a
for t in f.imatch(t)do
e:add_forwarding_to(t)
end
end
function i.write(a,a,t)
e:del_forwardings_by("dest")
local a
for t in f.imatch(t)do
e:add_forwarding_from(t)
end
end
return a
