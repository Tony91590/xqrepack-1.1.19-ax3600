local t,e,t=...
local f,u,l,c
local o,i,n,d,s,
a,t,h,r
f=e:taboption("general",Value,"username",translate("PAP/CHAP username"))
u=e:taboption("general",Value,"password",translate("PAP/CHAP password"))
u.password=true
l=e:taboption("general",Value,"ac",
translate("Access Concentrator"),
translate("Leave empty to autodetect"))
l.placeholder=translate("auto")
c=e:taboption("general",Value,"service",
translate("Service Name"),
translate("Leave empty to autodetect"))
c.placeholder=translate("auto")
if luci.model.network:has_ipv6()then
o=e:taboption("advanced",ListValue,"ipv6",
translate("Obtain IPv6-Address"),
translate("Enable IPv6 negotiation on the PPP link"))
o:value("auto",translate("Automatic"))
o:value("0",translate("Disabled"))
o:value("1",translate("Manual"))
o.default="auto"
end
i=e:taboption("advanced",Flag,"defaultroute",
translate("Use default gateway"),
translate("If unchecked, no default route is configured"))
i.default=i.enabled
n=e:taboption("advanced",Value,"metric",
translate("Use gateway metric"))
n.placeholder="0"
n.datatype="uinteger"
n:depends("defaultroute",i.enabled)
d=e:taboption("advanced",Flag,"peerdns",
translate("Use DNS servers advertised by peer"),
translate("If unchecked, the advertised DNS server addresses are ignored"))
d.default=d.enabled
s=e:taboption("advanced",DynamicList,"dns",
translate("Use custom DNS servers"))
s:depends("peerdns","")
s.datatype="ipaddr"
s.cast="string"
a=e:taboption("advanced",Value,"_keepalive_failure",
translate("LCP echo failure threshold"),
translate("Presume peer to be dead after given amount of LCP echo failures, use 0 to ignore failures"))
function a.cfgvalue(t,e)
local e=m:get(e,"keepalive")
if e and#e>0 then
return tonumber(e:match("^(%d+)[ ,]+%d+")or e)
end
end
a.placeholder="0"
a.datatype="uinteger"
t=e:taboption("advanced",Value,"_keepalive_interval",
translate("LCP echo interval"),
translate("Send LCP echo requests at the given interval in seconds, only effective in conjunction with failure threshold"))
function t.cfgvalue(t,e)
local e=m:get(e,"keepalive")
if e and#e>0 then
return tonumber(e:match("^%d+[ ,]+(%d+)"))
end
end
function t.write(o,e,i)
local o=tonumber(a:formvalue(e))or 0
local a=tonumber(i)or 5
if a<1 then a=1 end
if o>0 then
m:set(e,"keepalive","%d %d"%{o,a})
else
m:set(e,"keepalive","0")
end
end
t.remove=t.write
a.write=t.write
a.remove=t.write
t.placeholder="5"
t.datatype="min(1)"
h=e:taboption("advanced",Value,"demand",
translate("Inactivity timeout"),
translate("Close inactive connection after the given amount of seconds, use 0 to persist connection"))
h.placeholder="0"
h.datatype="uinteger"
r=e:taboption("advanced",Value,"mtu",translate("Override MTU"))
r.placeholder="1500"
r.datatype="max(9200)"
