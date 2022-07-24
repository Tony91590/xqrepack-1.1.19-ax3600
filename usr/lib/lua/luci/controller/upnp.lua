module("luci.controller.upnp",package.seeall)
function index()
if not nixio.fs.access("/etc/config/upnpd")then
return
end
local e
e=entry({"admin","services","upnp"},cbi("upnp/upnp"),_("UPnP"))
e.dependent=true
entry({"admin","services","upnp","status"},call("act_status")).leaf=true
entry({"admin","services","upnp","delete"},post("act_delete")).leaf=true
end
function act_status()
local e=luci.model.uci.cursor()
local e=e:get("upnpd","config","upnp_lease_file")
local h=io.popen("iptables --line-numbers -t nat -xnvL MINIUPNPD 2>/dev/null")
if h then
local a=e and io.open(e,"r")
local r={}
while true do
local e=h:read("*l")
if not e then
break
elseif e:match("^%d+")then
local o,s,t,n,e=
e:match("^(%d+).-([a-z]+).-dpt:(%d+) to:(%S-):(%d+)")
local i=""
if o and s and t and n and e then
o=tonumber(o)
t=tonumber(t)
e=tonumber(e)
if a then
local a=a:read("*l")
if a then i=a:match(string.format("^%s:%d:%s:%d:%%d*:(.*)$",s:upper(),t,n,e))end
if not i then i=""end
end
r[#r+1]={
num=o,
proto=s:upper(),
extport=t,
intaddr=n,
intport=e,
descr=i
}
end
end
end
if a then a:close()end
h:close()
luci.http.prepare_content("application/json")
luci.http.write_json(r)
end
end
function act_delete(e)
local e=tonumber(e)
local t=luci.model.uci.cursor()
if e and e>0 then
luci.sys.call("iptables -t filter -D MINIUPNPD %d 2>/dev/null"%e)
luci.sys.call("iptables -t nat -D MINIUPNPD %d 2>/dev/null"%e)
local t=t:get("upnpd","config","upnp_lease_file")
if t and nixio.fs.access(t)then
luci.sys.call("sed -i -e '%dd' %s"%{e,luci.util.shellquote(t)})
end
luci.http.status(200,"OK")
return
end
luci.http.status(400,"Bad request")
end
