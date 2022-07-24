local t,e,t=...
local h,n,t,o,a,s,i
h=e:taboption("general",Value,"sshuser",translate("SSH username"))
n=e:taboption("general",Value,"server",translate("SSH server address"))
n.datatype="host(0)"
t=e:taboption("general",Value,"port",translate("SSH server port"))
t.datatype="port"
t.optional=true
t.default=22
o=e:taboption("general",Value,"ssh_options",translate("Extra SSH command options"))
o.optional=true
a=e:taboption("general",DynamicList,"identity",translate("List of SSH key files for auth"))
a.optional=true
a.datatype="file"
s=e:taboption("general",Value,"ipaddr",translate("Local IP address to assign"))
s.datatype="ipaddr"
i=e:taboption("general",Value,"peeraddr",translate("Peer IP address to assign"))
i.datatype="ipaddr"
local r,n,i,s,o,
t,a,h
if luci.model.network:has_ipv6()then
r=e:taboption("advanced",Flag,"ipv6",
translate("Enable IPv6 negotiation on the PPP link"))
r.default=r.disabled
end
n=e:taboption("advanced",Flag,"defaultroute",
translate("Use default gateway"),
translate("If unchecked, no default route is configured"))
n.default=n.enabled
i=e:taboption("advanced",Value,"metric",
translate("Use gateway metric"))
i.placeholder="0"
i.datatype="uinteger"
i:depends("defaultroute",n.enabled)
s=e:taboption("advanced",Flag,"peerdns",
translate("Use DNS servers advertised by peer"),
translate("If unchecked, the advertised DNS server addresses are ignored"))
s.default=s.enabled
o=e:taboption("advanced",DynamicList,"dns",
translate("Use custom DNS servers"))
o:depends("peerdns","")
o.datatype="ipaddr"
o.cast="string"
t=e:taboption("advanced",Value,"_keepalive_failure",
translate("LCP echo failure threshold"),
translate("Presume peer to be dead after given amount of LCP echo failures, use 0 to ignore failures"))
function t.cfgvalue(t,e)
local e=m:get(e,"keepalive")
if e and#e>0 then
return tonumber(e:match("^(%d+)[ ,]+%d+")or e)
end
end
function t.write()end
function t.remove()end
t.placeholder="0"
t.datatype="uinteger"
a=e:taboption("advanced",Value,"_keepalive_interval",
translate("LCP echo interval"),
translate("Send LCP echo requests at the given interval in seconds, only effective in conjunction with failure threshold"))
function a.cfgvalue(t,e)
local e=m:get(e,"keepalive")
if e and#e>0 then
return tonumber(e:match("^%d+[ ,]+(%d+)"))
end
end
function a.write(o,e,i)
local o=tonumber(t:formvalue(e))or 0
local t=tonumber(i)or 5
if t<1 then t=1 end
if o>0 then
m:set(e,"keepalive","%d %d"%{o,t})
else
m:set(e,"keepalive","0")
end
end
a.remove=a.write
a.placeholder="5"
a.datatype="min(1)"
h=e:taboption("advanced",Value,"demand",
translate("Inactivity timeout"),
translate("Close inactive connection after the given amount of seconds, use 0 to persist connection"))
h.placeholder="0"
h.datatype="uinteger"
