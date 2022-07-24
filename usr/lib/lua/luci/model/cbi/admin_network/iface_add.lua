local t=require"luci.model.network".init()
local e=require"luci.model.firewall".init()
local i=require"luci.util"
local e=require"luci.model.uci".cursor()
m=SimpleForm("network",translate("Create Interface"))
m.redirect=luci.dispatcher.build_url("admin/network/network")
m.reset=false
newnet=m:field(Value,"_netname",translate("Name of the new interface"),
translate("The allowed characters are: <code>A-Z</code>, <code>a-z</code>, "..
"<code>0-9</code> and <code>_</code>"
))
newnet:depends("_attach","")
newnet.default=arg[1]and"net_"..arg[1]:gsub("[^%w_]+","_")
newnet.datatype="and(uciname,maxlength(15))"
advice=m:field(DummyValue,"d1",translate("Note: interface name length"),
translate("Maximum length of the name is 15 characters including "..
"the automatic protocol/bridge prefix (br-, 6in4-, pppoe- etc.)"
))
newproto=m:field(ListValue,"_netproto",translate("Protocol of the new interface"))
netbridge=m:field(Flag,"_bridge",translate("Create a bridge over multiple interfaces"))
sifname=m:field(Value,"_ifname",translate("Cover the following interface"))
sifname.widget="radio"
sifname.template="cbi/network_ifacelist"
sifname.nobridges=true
mifname=m:field(Value,"_ifnames",translate("Cover the following interfaces"))
mifname.widget="checkbox"
mifname.template="cbi/network_ifacelist"
mifname.nobridges=true
local e,e
for t,e in ipairs(t:get_protocols())do
if e:is_installed()then
newproto:value(e:proto(),e:get_i18n())
if not e:is_virtual()then netbridge:depends("_netproto",e:proto())end
if not e:is_floating()then
sifname:depends({_bridge="",_netproto=e:proto()})
mifname:depends({_bridge="1",_netproto=e:proto()})
end
end
end
function newproto.validate(o,a,e)
local o=newnet:formvalue(e)
if not o or#o==0 then
newnet:add_error(e,translate("No network name specified"))
elseif m:get(o)then
newnet:add_error(e,translate("The given network name is not unique"))
end
local t=t:get_protocol(a)
if t and not t:is_floating()then
local t=(netbridge:formvalue(e)=="1")
local e=t and mifname:formvalue(e)or sifname:formvalue(e)
for e in i.imatch(e)do
return a
end
return nil,translate("The selected protocol needs a device assigned")
end
return a
end
function newproto.write(e,a,n)
local e=newnet:formvalue(a)
if e and#e>0 then
local o=(netbridge:formvalue(a)=="1")and"bridge"or nil
local n=t:add_network(e,{proto=n,type=o})
if n then
local e
for e in i.imatch(
o and mifname:formvalue(a)or sifname:formvalue(a)
)do
n:add_interface(e)
end
t:save("network")
t:save("wireless")
end
luci.http.redirect(luci.dispatcher.build_url("admin/network/network",e))
end
end
return m
