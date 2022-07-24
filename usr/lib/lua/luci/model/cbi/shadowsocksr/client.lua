local i,t,a,e,a
local n=luci.model.uci.cursor()
i=Map("shadowsocksr",translate("ShadowSocksR Plus+ Settings"),translate("<h3>Support SS/SSR/V2RAY/XRAY/TROJAN/NAIVEPROXY/SOCKS5/TUN etc.</h3>"))
i:section(SimpleSection).template="shadowsocksr/status"
local a={}
n:foreach("shadowsocksr","servers",function(e)
if e.alias then
a[e[".name"]]="[%s]:%s"%{string.upper(e.v2ray_protocol or e.type),e.alias}
elseif e.server and e.server_port then
a[e[".name"]]="[%s]:%s:%s"%{string.upper(e.v2ray_protocol or e.type),e.server,e.server_port}
end
end)
local o={}
for e,t in pairs(a)do
table.insert(o,e)
end
table.sort(o)
t=i:section(TypedSection,"global")
t.anonymous=true
e=t:option(ListValue,"global_server",translate("Main Server"))
e:value("nil",translate("Disable"))
for o,t in pairs(o)do
e:value(t,a[t])
end
e.default="nil"
e.rmempty=false
e=t:option(ListValue,"udp_relay_server",translate("Game Mode UDP Server"))
e:value("",translate("Disable"))
e:value("same",translate("Same as Global Server"))
for o,t in pairs(o)do
e:value(t,a[t])
end
if n:get_first("shadowsocksr",'global','netflix_enable','0')~='0'then
e=t:option(ListValue,"netflix_server",translate("Netflix Node"))
e:value("nil",translate("Disable"))
e:value("same",translate("Same as Global Server"))
for o,t in pairs(o)do
e:value(t,a[t])
end
e.default="nil"
e.rmempty=false
e=t:option(Flag,"netflix_proxy",translate("External Proxy Mode"))
e.rmempty=false
e.description=translate("Forward Netflix Proxy through Main Proxy")
e.default="0"
end
e=t:option(ListValue,"threads",translate("Multi Threads Option"))
e:value("0",translate("Auto Threads"))
e:value("1",translate("1 Thread"))
e:value("2",translate("2 Threads"))
e:value("4",translate("4 Threads"))
e:value("8",translate("8 Threads"))
e:value("16",translate("16 Threads"))
e:value("32",translate("32 Threads"))
e:value("64",translate("64 Threads"))
e:value("128",translate("128 Threads"))
e.default="0"
e.rmempty=false
e=t:option(ListValue,"run_mode",translate("Running Mode"))
e:value("gfw",translate("GFW List Mode"))
e:value("router",translate("IP Route Mode"))
e:value("all",translate("Global Mode"))
e:value("oversea",translate("Oversea Mode"))
e.default=gfw
e=t:option(ListValue,"dports",translate("Proxy Ports"))
e:value("1",translate("All Ports"))
e:value("2",translate("Only Common Ports"))
e.default=1
e=t:option(ListValue,"pdnsd_enable",translate("Resolve Dns Mode"))
e:value("1",translate("Use Pdnsd tcp query and cache"))
e:value("2",translate("Use DNS2SOCKS query and cache"))
e:value("0",translate("Use Local DNS Service listen port 5335"))
e.default=1
e=t:option(Value,"tunnel_forward",translate("Anti-pollution DNS Server"))
e:value("8.8.4.4:53",translate("Google Public DNS (8.8.4.4)"))
e:value("8.8.8.8:53",translate("Google Public DNS (8.8.8.8)"))
e:value("208.67.222.222:53",translate("OpenDNS (208.67.222.222)"))
e:value("208.67.220.220:53",translate("OpenDNS (208.67.220.220)"))
e:value("209.244.0.3:53",translate("Level 3 Public DNS (209.244.0.3)"))
e:value("209.244.0.4:53",translate("Level 3 Public DNS (209.244.0.4)"))
e:value("4.2.2.1:53",translate("Level 3 Public DNS (4.2.2.1)"))
e:value("4.2.2.2:53",translate("Level 3 Public DNS (4.2.2.2)"))
e:value("4.2.2.3:53",translate("Level 3 Public DNS (4.2.2.3)"))
e:value("4.2.2.4:53",translate("Level 3 Public DNS (4.2.2.4)"))
e:value("1.1.1.1:53",translate("Cloudflare DNS (1.1.1.1)"))
e:value("114.114.114.114:53",translate("Oversea Mode DNS-1 (114.114.114.114)"))
e:value("114.114.115.115:53",translate("Oversea Mode DNS-2 (114.114.115.115)"))
e:depends("pdnsd_enable","1")
e:depends("pdnsd_enable","2")
e.description=translate("Custom DNS Server format as IP:PORT (default: 8.8.4.4:53)")
e.datatype="hostport"
return i
