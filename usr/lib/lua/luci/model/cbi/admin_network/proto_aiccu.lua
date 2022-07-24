local t,e,t=...
local y,c,r,m,u,r,h,a,n,
d,o,w,i,t
local r,f,l
y=e:taboption("general",Value,"username",
translate("Server username"),
translate("SIXXS-handle[/Tunnel-ID]"))
y.datatype="string"
c=e:taboption("general",Value,"password",
translate("Server password"),
translate("Server password, enter the specific password of the tunnel when the username contains the tunnel ID"))
c.datatype="string"
c.password=true
m=e:taboption("general",Value,"server",
translate("Tunnel setup server"),
translate("Optional, specify to override default server (tic.sixxs.net)"))
m.datatype="host(0)"
m.optional=true
u=e:taboption("general",Value,"tunnelid",
translate("Tunnel ID"),
translate("Optional, use when the SIXXS account has more than one tunnel"))
u.datatype="string"
u.optional=true
local u=e:taboption("general",Value,"ip6prefix",
translate("IPv6 prefix"),
translate("Routed IPv6 prefix for downstream interfaces"))
u.datatype="ip6addr"
u.optional=true
n=s:taboption("general",ListValue,"heartbeat",
translate("Tunnel type"),
translate("Also see <a href=\"https://www.sixxs.net/faq/connectivity/?faq=comparison\">Tunneling Comparison</a> on SIXXS"))
n:value("0",translate("AYIYA"))
n:value("1",translate("Heartbeat"))
n.default="0"
a=e:taboption("general",Flag,"nat",
translate("Behind NAT"),
translate("The tunnel end-point is behind NAT, defaults to disabled and only applies to AYIYA"))
a.optional=true
a.default=a.disabled
h=e:taboption("general",Flag,"requiretls",
translate("Require TLS"),
translate("Connection to server fails when TLS cannot be used"))
h.optional=true
h.default=h.disabled
d=e:taboption("advanced",Flag,"verbose",
translate("Verbose"),
translate("Verbose logging by aiccu daemon"))
d.optional=true
d.default=d.disabled
o=e:taboption("advanced",Value,"ntpsynctimeout",
translate("NTP sync time-out"),
translate("Wait for NTP sync that many seconds, seting to 0 disables waiting (optional)"))
o.datatype="uinteger"
o.placeholder="90"
o.optional=true
w=e:taboption("advanced",Value,"ip6addr",
translate("Local IPv6 address"),
translate("IPv6 address delegated to the local tunnel endpoint (optional)"))
w.datatype="ip6addr"
w.optional=true
t=e:taboption("advanced",Flag,"defaultroute",
translate("Default route"),
translate("Whether to create an IPv6 default route over the tunnel"))
t.default=t.enabled
t.optional=true
i=e:taboption("advanced",Flag,"sourcerouting",
translate("Source routing"),
translate("Whether to route only packets from delegated prefixes"))
i.default=i.enabled
i.optional=true
r=e:taboption("advanced",Value,"metric",
translate("Use gateway metric"))
r.datatype="uinteger"
r.placeholder="0"
r:depends("defaultroute",t.enabled)
f=e:taboption("advanced",Value,"ttl",
translate("Use TTL on tunnel interface"))
f.datatype="range(1,255)"
f.placeholder="64"
l=e:taboption("advanced",Value,"mtu",
translate("Use MTU on tunnel interface"),
translate("minimum 1280, maximum 1480"))
l.datatype="range(1280,1480)"
l.placeholder="1280"
