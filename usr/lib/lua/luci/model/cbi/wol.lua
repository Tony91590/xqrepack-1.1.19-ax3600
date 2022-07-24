local e=require"luci.sys"
local a=require"nixio.fs"
m=SimpleForm("wol",translate("Wake on LAN"),
translate("Wake on LAN is a mechanism to remotely boot computers in the local network."))
m.submit=translate("Wake up host")
m.reset=false
local t=a.access("/usr/bin/etherwake")
local a=a.access("/usr/bin/wol")
s=m:section(SimpleSection)
if t and a then
bin=s:option(ListValue,"binary",translate("WoL program"),
translate("Sometimes only one of the two tools works. If one fails, try the other one"))
bin:value("/usr/bin/etherwake","Etherwake")
bin:value("/usr/bin/wol","WoL")
end
if t then
iface=s:option(ListValue,"iface",translate("Network interface to use"),
translate("Specifies the interface the WoL packet is sent on"))
if a then
iface:depends("binary","/usr/bin/etherwake")
end
iface:value("",translate("Broadcast on all interfaces"))
for t,e in ipairs(e.net.devices())do
if e~="lo"then iface:value(e)end
end
iface.default="br-lan"
end
host=s:option(Value,"mac",translate("Host to wake up"),
translate("Choose the host to wake up or enter a custom MAC address to use"))
e.net.mac_hints(function(e,t)
host:value(e,"%s (%s)"%{e,t})
end)
function host.write(e,e,e)
local e=luci.http.formvalue("cbid.wol.1.mac")
if e and#e>0 and e:match("^[a-fA-F0-9:]+$")then
local a
local t=luci.http.formvalue("cbid.wol.1.binary")or(
t and"/usr/bin/etherwake"or"/usr/bin/wol"
)
if t=="/usr/bin/etherwake"then
local o=luci.http.formvalue("cbid.wol.1.iface")
a="%s -D%s %q"%{
t,(o~=""and" -i %q"%o or""),e
}
else
a="%s -v %q"%{t,e}
end
local t="<p><strong>%s</strong><br /><br /><code>%s<br /><br />"%{
translate("Starting WoL utility:"),a
}
local a=io.popen(a.." 2>&1")
if a then
while true do
local e=a:read("*l")
if e then
if#e>100 then e=e:sub(1,100).."..."end
t=t..e.."<br />"
else
break
end
end
a:close()
end
t=t.."</code></p>"
m.message=t
end
end
return m