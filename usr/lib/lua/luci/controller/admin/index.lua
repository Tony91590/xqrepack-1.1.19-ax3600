module("luci.controller.admin.index",package.seeall)
function index()
local e=node()
if not e.target then
e.target=alias("admin")
e.index=true
end
local e=node("admin")
e.target=firstchild()
e.title=_("Administration")
e.order=10
e.sysauth="root"
e.sysauth_authenticator="htmlauth"
e.ucidata=true
e.index=true
entry({"admin","services"},firstchild(),_("Services"),40).index=true
entry({"admin","nas"},firstchild(),_("NAS"),44).index=true
entry({"admin","vpn"},firstchild(),_("VPN"),44).index=true
entry({"admin","logout"},call("action_logout"),_("Logout"),90)
end
function action_logout()
local e=require"luci.dispatcher"
local a=require"luci.util"
local t=e.context.authsession
if t then
a.ubus("session","destroy",{ubus_rpc_session=t})
luci.http.header("Set-Cookie","sysauth=%s; expires=%s; path=%s/"%{
t,'Thu, 01 Jan 1970 01:00:00 GMT',e.build_url()
})
end
luci.http.redirect(e.build_url())
end
