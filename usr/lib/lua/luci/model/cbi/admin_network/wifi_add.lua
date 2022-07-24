local a=require"nixio.fs"
local h=require"luci.model.network"
local n=require"luci.model.firewall"
local s=require"luci.model.uci".cursor()
local e=require"luci.http"
local t=luci.sys.wifi.getiwinfo(e.formvalue("device"))
local r=a.access("/etc/config/firewall")
if not t then
luci.http.redirect(luci.dispatcher.build_url("admin/network/wireless"))
return
end
m=SimpleForm("network",translatef("Joining Network: %q",e.formvalue("join")))
m.cancel=translate("Back to scan results")
m.reset=false
function m.on_cancel()
local t=e.formvalue("device")
e.redirect(luci.dispatcher.build_url(
t and"admin/network/wireless_join?device="..t
or"admin/network/wireless"
))
end
h.init(s)
n.init(s)
m.hidden={
device=e.formvalue("device"),
join=e.formvalue("join"),
channel=e.formvalue("channel"),
mode=e.formvalue("mode"),
bssid=e.formvalue("bssid"),
wep=e.formvalue("wep"),
wpa_suites=e.formvalue("wpa_suites"),
wpa_version=e.formvalue("wpa_version")
}
if t and t.mbssid_support then
replace=m:field(Flag,"replace",translate("Replace wireless configuration"),
translate("Check this option to delete the existing networks from this radio."))
function replace.cfgvalue()return"0"end
else
replace=m:field(DummyValue,"replace",translate("Replace wireless configuration"))
replace.default=translate("The hardware is not multi-SSID capable and the existing "..
"configuration will be replaced if you proceed.")
function replace.formvalue()return"1"end
end
if e.formvalue("wep")=="1"then
key=m:field(Value,"key",translate("WEP passphrase"),
translate("Specify the secret encryption key here."))
key.password=true
key.datatype="wepkey"
elseif(tonumber(m.hidden.wpa_version)or 0)>0 and
(m.hidden.wpa_suites=="PSK"or m.hidden.wpa_suites=="PSK2")
then
key=m:field(Value,"key",translate("WPA passphrase"),
translate("Specify the secret encryption key here."))
key.password=true
key.datatype="wpakey"
end
newnet=m:field(Value,"_netname_new",translate("Name of the new network"),
translate("The allowed characters are: <code>A-Z</code>, <code>a-z</code>, "..
"<code>0-9</code> and <code>_</code>"
))
newnet.default=m.hidden.mode=="Ad-Hoc"and"mesh"or"wwan"
newnet.datatype="uciname"
if r then
fwzone=m:field(Value,"_fwzone",
translate("Create / Assign firewall-zone"),
translate("Choose the firewall zone you want to assign to this interface. Select <em>unspecified</em> to remove the interface from the associated zone or fill out the <em>create</em> field to define a new zone and attach the interface to it."))
fwzone.template="cbi/firewall_zonelist"
fwzone.default=m.hidden.mode=="Ad-Hoc"and"mesh"or"wan"
end
function newnet.parse(d,t)
local a,i
if r then
local e=fwzone:formvalue(t)
i=n:get_zone(e)
if not i and e=='-'then
e=m:formvalue(fwzone:cbid(t)..".newzone")
if e and#e>0 then
i=n:add_zone(e)
end
end
end
local o=h:get_wifidev(m.hidden.device)
o:set("disabled",false)
o:set("channel",m.hidden.channel)
if replace:formvalue(t)then
local e
for t,e in ipairs(o:get_wifinets())do
o:del_wifinet(e)
end
end
local e={
device=m.hidden.device,
ssid=m.hidden.join,
mode=(m.hidden.mode=="Ad-Hoc"and"adhoc"or"sta")
}
if m.hidden.wep=="1"then
e.encryption="wep-open"
e.key="1"
e.key1=key and key:formvalue(t)or""
elseif(tonumber(m.hidden.wpa_version)or 0)>0 then
e.encryption=(tonumber(m.hidden.wpa_version)or 0)>=2 and"psk2"or"psk"
e.key=key and key:formvalue(t)or""
else
e.encryption="none"
end
if e.mode=="adhoc"or e.mode=="sta"then
e.bssid=m.hidden.bssid
end
local r=d:formvalue(t)
a=h:add_network(r,{proto="dhcp"})
if not a then
d.error={[t]="missing"}
else
e.network=a:name()
local e=o:add_wifinet(e)
if e then
if i then
n:del_network(a:name())
i:add_network(a:name())
end
s:save("wireless")
s:save("network")
s:save("firewall")
luci.http.redirect(e:adminlink())
end
end
end
if r then
function fwzone.cfgvalue(t,e)
t.iface=e
local e=n:get_zone_by_network(e)
return e and e:name()
end
end
return m
