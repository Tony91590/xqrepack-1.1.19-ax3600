module("luci.controller.ddns",package.seeall)
local m=require"nixio"
local v=require"nixio.fs"
local r=require"luci.dispatcher"
local o=require"luci.http"
local e=require"luci.i18n"
local n=require"luci.model.ipkg"
local f=require"luci.sys"
local w=require"luci.model.uci"
local p=require"luci.util"
local a=require"luci.tools.ddns"
luci_helper="/usr/lib/ddns/dynamic_dns_lucihelper.sh"
local i="ddns-scripts"
local s="2.7.7"
local l="luci-app-ddns"
local h="Dynamic DNS"
local d="2.4.9-1"
local t=e.translate
function index()
local e=require"nixio.fs"
local t=require"luci.sys"
local t=require"luci.model.uci"
if not e.access("/etc/config/ddns")then
e.writefile("/etc/config/ddns","")
end
local t=t.cursor()
local a=false
t:foreach("ddns","service",function(e)
if not e["lookup_host"]and e["domain"]then
t:set("ddns",e[".name"],"lookup_host",e["domain"])
a=true
end
end)
if a then t:commit("ddns")end
t:unload("ddns")
entry({"admin","services","ddns"},cbi("ddns/overview"),_("Dynamic DNS"),59)
entry({"admin","services","ddns","detail"},cbi("ddns/detail"),nil).leaf=true
entry({"admin","services","ddns","hints"},cbi("ddns/hints",
{hideapplybtn=true,hidesavebtn=true,hideresetbtn=true}),nil).leaf=true
entry({"admin","services","ddns","global"},cbi("ddns/global"),nil).leaf=true
entry({"admin","services","ddns","logview"},call("logread")).leaf=true
entry({"admin","services","ddns","startstop"},post("startstop")).leaf=true
entry({"admin","services","ddns","status"},call("status")).leaf=true
end
function app_description()
local e={}
e[#e+1]=t("Dynamic DNS allows that your router can be reached with \
								a fixed hostname while having a dynamically changing IP address.")
e[#e+1]=[[<br />]]
e[#e+1]=t("OpenWrt Wiki")..": "
e[#e+1]=[[<a href="https://openwrt.org/docs/guide-user/services/ddns/client" target="_blank">]]
e[#e+1]=t("DDNS Client Documentation")
e[#e+1]=[[</a>]]
e[#e+1]=" --- "
e[#e+1]=[[<a href="https://openwrt.org/docs/guide-user/base-system/ddns" target="_blank">]]
e[#e+1]=t("DDNS Client Configuration")
e[#e+1]=[[</a>]]
return table.concat(e)
end
function app_title_back()
local e={}
e[#e+1]=[[<a href="]]
e[#e+1]=r.build_url("admin","services","ddns")
e[#e+1]=[[">]]
e[#e+1]=t(h)
e[#e+1]=[[</a>]]
return table.concat(e)
end
function app_title_main()
local e={}
e[#e+1]=[[<a href="javascript:alert(']]
e[#e+1]=t("Version Information")
e[#e+1]=[[\n\n]]..l
e[#e+1]=[[\n]]..t("Version")..[[: ]]..d
e[#e+1]=[[\n\n]]..i..[[ ]]..t("required")..[[:]]
e[#e+1]=[[\n]]..t("Version")..[[: ]]
e[#e+1]=s..[[ ]]..t("or higher")
e[#e+1]=[[\n\n]]..i..[[ ]]..t("installed")..[[:]]
e[#e+1]=[[\n]]..t("Version")..[[: ]]
e[#e+1]=(service_version()or t("NOT installed"))
e[#e+1]=[[\n\n]]
e[#e+1]=[[')">]]
e[#e+1]=t(h)
e[#e+1]=[[</a>]]
return table.concat(e)
end
function service_version()
local t=luci_helper.." -V | awk {'print $2'} "
local e
if n then
e=n.info(i)[i].Version
else
e=p.exec(t)
end
if e and#e>0 then return e or nil end
end
function service_ok()
return n.compare_versions((service_version()or"0"),">=",s)
end
local function y()
local m=w.cursor()
local o=f.init.enabled("ddns")and 1 or 0
local e=r.build_url("admin","system","startup")
local r={}
r[#r+1]={
enabled=o,
url_up=e,
}
m:foreach("ddns","service",function(e)
local s=e[".name"]
local u=tonumber(e["enabled"])or 0
local c="_empty_"
local o="_empty_"
local n=nil
local i=a.calc_seconds(
tonumber(e["force_interval"])or 72,
e["force_unit"]or"hours")
local l=a.get_pid(s)
local h=f.uptime()
local d=a.get_lastupd(s)
if d>h then
d=0
end
if d==0 then
c="_never_"
else
local e=os.time()-h+d
c=a.epoch2date(e)
o=a.epoch2date(e+i)
end
i=(i>h)and h or i
if l>0 and(d+i-h)<=0 then
o="_verify_"
n=t("Verify")
elseif i==0 then
o="_runonce_"
n=t("Run once")
elseif l==0 and u==0 then
o="_disabled_"
n=t("Disabled")
elseif l==0 and u~=0 then
o="_stopped_"
n=t("Stopped")
end
local i=e["interface"]or"wan"
local h=tonumber(e["use_ipv6"])or 0
local t=(h==1)and"IPv6"or"IPv4"
i=t.." / "..i
local d=e["lookup_host"]or"_nolookup_"
local t=a.calc_seconds(
tonumber(e["check_interval"])or 10,
e["check_unit"]or"minutes")
local t=a.get_regip(s,t)
if t=="NOFILE"then
local a=e["dns_server"]or""
local n=tonumber(e["force_ipversion"]or 0)
local i=tonumber(e["force_dnstcp"]or 0)
local o=tonumber(e["is_glue"]or 0)
local e=luci_helper..[[ -]]
if(h==1)then e=e..[[6]]end
if(n==1)then e=e..[[f]]end
if(i==1)then e=e..[[t]]end
if(o==1)then e=e..[[g]]end
e=e..[[l ]]..d
e=e..[[ -S ]]..s
if(#a>0)then e=e..[[ -d ]]..a end
e=e..[[ -- get_registered_ip]]
t=f.exec(e)
end
r[#r+1]={
section=s,
enabled=u,
iface=i,
lookup=d,
reg_ip=t,
pid=l,
datelast=c,
datenext=o,
datenextstat=n
}
end)
m:unload("ddns")
return r
end
function logread(e)
local t=w.cursor()
local a=t:get("ddns","global","ddns_logdir")or"/var/log/ddns"
local e=a.."/"..e..".log"
local e=v.readfile(e)
if not e or#e==0 then
e="_nodata_"
end
t:unload("ddns")
o.write(e)
end
function startstop(i,n)
local e=w.cursor()
local a=a.get_pid(i)
local t={}
if a>0 then
local e=m.kill(a,15)
m.nanosleep(2)
t=y()
o.prepare_content("application/json")
o.write_json(t)
return
end
local a=true
local s=e:changes("ddns")
for e,t in pairs(s)do
if e~="ddns"then
a=false
break
end
for t,e in pairs(t)do
if t~=i then
a=false
break
end
for e,t in pairs(e)do
if e~="enabled"then
a=false
break
end
end
end
end
if not a then
o.write("_uncommitted_")
return
end
e:set("ddns",i,"enabled",((n=="true")and"1"or"0"))
e:save("ddns")
e:commit("ddns")
e:unload("ddns")
local e="%s -S %s -- start"%{luci_helper,p.shellquote(i)}
os.execute(e)
m.nanosleep(3)
t=y()
o.prepare_content("application/json")
o.write_json(t)
end
function status()
local e=y()
o.prepare_content("application/json")
o.write_json(e)
end
