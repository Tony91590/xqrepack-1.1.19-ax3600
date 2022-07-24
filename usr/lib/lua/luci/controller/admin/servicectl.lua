module("luci.controller.admin.servicectl",package.seeall)
function index()
entry({"servicectl"},alias("servicectl","status")).sysauth="root"
entry({"servicectl","status"},call("action_status")).leaf=true
entry({"servicectl","restart"},post("action_restart")).leaf=true
end
function action_status()
local e=nixio.fs.readfile("/var/run/luci-reload-status")
if e then
luci.http.write("/etc/config/")
luci.http.write(e)
else
luci.http.write("finish")
end
end
function action_restart(t)
local a=require"luci.model.uci".cursor()
if t then
local e
local e={}
for t in t:gmatch("[%w_-]+")do
e[#e+1]=t
end
local a=a:apply(e,true)
if nixio.fork()==0 then
local e=nixio.open("/dev/null","r")
local t=nixio.open("/dev/null","w")
nixio.dup(e,nixio.stdin)
nixio.dup(t,nixio.stdout)
e:close()
t:close()
nixio.exec("/bin/sh",unpack(a))
else
luci.http.write("OK")
os.exit(0)
end
end
end
