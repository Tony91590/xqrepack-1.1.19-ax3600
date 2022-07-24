module("luci.tools.firewall",package.seeall)
local i=require"luci.util"
local s=require"luci.ip"
local r=require"nixio"
local t,n=luci.i18n.translate,luci.i18n.translatef
local function e(...)
return tostring(t(...))
end
function fmt_neg(t)
if type(t)=="string"then
local a,o=t:gsub("^ *! *","")
if o>0 then
return a,"%s "%e("not")
else
return t,""
end
end
return t,""
end
function fmt_mac(a)
if a and#a>0 then
local t,o
local t={e("MAC")," "}
for e in i.imatch(a)do
e,o=fmt_neg(e)
t[#t+1]="<var>%s%s</var>"%{o,e}
t[#t+1]=", "
end
if#t>1 then
t[#t]=nil
if#t>3 then
t[1]=e("MACs")
end
return table.concat(t,"")
end
end
end
function fmt_port(a,s)
if a and#a>0 then
local t,o
local t={e("port")," "}
for a in i.imatch(a)do
a,o=fmt_neg(a)
local i,n=a:match("(%d+)%D+(%d+)")
if i and n then
t[1]=e("ports")
t[#t+1]="<var>%s%d-%d</var>"%{o,i,n}
else
t[#t+1]="<var>%s%d</var>"%{o,a}
end
t[#t+1]=", "
end
if#t>1 then
t[#t]=nil
if#t>3 then
t[1]=e("ports")
end
return table.concat(t,"")
end
end
return s and"<var>%s</var>"%s
end
function fmt_ip(o,h)
if o and#o>0 then
local a={e("IP")," "}
local h,t,n
for o in i.imatch(o)do
o,n=fmt_neg(o)
t,m=o:match("(%S+)/(%d+%.%S+)")
t=t or o
t=t:match(":")and s.IPv6(t,m)or s.IPv4(t,m)
if t and(t:is6()and t:prefix()<128 or t:prefix()<32)then
a[1]=e("IP range")
a[#a+1]="<var title='%s - %s'>%s%s</var>"%{
t:minhost():string(),
t:maxhost():string(),
n,t:string()
}
else
a[#a+1]="<var>%s%s</var>"%{
n,
t and t:string()or o
}
end
a[#a+1]=", "
end
if#a>1 then
a[#a]=nil
if#a>3 then
a[1]=e("IPs")
end
return table.concat(a,"")
end
end
return h and"<var>%s</var>"%h
end
function fmt_zone(t,a)
if t=="*"then
return"<var>%s</var>"%e("any zone")
elseif t and#t>0 then
return"<var>%s</var>"%t
elseif a then
return"<var>%s</var>"%a
end
end
function fmt_icmp_type(a)
if a and#a>0 then
local t,t,o
local t={e("type")," "}
for e in i.imatch(a)do
e,o=fmt_neg(e)
t[#t+1]="<var>%s%s</var>"%{o,e}
t[#t+1]=", "
end
if#t>1 then
t[#t]=nil
if#t>3 then
t[1]=e("types")
end
return table.concat(t,"")
end
end
end
function fmt_proto(t,o)
if t and#t>0 then
local e,a
local e={}
local o=fmt_icmp_type(o)
for t in i.imatch(t)do
t,a=fmt_neg(t)
if t=="tcpudp"then
e[#e+1]="TCP"
e[#e+1]=", "
e[#e+1]="UDP"
e[#e+1]=", "
elseif t~="all"then
local t=r.getproto(t)
if t then
if(t.proto==1 or t.proto==58)and o then
e[#e+1]=n(
"%s%s with %s",
a,t.aliases[1]or t.name,o
)
else
e[#e+1]="%s%s"%{
a,
t.aliases[1]or t.name
}
end
e[#e+1]=", "
end
end
end
if#e>0 then
e[#e]=nil
return table.concat(e,"")
end
end
end
function fmt_limit(i,a)
a=tonumber(a)
if i and#i>0 then
local o,t=i:match("(%d+)/(%w+)")
o=tonumber(o or i)
t=t or"second"
if o then
if t:match("^s")then
t=e("second")
elseif t:match("^m")then
t=e("minute")
elseif t:match("^h")then
t=e("hour")
elseif t:match("^d")then
t=e("day")
end
if a and a>0 then
return n("<var>%d</var> pkts. per <var>%s</var>, \
				    burst <var>%d</var> pkts.",o,t,a)
else
return n("<var>%d</var> pkts. per <var>%s</var>",o,t)
end
end
end
end
function fmt_target(t,a)
if a and#a>0 then
if t=="ACCEPT"then
return e("Accept forward")
elseif t=="REJECT"then
return e("Refuse forward")
elseif t=="NOTRACK"then
return e("Do not track forward")
else
return e("Discard forward")
end
else
if t=="ACCEPT"then
return e("Accept input")
elseif t=="REJECT"then
return e("Refuse input")
elseif t=="NOTRACK"then
return e("Do not track input")
else
return e("Discard input")
end
end
end
function opt_enabled(i,a,...)
if a==luci.cbi.Button then
local o=i:option(a,"__enabled")
function o.render(t,o)
if t.map:get(o,"enabled")~="0"then
t.title=e("Rule is enabled")
t.inputtitle=e("Disable")
t.inputstyle="reset"
else
t.title=e("Rule is disabled")
t.inputtitle=e("Enable")
t.inputstyle="apply"
end
a.render(t,o)
end
function o.write(e,t,a)
if e.map:get(t,"enabled")~="0"then
e.map:set(t,"enabled","0")
else
e.map:del(t,"enabled")
end
end
return o
else
local e=i:option(a,"enabled",...)
e.default="1"
return e
end
end
function opt_name(t,e,...)
local e=t:option(e,"name",...)
function e.cfgvalue(e,t)
return e.map:get(t,"name")or
e.map:get(t,"_name")or"-"
end
function e.write(e,t,a)
if a~="-"then
e.map:set(t,"name",a)
e.map:del(t,"_name")
else
e:remove(t)
end
end
function e.remove(t,e)
t.map:del(e,"name")
t.map:del(e,"_name")
end
return e
end
