local n=require"luci.dispatcher"
local i=require"luci.model.firewall"
local t,e,o,a,s,s
t=Map("firewall",
translate("Firewall - Zone Settings"),
translate("The firewall creates zones over your network interfaces to control network traffic flow."))
i.init(t.uci)
e=t:section(TypedSection,"defaults",translate("General Settings"))
e.anonymous=true
e.addremove=false
e:option(Flag,"syn_flood",translate("Enable SYN-flood protection"))
o=e:option(Flag,"drop_invalid",translate("Drop invalid packets"))
e:option(Flag,"fullcone",translate("Enable FullCone NAT"))
a={
e:option(ListValue,"input",translate("Input")),
e:option(ListValue,"output",translate("Output")),
e:option(ListValue,"forward",translate("Forward"))
}
for a,t in ipairs(a)do
t:value("REJECT",translate("reject"))
t:value("DROP",translate("drop"))
t:value("ACCEPT",translate("accept"))
end
e=t:section(TypedSection,"zone",translate("Zones"))
e.template="cbi/tblsection"
e.anonymous=true
e.addremove=true
e.extedit=n.build_url("admin","network","firewall","zones","%s")
function e.create(e)
local e=i:new_zone()
if e then
luci.http.redirect(
n.build_url("admin","network","firewall","zones",e.sid)
)
end
end
function e.remove(t,e)
return i:del_zone(e)
end
o=e:option(DummyValue,"_info",translate("Zone ⇒ Forwardings"))
o.template="cbi/firewall_zoneforwards"
o.cfgvalue=function(e,t)
return e.map:get(t,"name")
end
a={
e:option(ListValue,"input",translate("Input")),
e:option(ListValue,"output",translate("Output")),
e:option(ListValue,"forward",translate("Forward"))
}
for a,t in ipairs(a)do
t:value("REJECT",translate("reject"))
t:value("DROP",translate("drop"))
t:value("ACCEPT",translate("accept"))
end
e:option(Flag,"masq",translate("Masquerading"))
e:option(Flag,"mtu_fix",translate("MSS clamping"))
return t
