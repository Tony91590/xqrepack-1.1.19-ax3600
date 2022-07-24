require"luci.http"
require"luci.dispatcher"
require"nixio.fs"
local a,t,e
local o=arg[1]
local s={
"rc4-md5",
"rc4-md5-6",
"rc4",
"table",
"aes-128-cfb",
"aes-192-cfb",
"aes-256-cfb",
"aes-128-ctr",
"aes-192-ctr",
"aes-256-ctr",
"bf-cfb",
"camellia-128-cfb",
"camellia-192-cfb",
"camellia-256-cfb",
"cast5-cfb",
"des-cfb",
"idea-cfb",
"rc2-cfb",
"seed-cfb",
"salsa20",
"chacha20",
"chacha20-ietf"
}
local n={
"aes-128-gcm",
"aes-192-gcm",
"aes-256-gcm",
"chacha20-ietf-poly1305",
"xchacha20-ietf-poly1305"
}
local i={"origin"}
obfs={"plain","http_simple","http_post"}
a=Map("shadowsocksr",translate("Edit ShadowSocksR Server"))
a.redirect=luci.dispatcher.build_url("admin/services/shadowsocksr/server")
if a.uci:get("shadowsocksr",o)~="server_config"then
luci.http.redirect(a.redirect)
return
end
t=a:section(NamedSection,o,"server_config")
t.anonymous=true
t.addremove=false
e=t:option(Flag,"enable",translate("Enable"))
e.default=1
e.rmempty=false
e=t:option(ListValue,"type",translate("Server Type"))
e:value("socks5",translate("Socks5"))
if nixio.fs.access("/usr/bin/ssserver")or nixio.fs.access("/usr/bin/ss-server")then
e:value("ss",translate("Shadowsocks"))
end
if nixio.fs.access("/usr/bin/ssr-server")then
e:value("ssr",translate("ShadowsocksR"))
end
e.default="socks5"
e=t:option(Value,"server_port",translate("Server Port"))
e.datatype="port"
math.randomseed(tostring(os.time()):reverse():sub(1,7))
e.default=math.random(10240,20480)
e.rmempty=false
e.description=translate("warning! Please do not reuse the port!")
e=t:option(Value,"timeout",translate("Connection Timeout"))
e.datatype="uinteger"
e.default=60
e.rmempty=false
e:depends("type","ss")
e:depends("type","ssr")
e=t:option(Value,"username",translate("Username"))
e.rmempty=false
e:depends("type","socks5")
e=t:option(Value,"password",translate("Password"))
e.password=true
e.rmempty=false
e=t:option(ListValue,"encrypt_method",translate("Encrypt Method"))
for a,t in ipairs(s)do
e:value(t)
end
e.rmempty=false
e:depends("type","ssr")
e=t:option(ListValue,"encrypt_method_ss",translate("Encrypt Method"))
for a,t in ipairs(n)do
e:value(t)
end
e.rmempty=false
e:depends("type","ss")
e=t:option(ListValue,"protocol",translate("Protocol"))
for a,t in ipairs(i)do
e:value(t)
end
e.rmempty=false
e:depends("type","ssr")
e=t:option(ListValue,"obfs",translate("Obfs"))
for a,t in ipairs(obfs)do
e:value(t)
end
e.rmempty=false
e:depends("type","ssr")
e=t:option(Value,"obfs_param",translate("Obfs param(optional)"))
e:depends("type","ssr")
e=t:option(Flag,"fast_open",translate("TCP Fast Open"))
e.rmempty=false
e:depends("type","ss")
e:depends("type","ssr")
return a
