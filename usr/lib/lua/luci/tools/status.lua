module("luci.tools.status",package.seeall)
local s=require"luci.model.uci".cursor()
local function c(o)
local e={}
local r=require"nixio.fs"
local t="/tmp/dhcp.leases"
s:foreach("dhcp","dnsmasq",
function(e)
if e.leasefile and r.access(e.leasefile)then
t=e.leasefile
return false
end
end)
local n=io.open(t,"r")
if n then
while true do
local t=n:read("*l")
if not t then
break
else
local h,s,t,a,n=t:match("^(%d+) (%S+) (%S+) (%S+) (%S+)")
local i=tonumber(h)or 0
if h and s and t and a and n then
if o==4 and not t:match(":")then
e[#e+1]={
expires=(i~=0)and os.difftime(i,os.time()),
macaddr=s,
ipaddr=t,
hostname=(a~="*")and a
}
elseif o==6 and t:match(":")then
e[#e+1]={
expires=(i~=0)and os.difftime(i,os.time()),
ip6addr=t,
duid=(n~="*")and n,
hostname=(a~="*")and a
}
end
end
end
end
n:close()
end
local t="/tmp/hosts/odhcpd"
s:foreach("dhcp","odhcpd",
function(e)
if e.leasefile and r.access(e.leasefile)then
t=e.leasefile
return false
end
end)
local l=io.open(t,"r")
if l then
while true do
local t=l:read("*l")
if not t then
break
else
local h,t,s,n,i,h,h,a=t:match("^# (%S+) (%S+) (%S+) (%S+) (-?%d+) (%S+) (%S+) (.*)")
local i=tonumber(i)or 0
if a and s~="ipv4"and o==6 then
e[#e+1]={
expires=(i>=0)and os.difftime(i,os.time()),
duid=t,
ip6addr=a,
hostname=(n~="-")and n
}
elseif a and s=="ipv4"and o==4 then
local s,o,d,h,u,l,r
if t and type(t)=="string"then
o,d,h,u,l,r=t:match("^(%x%x)(%x%x)(%x%x)(%x%x)(%x%x)(%x%x)$")
end
if not(o and d and h and u and l and r)then
s="FF:FF:FF:FF:FF:FF"
else
s=o..":"..d..":"..h..":"..u..":"..l..":"..r
end
e[#e+1]={
expires=(i>=0)and os.difftime(i,os.time()),
macaddr=t,
macaddr=s:lower(),
ipaddr=a,
hostname=(n~="-")and n
}
end
end
end
l:close()
end
return e
end
function dhcp_leases()
return c(4)
end
function dhcp6_leases()
return c(6)
end
function wifi_networks()
local o={}
local e=require"luci.model.network".init()
local t
for e,t in ipairs(e:get_wifidevs())do
local a={
up=t:is_up(),
device=t:name(),
name=t:get_i18n(),
networks={}
}
local e
for i,e in ipairs(t:get_wifinets())do
a.networks[#a.networks+1]={
name=e:shortname(),
link=e:adminlink(),
up=e:is_up(),
mode=e:active_mode(),
ssid=e:active_ssid(),
bssid=e:active_bssid(),
encryption=e:active_encryption(),
frequency=e:frequency(),
channel=e:channel(),
signal=e:signal(),
quality=e:signal_percent(),
noise=e:noise(),
bitrate=e:bitrate(),
ifname=e:ifname(),
assoclist=e:assoclist(),
country=e:country(),
txpower=e:txpower(),
txpoweroff=e:txpower_offset(),
disabled=(t:get("disabled")=="1"or
e:get("disabled")=="1")
}
end
o[#o+1]=a
end
return o
end
function wifi_network(a)
local e=require"luci.model.network".init()
local e=e:get_wifinet(a)
if e then
local t=e:get_device()
if t then
return{
id=a,
name=e:shortname(),
link=e:adminlink(),
up=e:is_up(),
mode=e:active_mode(),
ssid=e:active_ssid(),
bssid=e:active_bssid(),
encryption=e:active_encryption(),
frequency=e:frequency(),
channel=e:channel(),
signal=e:signal(),
quality=e:signal_percent(),
noise=e:noise(),
bitrate=e:bitrate(),
ifname=e:ifname(),
assoclist=e:assoclist(),
country=e:country(),
txpower=e:txpower(),
txpoweroff=e:txpower_offset(),
disabled=(t:get("disabled")=="1"or
e:get("disabled")=="1"),
device={
up=t:is_up(),
device=t:name(),
name=t:get_i18n()
}
}
end
end
return{}
end
function switch_status(e)
local t
local i={}
for o in e:gmatch("[^%s,]+")do
local a={}
local t=io.popen("swconfig dev %q show"%o,"r")
if t then
local e
repeat
e=t:read("*l")
if e then
local t,i=e:match("port:(%d+) link:(%w+)")
if t then
local s=e:match(" speed:(%d+)")
local n=e:match(" (%w+)-duplex")
local o=e:match(" (txflow)")
local h=e:match(" (rxflow)")
local e=e:match(" (auto)")
a[#a+1]={
port=tonumber(t)or 0,
speed=tonumber(s)or 0,
link=(i=="up"),
duplex=(n=="full"),
rxflow=(not not h),
txflow=(not not o),
auto=(not not e)
}
end
end
until not e
t:close()
end
i[o]=a
end
return i
end
