local e,t,e=...
local l,e,u,d,h,r
local a,o,n,i
l=s:taboption("general",Value,"ipaddr",
translate("Local IPv4 address"),
translate("Leave empty to use the current WAN address"))
l.datatype="ip4addr"
e=s:taboption("general",Value,"peeraddr",
translate("Remote IPv4 address"),
translate("This is usually the address of the nearest PoP operated by the tunnel broker"))
e.rmempty=false
e.datatype="ip4addr"
u=s:taboption("general",Value,"ip6addr",
translate("Local IPv6 address"),
translate("This is the local endpoint address assigned by the tunnel broker, it usually ends with <code>...:2/64</code>"))
u.datatype="ip6addr"
local e=s:taboption("general",Value,"ip6prefix",
translate("IPv6 routed prefix"),
translate("This is the prefix routed to you by the tunnel broker for use by clients"))
e.datatype="ip6addr"
local e=t:taboption("general",Flag,"_update",
translate("Dynamic tunnel"),
translate("Enable HE.net dynamic endpoint update"))
e.enabled="1"
e.disabled="0"
function e.write()end
function e.remove()end
function e.cfgvalue(e,t)
return(tonumber(m:get(t,"tunnelid"))~=nil)
and e.enabled or e.disabled
end
d=t:taboption("general",Value,"tunnelid",translate("Tunnel ID"))
d.datatype="uinteger"
d:depends("_update",e.enabled)
h=t:taboption("general",Value,"username",
translate("HE.net username"),
translate("This is the plain username for logging into the account"))
h:depends("_update",e.enabled)
h.validate=function(t,e,t)
if type(e)=="string"and#e==32 and e:match("^[a-fA-F0-9]+$")then
return nil,translate("The HE.net endpoint update configuration changed, you must now use the plain username instead of the user ID!")
end
return e
end
r=t:taboption("general",Value,"password",
translate("HE.net password"),
translate("This is either the \"Update Key\" configured for the tunnel or the account password if no update key has been configured"))
r.password=true
r:depends("_update",e.enabled)
a=t:taboption("advanced",Flag,"defaultroute",
translate("Default gateway"),
translate("If unchecked, no default route is configured"))
a.default=a.enabled
o=t:taboption("advanced",Value,"metric",
translate("Use gateway metric"))
o.placeholder="0"
o.datatype="uinteger"
o:depends("defaultroute",a.enabled)
n=t:taboption("advanced",Value,"ttl",translate("Use TTL on tunnel interface"))
n.placeholder="64"
n.datatype="range(1,255)"
i=t:taboption("advanced",Value,"mtu",translate("Use MTU on tunnel interface"))
i.placeholder="1280"
i.datatype="max(9200)"
