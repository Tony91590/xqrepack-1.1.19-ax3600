local t,e,t=...
local d,u,l
local n,o,r,i,
a,t,h,s
d=e:taboption("general",Value,"server",translate("VPN Server"))
d.datatype="host(0)"
u=e:taboption("general",Value,"username",translate("PAP/CHAP username"))
l=e:taboption("general",Value,"password",translate("PAP/CHAP password"))
l.password=true
n=e:taboption("advanced",Flag,"defaultroute",
translate("Use default gateway"),
translate("If unchecked, no default route is configured"))
n.default=n.enabled
o=e:taboption("advanced",Value,"metric",
translate("Use gateway metric"))
o.placeholder="0"
o.datatype="uinteger"
o:depends("defaultroute",n.enabled)
r=e:taboption("advanced",Flag,"peerdns",
translate("Use DNS servers advertised by peer"),
translate("If unchecked, the advertised DNS server addresses are ignored"))
r.default=r.enabled
i=e:taboption("advanced",DynamicList,"dns",
translate("Use custom DNS servers"))
i:depends("peerdns","")
i.datatype="ipaddr"
i.cast="string"
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
s=e:taboption("advanced",Value,"mtu",translate("Override MTU"))
s.placeholder="1500"
s.datatype="max(9200)"
