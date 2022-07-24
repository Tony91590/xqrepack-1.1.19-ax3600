module("luci.tools.webadmin",package.seeall)
local s=require"luci.util"
local n=require"luci.model.uci"
local i=require"luci.ip"
function byte_format(e)
local a={"B","KB","MB","GB","TB"}
for t=1,5 do
if e>1024 and t<5 then
e=e/1024
else
return string.format("%.2f %s",e,a[t])
end
end
end
function date_format(e)
local t={"min","h","d"}
local t=0
local a=0
local o=0
e=math.floor(e)
if e>60 then
t=math.floor(e/60)
e=e%60
end
if t>60 then
a=math.floor(t/60)
t=t%60
end
if a>24 then
o=math.floor(a/24)
a=a%24
end
if o>0 then
return string.format("%.0fd %02.0fh %02.0fmin %02.0fs",o,a,t,e)
else
return string.format("%02.0fh %02.0fmin %02.0fs",a,t,e)
end
end
function cbi_add_networks(t)
n.cursor():foreach("network","interface",
function(e)
if e[".name"]~="loopback"then
t:value(e[".name"])
end
end
)
t.titleref=luci.dispatcher.build_url("admin","network","network")
end
function cbi_add_knownips(t)
local e,e
for a,e in ipairs(i.neighbors({family=4}))do
if e.dest then
t:value(e.dest:string())
end
end
end
function firewall_find_zone(a)
local t
luci.model.uci.cursor():foreach("firewall","zone",
function(e)
if e.name==a then
t=e[".name"]
end
end
)
return t
end
function iface_get_network(e)
local t=i.link(tostring(e))
if t.master then
e=t.master
end
local a=n.cursor()
local t=s.ubus("network.interface","dump",{})
if t then
local o,o
for o,t in ipairs(t.interface)do
if t.l3_device==e or t.device==e then
local e=a:get("network",t.interface,"ifname")
if type(e)=="string"and e:sub(1,1)~="@"or e then
return t.interface
end
end
end
end
end
