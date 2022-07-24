require"luci.http"
require"luci.dispatcher"
local a,t,e
local o={
"table",
"rc4",
"rc4-md5",
"rc4-md5-6",
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
local o={
"aes-128-gcm",
"aes-192-gcm",
"aes-256-gcm",
"chacha20-ietf-poly1305",
"xchacha20-ietf-poly1305"
}
local o={
"origin",
"verify_deflate",
"auth_sha1_v4",
"auth_aes128_sha1",
"auth_aes128_md5",
"auth_chain_a"
}
obfs={
"plain",
"http_simple",
"http_post",
"random_head",
"tls1.2_ticket_auth",
"tls1.2_ticket_fastauth"
}
a=Map("shadowsocksr")
t=a:section(TypedSection,"server_global",translate("Global Setting"))
t.anonymous=true
e=t:option(Flag,"enable_server",translate("Enable Server"))
e.rmempty=false
t=a:section(TypedSection,"server_config",translate("Server Setting"))
t.anonymous=true
t.addremove=true
t.template="cbi/tblsection"
t.extedit=luci.dispatcher.build_url("admin/services/shadowsocksr/server/%s")
function t.create(...)
local a=TypedSection.create(...)
if a then
luci.http.redirect(t.extedit%a)
return
end
end
e=t:option(Flag,"enable",translate("Enable"))
function e.cfgvalue(...)
return Value.cfgvalue(...)or translate("0")
end
e.rmempty=false
e=t:option(DummyValue,"type",translate("Server Type"))
function e.cfgvalue(...)
return Value.cfgvalue(...)or"ss"
end
e=t:option(DummyValue,"server_port",translate("Server Port"))
function e.cfgvalue(...)
return Value.cfgvalue(...)or"-"
end
e=t:option(DummyValue,"username",translate("Username"))
function e.cfgvalue(...)
return Value.cfgvalue(...)or"-"
end
e=t:option(DummyValue,"encrypt_method",translate("Encrypt Method"))
function e.cfgvalue(...)
local t=Value.cfgvalue(...)
return t and t:upper()or"-"
end
e=t:option(DummyValue,"encrypt_method_ss",translate("Encrypt Method"))
function e.cfgvalue(...)
local t=Value.cfgvalue(...)
return t and t:upper()or"-"
end
e=t:option(DummyValue,"protocol",translate("Protocol"))
function e.cfgvalue(...)
return Value.cfgvalue(...)or"-"
end
e=t:option(DummyValue,"obfs",translate("Obfs"))
function e.cfgvalue(...)
return Value.cfgvalue(...)or"-"
end
return a
