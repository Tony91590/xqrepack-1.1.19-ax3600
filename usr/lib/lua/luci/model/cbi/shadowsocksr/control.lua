require"luci.ip"
require"nixio.fs"
local o,t,e
o=Map("shadowsocksr")
t=o:section(TypedSection,"access_control")
t.anonymous=true
t:tab("Interface",translate("Interface control"))
e=t:taboption("Interface",DynamicList,"Interface",translate("Interface"))
e.template="cbi/network_netlist"
e.widget="checkbox"
e.nocreate=true
e.unspecified=true
e.description=translate("Listen only on the given interface or, if unspecified, on all")
t:tab("wan_ac",translate("WAN IP AC"))
e=t:taboption("wan_ac",DynamicList,"wan_bp_ips",translate("WAN White List IP"))
e.datatype="ip4addr"
e=t:taboption("wan_ac",DynamicList,"wan_fw_ips",translate("WAN Force Proxy IP"))
e.datatype="ip4addr"
t:tab("lan_ac",translate("LAN IP AC"))
e=t:taboption("lan_ac",ListValue,"lan_ac_mode",translate("LAN Access Control"))
e:value("0",translate("Disable"))
e:value("w",translate("Allow listed only"))
e:value("b",translate("Allow all except listed"))
e.rmempty=false
e=t:taboption("lan_ac",DynamicList,"lan_ac_ips",translate("LAN Host List"))
e.datatype="ipaddr"
luci.ip.neighbors({family=4},function(t)
if t.reachable then
e:value(t.dest:string())
end
end)
e:depends("lan_ac_mode","w")
e:depends("lan_ac_mode","b")
e=t:taboption("lan_ac",DynamicList,"lan_bp_ips",translate("LAN Bypassed Host List"))
e.datatype="ipaddr"
luci.ip.neighbors({family=4},function(t)
if t.reachable then
e:value(t.dest:string())
end
end)
e=t:taboption("lan_ac",DynamicList,"lan_fp_ips",translate("LAN Force Proxy Host List"))
e.datatype="ipaddr"
luci.ip.neighbors({family=4},function(t)
if t.reachable then
e:value(t.dest:string())
end
end)
e=t:taboption("lan_ac",DynamicList,"lan_gm_ips",translate("Game Mode Host List"))
e.datatype="ipaddr"
luci.ip.neighbors({family=4},function(t)
if t.reachable then
e:value(t.dest:string())
end
end)
t:tab("esc",translate("Bypass Domain List"))
local a="/etc/ssrplus/white.list"
e=t:taboption("esc",TextValue,"escconf")
e.rows=13
e.wrap="off"
e.rmempty=true
e.cfgvalue=function(t,t)
return nixio.fs.readfile(a)or""
end
e.write=function(o,o,t)
nixio.fs.writefile(a,t:gsub("\r\n","\n"))
end
e.remove=function(e,e,e)
nixio.fs.writefile(a,"")
end
t:tab("block",translate("Black Domain List"))
local a="/etc/ssrplus/black.list"
e=t:taboption("block",TextValue,"blockconf")
e.rows=13
e.wrap="off"
e.rmempty=true
e.cfgvalue=function(t,t)
return nixio.fs.readfile(a)or" "
end
e.write=function(o,o,t)
nixio.fs.writefile(a,t:gsub("\r\n","\n"))
end
e.remove=function(e,e,e)
nixio.fs.writefile(a,"")
end
t:tab("denydomain",translate("Deny Domain List"))
local a="/etc/ssrplus/deny.list"
e=t:taboption("denydomain",TextValue,"denydomainconf")
e.rows=13
e.wrap="off"
e.rmempty=true
e.cfgvalue=function(t,t)
return nixio.fs.readfile(a)or" "
end
e.write=function(o,o,t)
nixio.fs.writefile(a,t:gsub("\r\n","\n"))
end
e.remove=function(e,e,e)
nixio.fs.writefile(a,"")
end
t:tab("netflix",translate("Netflix Domain List"))
local a="/etc/ssrplus/netflix.list"
e=t:taboption("netflix",TextValue,"netflixconf")
e.rows=13
e.wrap="off"
e.rmempty=true
e.cfgvalue=function(t,t)
return nixio.fs.readfile(a)or" "
end
e.write=function(o,o,t)
nixio.fs.writefile(a,t:gsub("\r\n","\n"))
end
e.remove=function(e,e,e)
nixio.fs.writefile(a,"")
end
return o
