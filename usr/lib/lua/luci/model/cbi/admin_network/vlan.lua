m=Map("network",translate("Switch"),translate("The network ports on this device can be combined to several <abbr title=\"Virtual Local Area Network\">VLAN</abbr>s in which computers can communicate directly with each other. <abbr title=\"Virtual Local Area Network\">VLAN</abbr>s are often used to separate different network segments. Often there is by default one Uplink port for a connection to the next greater network like the internet and other ports for a local network."))
local e=require"nixio.fs"
local e=require"luci.model.network"
local c={}
e.init(m.uci)
local f=e:get_switch_topologies()or{}
local v=function(n,o)
local t={}
m.uci:foreach("network","interface",function(a)
local s=m.uci:get("network",a[".name"],"ifname")
local e={}
local i
local i=false
for t in luci.util.imatch(s)do
if t==n then
e[#e+1]=o
i=true
else
e[#e+1]=t
end
end
if i then
m.uci:set("network",a[".name"],"ifname",table.concat(e," "))
t[#t+1]=translatef("Interface %q device auto-migrated from %q to %q.",
a[".name"],n,o)
end
end)
if#t>0 then
m.message=(m.message and m.message.."\n"or"")..table.concat(t,"\n")
end
end
m.uci:foreach("network","switch",
function(o)
local p=o['.name']
local t=o.name or p
local d=nil
local r=nil
local a=nil
local u=nil
local y=nil
local h=0
local e=16
local l=16
local i
local w=false
local n=f[t]
if not n then
m.message=translatef("Switch %q has an unknown topology - the VLAN settings might not be accurate.",t)
n={
ports={
{num=0,label="Port 1"},
{num=1,label="Port 2"},
{num=2,label="Port 3"},
{num=3,label="Port 4"},
{num=4,label="Port 5"},
{num=5,label="CPU (eth0)",tagged=false}
}
}
end
local f=io.popen("swconfig dev %q help 2>/dev/null"%t)
if f then
local o=false
local t=false
while true do
local e=f:read("*l")
if not e then break end
if e:match("^%s+%-%-vlan")then
t=true
elseif e:match("^%s+%-%-port")then
t=false
o=true
elseif e:match("cpu @")then
i=e:match("^switch%d: %w+%((.-)%)")
l=tonumber(e:match("vlans: (%d+)"))or 16
h=1
elseif e:match(": pvid")or e:match(": tag")or e:match(": vid")then
if t then a=e:match(": (%w+)")end
elseif e:match(": enable_vlan4k")then
w=true
elseif e:match(": enable_vlan")then
d="enable_vlan"
elseif e:match(": enable_learning")then
r="enable_learning"
elseif e:match(": enable_mirror_rx")then
y="enable_mirror_rx"
elseif e:match(": max_length")then
u="max_length"
end
end
f:close()
end
s=m:section(NamedSection,o['.name'],"switch",
i and translatef("Switch %q (%s)",t,i)
or translatef("Switch %q",t))
s.addremove=false
if d then
s:option(Flag,d,translate("Enable VLAN functionality"))
end
if r then
o=s:option(Flag,r,translate("Enable learning and aging"))
o.default=o.enabled
end
if u then
o=s:option(Flag,u,translate("Enable Jumbo Frame passthrough"))
o.enabled="3"
o.rmempty=true
end
if y then
s:option(Flag,"enable_mirror_rx",translate("Enable mirroring of incoming packets"))
s:option(Flag,"enable_mirror_tx",translate("Enable mirroring of outgoing packets"))
local a=s:option(ListValue,"mirror_source_port",translate("Mirror source port"))
local t=s:option(ListValue,"mirror_monitor_port",translate("Mirror monitor port"))
a:depends("enable_mirror_tx","1")
a:depends("enable_mirror_rx","1")
t:depends("enable_mirror_tx","1")
t:depends("enable_mirror_rx","1")
local e,e
for o,e in ipairs(n.ports)do
a:value(e.num,e.label)
t:value(e.num,e.label)
end
end
s=m:section(TypedSection,"switch_vlan",
i and translatef("VLANs on %q (%s)",t,i)
or translatef("VLANs on %q",t))
s.template="cbi/tblsection"
s.addremove=true
s.anonymous=true
s.filter=function(a,e)
local e=m:get(e,"device")
return(e and e==t)
end
s.cfgsections=function(e)
local e=TypedSection.cfgsections(e)
local t={}
local o
for a,e in luci.util.spairs(
e,
function(t,o)
return(tonumber(m:get(e[t],a or"vlan"))or 9999)
<(tonumber(m:get(e[o],a or"vlan"))or 9999)
end
)do
t[#t+1]=e
end
return t
end
s.create=function(e,o,i)
if m:get(i,"device")~=t then
return
end
local e=TypedSection.create(e,o)
local n=0
local o=0
m.uci:foreach("network","switch_vlan",
function(i)
if i.device==t then
local e=tonumber(i.vlan)
local t=a and tonumber(i[a])
if e~=nil and e>n then n=e end
if t~=nil and t>o then o=t end
end
end)
m:set(e,"device",t)
m:set(e,"vlan",n+1)
if a then
m:set(e,a,o+1)
end
return e
end
local i={}
local o={}
local d=function(a,e)
local t
for e in(m:get(e,"ports")or""):gmatch("%w+")do
local t,e=e:match("^(%d+)([tu]*)")
if t==a.option then return(#e>0)and e or"u"end
end
return""
end
local r=function(e,t,a)
if t=="u"then
if not o[e.option]then
o[e.option]=true
else
return nil,
translatef("%s is untagged in multiple VLANs!",e.title)
end
end
return t
end
local o=s:option(Value,a or"vlan","VLAN ID","<div id='portstatus-%s'></div>"%t)
local e=a and 4094 or(l-1)
o.rmempty=false
o.forcewrite=true
o.vlan_used={}
o.datatype="and(uinteger,range("..h..","..e.."))"
o.validate=function(t,i,e)
local e=tonumber(i)
local a=a and 4094 or(l-1)
if e~=nil and e>=h and e<=a then
if not t.vlan_used[e]then
t.vlan_used[e]=true
return i
else
return nil,
translatef("Invalid VLAN ID given! Only unique IDs are allowed")
end
else
return nil,
translatef("Invalid VLAN ID given! Only IDs between %d and %d are allowed.",h,a)
end
end
o.write=function(s,t,n)
local e
local a={}
for o,e in ipairs(i)do
local o=e:formvalue(t)
if o=="t"then
a[#a+1]=e.option..o
elseif o=="u"then
a[#a+1]=e.option
end
if e.info and e.info.device then
local a=e:cfgvalue(t)
local t=s:cfgvalue(t)
if a~=o or t~=n then
local t=(a=="u")and e.info.device
or"%s.%s"%{e.info.device,t}
local e=(o=="u")and e.info.device
or"%s.%s"%{e.info.device,n}
if t~=e then
v(t,e)
end
end
end
end
if w then
m:set(p,"enable_vlan4k","1")
end
m:set(t,"ports",table.concat(a," "))
return Value.write(s,t,n)
end
o.cfgvalue=function(t,e)
return m:get(e,a or"vlan")
or m:get(e,"vlan")
end
local e,e
for e,a in ipairs(n.ports)do
local e=s:option(ListValue,tostring(a.num),a.label,'<div id="portstatus-%s-%d"></div>'%{t,a.num})
e:value("",translate("off"))
if not a.tagged then
e:value("u",translate("untagged"))
end
e:value("t",translate("tagged"))
e.cfgvalue=d
e.validate=r
e.write=function()end
e.info=a
i[#i+1]=e
end
table.sort(i,function(t,e)return t.option<e.option end)
c[#c+1]=t
end
)
s=m:section(SimpleSection)
s.template="admin_network/switch_status"
s.switches=c
return m
