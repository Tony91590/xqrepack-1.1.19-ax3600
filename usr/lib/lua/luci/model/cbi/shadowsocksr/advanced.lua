local e=luci.model.uci.cursor()
local t={}
e:foreach("shadowsocksr","servers",function(e)
if e.alias then
t[e[".name"]]="[%s]:%s"%{string.upper(e.v2ray_protocol or e.type),e.alias}
elseif e.server and e.server_port then
t[e[".name"]]="[%s]:%s:%s"%{string.upper(e.v2ray_protocol or e.type),e.server,e.server_port}
end
end)
local e={}
for t,a in pairs(t)do
table.insert(e,t)
end
table.sort(e)
m=Map("shadowsocksr")
s=m:section(TypedSection,"global",translate("Server failsafe auto swith and custom update settings"))
s.anonymous=true
o=s:option(Flag,"enable_switch",translate("Enable Auto Switch"))
o.rmempty=false
o.default="1"
o=s:option(Value,"switch_time",translate("Switch check cycly(second)"))
o.datatype="uinteger"
o:depends("enable_switch","1")
o.default=667
o=s:option(Value,"switch_timeout",translate("Check timout(second)"))
o.datatype="uinteger"
o:depends("enable_switch","1")
o.default=5
o=s:option(Value,"switch_try_count",translate("Check Try Count"))
o.datatype="uinteger"
o:depends("enable_switch","1")
o.default=3
o=s:option(Value,"gfwlist_url",translate("gfwlist Update url"))
o:value("https://cdn.jsdelivr.net/gh/YW5vbnltb3Vz/domain-list-community@release/gfwlist.txt",translate("v2fly/domain-list-community"))
o:value("https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/gfw.txt",translate("Loyalsoldier/v2ray-rules-dat"))
o:value("https://cdn.jsdelivr.net/gh/Loukky/gfwlist-by-loukky/gfwlist.txt",translate("Loukky/gfwlist-by-loukky"))
o:value("https://cdn.jsdelivr.net/gh/gfwlist/gfwlist/gfwlist.txt",translate("gfwlist/gfwlist"))
o.default="https://cdn.jsdelivr.net/gh/YW5vbnltb3Vz/domain-list-community@release/gfwlist.txt"
o=s:option(Value,"chnroute_url",translate("Chnroute Update url"))
o:value("https://ispip.clang.cn/all_cn.txt",translate("Clang.CN"))
o:value("https://ispip.clang.cn/all_cn_cidr.txt",translate("Clang.CN.CIDR"))
o.default="https://ispip.clang.cn/all_cn.txt"
o=s:option(Flag,"netflix_enable",translate("Enable Netflix Mode"))
o.rmempty=false
o=s:option(Value,"nfip_url",translate("nfip_url"))
o:value("https://cdn.jsdelivr.net/gh/QiuSimons/Netflix_IP/NF_only.txt",translate("Netflix IP Only"))
o:value("https://cdn.jsdelivr.net/gh/QiuSimons/Netflix_IP/getflix.txt",translate("Netflix and AWS"))
o.default="https://cdn.jsdelivr.net/gh/QiuSimons/Netflix_IP/NF_only.txt"
o.description=translate("Customize Netflix IP Url")
o:depends("netflix_enable","1")
o=s:option(Flag,"adblock",translate("Enable adblock"))
o.rmempty=false
o=s:option(Value,"adblock_url",translate("adblock_url"))
o:value("https://raw.githubusercontent.com/neodevpro/neodevhost/master/lite_host_dnsmasq.conf",translate("NEO DEV HOST Lite"))
o:value("https://raw.githubusercontent.com/neodevpro/neodevhost/master/host_dnsmasq.conf",translate("NEO DEV HOST Full"))
o:value("https://anti-ad.net/anti-ad-for-dnsmasq.conf",translate("anti-AD"))
o.default="https://raw.githubusercontent.com/neodevpro/neodevhost/master/lite_host_dnsmasq.conf"
o:depends("adblock","1")
o.description=translate("Support AdGuardHome and DNSMASQ format list")
o=s:option(Button,"reset",translate("Reset to defaults"))
o.rawhtml=true
o.template="shadowsocksr/reset"
s=m:section(TypedSection,"socks5_proxy",translate("Global SOCKS5 Proxy Server"))
s.anonymous=true
o=s:option(ListValue,"server",translate("Server"))
o:value("nil",translate("Disable"))
o:value("same",translate("Same as Global Server"))
for a,e in pairs(e)do
o:value(e,t[e])
end
o.default="nil"
o.rmempty=false
o=s:option(Value,"local_port",translate("Local Port"))
o.datatype="port"
o.default=1080
o.rmempty=false
return m
