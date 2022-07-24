local a=require"luci.dispatcher"
local e=require"luci.tools.firewall"
m=Map("firewall",translate("Firewall - Port Forwards"),
translate("Port forwarding allows remote computers on the Internet to \
	           connect to a specific computer or service within the \
	           private LAN."))
s=m:section(TypedSection,"redirect",translate("Port Forwards"))
s.template="cbi/tblsection"
s.addremove=true
s.anonymous=true
s.sortable=true
s.extedit=a.build_url("admin/network/firewall/forwards/%s")
s.template_addremove="firewall/cbi_addforward"
function s.create(e,s)
local o=m:formvalue("_newfwd.name")
local t=m:formvalue("_newfwd.proto")
local h=m:formvalue("_newfwd.extzone")
local n=m:formvalue("_newfwd.extport")
local i=m:formvalue("_newfwd.intzone")
local a=m:formvalue("_newfwd.intaddr")
local r=m:formvalue("_newfwd.intport")
if t=="other"or(t and a)then
created=TypedSection.create(e,s)
e.map:set(created,"target","DNAT")
e.map:set(created,"src",h or"wan")
e.map:set(created,"dest",i or"lan")
e.map:set(created,"proto",(t~="other")and t or"all")
e.map:set(created,"src_dport",n)
e.map:set(created,"dest_ip",a)
e.map:set(created,"dest_port",r)
e.map:set(created,"name",o)
end
if t~="other"then
created=nil
end
end
function s.parse(e,...)
TypedSection.parse(e,...)
if created then
m.uci:save("firewall")
luci.http.redirect(a.build_url(
"admin/network/firewall/redirect",created
))
end
end
function s.filter(t,a)
return(t.map:get(a,"target")~="SNAT")
end
e.opt_name(s,DummyValue,translate("Name"))
local function h(a,t)
return"%s-%s"%{
translate("IPv4"),
e.fmt_proto(a.map:get(t,"proto"),
a.map:get(t,"icmp_type"))or"TCP+UDP"
}
end
local function r(o,t)
local n=e.fmt_zone(o.map:get(t,"src"),translate("any zone"))
local i=e.fmt_ip(o.map:get(t,"src_ip"),translate("any host"))
local a=e.fmt_port(o.map:get(t,"src_port"))
local e=e.fmt_mac(o.map:get(t,"src_mac"))
if a and e then
return translatef("From %s in %s with source %s and %s",i,n,a,e)
elseif a or e then
return translatef("From %s in %s with source %s",i,n,a or e)
else
return translatef("From %s in %s",i,n)
end
end
local function i(a,t)
local o=e.fmt_ip(a.map:get(t,"src_dip"),translate("any router IP"))
local e=e.fmt_port(a.map:get(t,"src_dport"))
if e then
return translatef("Via %s at %s",o,e)
else
return translatef("Via %s",o)
end
end
match=s:option(DummyValue,"match",translate("Match"))
match.rawhtml=true
match.width="50%"
function match.cfgvalue(e,t)
return"<small>%s<br />%s<br />%s</small>"%{
h(e,t),
r(e,t),
i(e,t)
}
end
dest=s:option(DummyValue,"dest",translate("Forward to"))
dest.rawhtml=true
dest.width="40%"
function dest.cfgvalue(t,a)
local o=e.fmt_zone(t.map:get(a,"dest"),translate("any zone"))
local i=e.fmt_ip(t.map:get(a,"dest_ip"),translate("any host"))
local t=e.fmt_port(t.map:get(a,"dest_port"))or
e.fmt_port(t.map:get(a,"src_dport"))
if t then
return translatef("%s, %s in %s",i,t,o)
else
return translatef("%s in %s",i,o)
end
end
e.opt_enabled(s,Flag,translate("Enable")).width="1%"
return m
