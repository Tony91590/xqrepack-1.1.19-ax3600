local o=require"luci.dispatcher"
local e=require"luci.tools.firewall"
m=Map("firewall",
translate("Firewall - Traffic Rules"),
translate("Traffic rules define policies for packets traveling between \
		different zones, for example to reject traffic between certain hosts \
		or to open WAN ports on the router."))
s=m:section(TypedSection,"rule",translate("Traffic Rules"))
s.addremove=true
s.anonymous=true
s.sortable=true
s.template="cbi/tblsection"
s.extedit=o.build_url("admin/network/firewall/rules/%s")
s.defaults.target="ACCEPT"
s.template_addremove="firewall/cbi_addrule"
function s.create(t,e)
created=TypedSection.create(t,e)
end
function s.parse(t,...)
TypedSection.parse(t,...)
local n=m:formvalue("_newopen.name")
local a=m:formvalue("_newopen.proto")
local i=m:formvalue("_newopen.extport")
local s=m:formvalue("_newopen.submit")
local h=m:formvalue("_newfwd.name")
local r=m:formvalue("_newfwd.src")
local l=m:formvalue("_newfwd.dest")
local d=m:formvalue("_newfwd.submit")
if s then
created=TypedSection.create(t,section)
t.map:set(created,"target","ACCEPT")
t.map:set(created,"src","wan")
t.map:set(created,"proto",(a~="other")and a or"all")
t.map:set(created,"dest_port",i)
t.map:set(created,"name",n)
if a~="other"and i and#i>0 then
created=nil
end
elseif d then
created=TypedSection.create(t,section)
t.map:set(created,"target","ACCEPT")
t.map:set(created,"src",r)
t.map:set(created,"dest",l)
t.map:set(created,"name",h)
end
if created then
m.uci:save("firewall")
luci.http.redirect(o.build_url(
"admin/network/firewall/rules",created
))
end
end
e.opt_name(s,DummyValue,translate("Name"))
local function h(o,a)
local t=o.map:get(a,"family")
local e=e.fmt_proto(o.map:get(a,"proto"),
o.map:get(a,"icmp_type"))or translate("traffic")
if t and t:match("4")then
return"%s-%s"%{translate("IPv4"),e}
elseif t and t:match("6")then
return"%s-%s"%{translate("IPv6"),e}
else
return"%s %s"%{translate("Any"),e}
end
end
local function r(t,a)
local i=e.fmt_zone(t.map:get(a,"src"),translate("any zone"))
local n=e.fmt_ip(t.map:get(a,"src_ip"),translate("any host"))
local o=e.fmt_port(t.map:get(a,"src_port"))
local e=e.fmt_mac(t.map:get(a,"src_mac"))
if o and e then
return translatef("From %s in %s with source %s and %s",n,i,o,e)
elseif o or e then
return translatef("From %s in %s with source %s",n,i,o or e)
else
return translatef("From %s in %s",n,i)
end
end
local function n(o,t)
local i=e.fmt_zone(o.map:get(t,"dest"))
local a=e.fmt_port(o.map:get(t,"dest_port"))
if i then
local e=e.fmt_ip(o.map:get(t,"dest_ip"),translate("any host"))
if a then
return translatef("To %s, %s in %s",e,a,i)
else
return translatef("To %s in %s",e,i)
end
else
local e=e.fmt_ip(o.map:get(t,"dest_ip"),
translate("any router IP"))
if a then
return translatef("To %s at %s on <var>this device</var>",e,a)
else
return translatef("To %s on <var>this device</var>",e)
end
end
end
local function d(t,a)
local i=e.fmt_zone(t.map:get(a,"dest"),translate("any zone"))
local o=e.fmt_ip(t.map:get(a,"dest_ip"),translate("any host"))
local e=e.fmt_port(t.map:get(a,"dest_port"))or
e.fmt_port(t.map:get(a,"src_dport"))
if e then
return translatef("To %s, %s in %s",o,e,i)
else
return translatef("To %s in %s",o,i)
end
end
match=s:option(DummyValue,"match",translate("Match"))
match.rawhtml=true
match.width="70%"
function match.cfgvalue(t,e)
return"<small>%s<br />%s<br />%s</small>"%{
h(t,e),
r(t,e),
n(t,e)
}
end
target=s:option(DummyValue,"target",translate("Action"))
target.rawhtml=true
target.width="20%"
function target.cfgvalue(t,a)
local o=e.fmt_target(t.map:get(a,"target"),t.map:get(a,"dest"))
local t=e.fmt_limit(t.map:get(a,"limit"),
t.map:get(a,"limit_burst"))
if t then
return translatef("<var>%s</var> and limit to %s",o,t)
else
return"<var>%s</var>"%o
end
end
e.opt_enabled(s,Flag,translate("Enable")).width="1%"
s=m:section(TypedSection,"redirect",
translate("Source NAT"),
translate("Source NAT is a specific form of masquerading which allows \
		fine grained control over the source IP used for outgoing traffic, \
		for example to map multiple WAN addresses to internal subnets."))
s.template="cbi/tblsection"
s.addremove=true
s.anonymous=true
s.sortable=true
s.extedit=o.build_url("admin/network/firewall/rules/%s")
s.template_addremove="firewall/cbi_addsnat"
function s.create(e,t)
created=TypedSection.create(e,t)
end
function s.parse(e,...)
TypedSection.parse(e,...)
local s=m:formvalue("_newsnat.name")
local n=m:formvalue("_newsnat.src")
local h=m:formvalue("_newsnat.dest")
local t=m:formvalue("_newsnat.dip")
local a=m:formvalue("_newsnat.dport")
local i=m:formvalue("_newsnat.submit")
if i and t and#t>0 then
created=TypedSection.create(e,section)
e.map:set(created,"target","SNAT")
e.map:set(created,"src",n)
e.map:set(created,"dest",h)
e.map:set(created,"proto","all")
e.map:set(created,"src_dip",t)
e.map:set(created,"src_dport",a)
e.map:set(created,"name",s)
end
if created then
m.uci:save("firewall")
luci.http.redirect(o.build_url(
"admin/network/firewall/rules",created
))
end
end
function s.filter(a,t)
return(a.map:get(t,"target")=="SNAT")
end
e.opt_name(s,DummyValue,translate("Name"))
match=s:option(DummyValue,"match",translate("Match"))
match.rawhtml=true
match.width="70%"
function match.cfgvalue(t,e)
return"<small>%s<br />%s<br />%s</small>"%{
h(t,e),
r(t,e),
d(t,e)
}
end
snat=s:option(DummyValue,"via",translate("Action"))
snat.rawhtml=true
snat.width="20%"
function snat.cfgvalue(o,a)
local t=e.fmt_ip(o.map:get(a,"src_dip"))
local a=e.fmt_port(o.map:get(a,"src_dport"))
if t and a then
return translatef("Rewrite to source %s, %s",t,a)
else
return translatef("Rewrite to source %s",t or a)
end
end
e.opt_enabled(s,Flag,translate("Enable")).width="1%"
return m
