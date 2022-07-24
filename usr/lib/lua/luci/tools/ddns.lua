module("luci.tools.ddns",package.seeall)
local d=require"nixio"
local a=require"nixio.fs"
local i=require"luci.model.uci"
local t=require"luci.sys"
function env_info(e)
if(e=="has_ssl")or(e=="has_proxy")or(e=="has_forceip")
or(e=="has_bindnet")or(e=="has_fetch")
or(e=="has_wgetssl")or(e=="has_curl")
or(e=="has_curlssl")or(e=="has_curlpxy")
or(e=="has_fetchssl")or(e=="has_bbwget")then
local function o()
return(t.call([[which wget-ssl >/dev/null 2>&1]])==0)
end
local function h()
return(t.call([[$(which curl) -V 2>&1 | grep -qF "https"]])==0)
end
local function i()
return(t.call([[which uclient-fetch >/dev/null 2>&1]])==0)
end
local function r()
return a.access("/lib/libustream-ssl.so")
end
local function a()
return(t.call([[which curl >/dev/null 2>&1]])==0)
end
local function s()
return(t.call([[grep -i "all_proxy" /usr/lib/libcurl.so* >/dev/null 2>&1]])==0)
end
local function n()
return(t.call([[$(which wget) -V 2>&1 | grep -iqF "busybox"]])==0)
end
if e=="has_wgetssl"then
return o()
elseif e=="has_curl"then
return a()
elseif e=="has_curlssl"then
return h()
elseif e=="has_curlpxy"then
return s()
elseif e=="has_fetch"then
return i()
elseif e=="has_fetchssl"then
return r()
elseif e=="has_bbwget"then
return n()
elseif e=="has_ssl"then
if o()then return true end
if h()then return true end
if(i()and r())then return true end
return false
elseif e=="has_proxy"then
if o()then return true end
if s()then return true end
if i()then return true end
if n()then return true end
return false
elseif e=="has_forceip"then
if o()then return true end
if a()then return true end
if i()then return true end
return false
elseif e=="has_bindnet"then
if a()then return true end
if o()then return true end
return false
end
elseif(e=="has_dnsserver")or(e=="has_bindhost")or(e=="has_hostip")or(e=="has_nslookup")then
local function a()
if(t.call([[which host >/dev/null 2>&1]])==0)then return true end
if(t.call([[which khost >/dev/null 2>&1]])==0)then return true end
if(t.call([[which drill >/dev/null 2>&1]])==0)then return true end
return false
end
local function i()
return(t.call([[which hostip >/dev/null 2>&1]])==0)
end
local function o()
return(t.call([[which nslookup >/dev/null 2>&1]])==0)
end
if e=="has_bindhost"then
return a()
elseif e=="has_hostip"then
return i()
elseif e=="has_nslookup"then
return o()
elseif e=="has_dnsserver"then
if a()then return true end
if i()then return true end
if o()then return true end
return false
end
elseif e=="has_ipv6"then
return(a.access("/proc/net/ipv6_route")and a.access("/usr/sbin/ip6tables"))
elseif e=="has_cacerts"then
local t,e=a.glob("/etc/ssl/certs/*.crt")
if(e==0)then t,e=a.glob("/etc/ssl/certs/*.pem")end
return(e>0)
else
return
end
end
function calc_seconds(e,t)
if not tonumber(e)then
return nil
elseif t=="days"then
return(tonumber(e)*86400)
elseif t=="hours"then
return(tonumber(e)*3600)
elseif t=="minutes"then
return(tonumber(e)*60)
elseif t=="seconds"then
return tonumber(e)
else
return nil
end
end
function epoch2date(a,e)
if not e or#e<2 then
local t=i.cursor()
e=t:get("ddns","global","ddns_dateformat")or"%F %R"
t:unload("ddns")
end
e=e:gsub("%%n","<br />")
e=e:gsub("%%t","    ")
return os.date(e,a)
end
function get_lastupd(t)
local e=i.cursor()
local o=e:get("ddns","global","ddns_rundir")or"/var/run/ddns"
local t=tonumber(a.readfile("%s/%s.update"%{o,t})or 0)
e:unload("ddns")
return t
end
function get_regip(t,s)
local i=i.cursor()
local e=i:get("ddns","global","ddns_rundir")or"/var/run/ddns"
local o="NOFILE"
if a.access("%s/%s.ip"%{e,t})then
local n=a.stat("%s/%s.ip"%{e,t},"ctime")or 0
local i=os.time()
if i<(n+s+9)then
o=a.readfile("%s/%s.ip"%{e,t})
end
end
i:unload("ddns")
return o
end
function get_pid(o)
local t=i.cursor()
local e=t:get("ddns","global","ddns_rundir")or"/var/run/ddns"
local e=tonumber(a.readfile("%s/%s.pid"%{e,o})or 0)
if e>0 and not d.kill(e,0)then
e=0
end
t:unload("ddns")
return e
end
function read_value(t,a,o)
local e
if t.tag_error[a]then
e=t:formvalue(a)
else
e=t.map:get(a,o)
end
if not e then
return nil
elseif not t.cast or t.cast==type(e)then
return e
elseif t.cast=="string"then
if type(e)=="table"then
return e[1]
end
elseif t.cast=="table"then
return{e}
end
end
function value_parse(e,i,d)
local t=e:formvalue(i)
local r=(t and(#t>0))
local n=e:cfgvalue(i)
local h=(e.rmempty or e.optional)
local a
if type(t)=="table"and type(n)=="table"then
a=(#t==#n)
if a then
for e=1,#t do
if n[e]~=t[e]then
a=false
end
end
end
if a then
t=n
end
end
local o,s=e:validate(t)
if not o then
if d then
return
end
if r then
e:add_error(i,"invalid",s or e.title..": invalid")
return
elseif not h then
e:add_error(i,"missing",s or e.title..": missing")
return
elseif s then
e:add_error(i,"invalid",s)
return
end
end
a=(o==n)
local l=(o and(#o>0))and true or false
local d=(o==e.default)
if h and(not l or d)then
if e:remove(i)then
e.section.changed=true
end
return
end
if not e.forcewrite and a then
return
end
assert(o,"\n option: "..e.option..
"\n fvalue: "..tostring(t)..
"\n fexist: "..tostring(r)..
"\n cvalue: "..tostring(n)..
"\n vvalue: "..tostring(o)..
"\n vexist: "..tostring(l)..
"\n rm_opt: "..tostring(h)..
"\n eq_cfg: "..tostring(a)..
"\n eq_def: "..tostring(d)..
"\n errtxt: "..tostring(s))
if e:write(i,o)and not a then
e.section.changed=true
end
end
function parse_url(t)
local e={}
t=string.gsub(t,"#(.*)$",
function(t)
e.fragment=t
return""
end)
t=string.gsub(t,"^([%w][%w%+%-%.]*)%:",
function(t)
e.scheme=string.lower(t);
return""
end)
t=string.gsub(t,"^//([^/]*)",
function(t)
e.authority=t
return""
end)
t=string.gsub(t,"%?(.*)",
function(t)
e.query=t
return""
end)
t=string.gsub(t,"%;(.*)",
function(t)
e.params=t
return""
end)
e.path=t
local t=e.authority
if not t then
return e
end
t=string.gsub(t,"^([^@]*)@",
function(t)
e.userinfo=t;
return""
end)
t=string.gsub(t,":([0-9]*)$",
function(t)
if t~=""then
e.port=t
end;
return""
end)
if t~=""then
e.host=t
end
local t=e.userinfo
if not t then
return e
end
t=string.gsub(t,":([^:]*)$",
function(t)
e.password=t;
return""
end)
e.user=t
return e
end
