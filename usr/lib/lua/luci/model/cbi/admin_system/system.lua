local o=require"luci.sys"
local n=require"luci.sys.zoneinfo"
local i=require"nixio.fs"
local s=require"luci.config"
local a,t,e
local h=i.access("/usr/sbin/ntpd")
a=Map("system",translate("System"),translate("Here you can configure the basic aspects of your device like its hostname or the timezone."))
a:chain("luci")
t=a:section(TypedSection,"system",translate("System Properties"))
t.anonymous=true
t.addremove=false
t:tab("general",translate("General Settings"))
t:tab("logging",translate("Logging"))
t:tab("language",translate("Language and Style"))
e=t:taboption("general",DummyValue,"_systime",translate("Local Time"))
e.template="admin_system/clock_status"
e=t:taboption("general",Value,"hostname",translate("Hostname"))
e.datatype="hostname"
function e.write(a,i,t)
Value.write(a,i,t)
o.hostname(t)
end
e=t:taboption("general",ListValue,"zonename",translate("Timezone"))
e:value("UTC")
for a,t in ipairs(n.TZ)do
e:value(t[1])
end
function e.write(o,t,a)
local function s(t)
for a,e in ipairs(n.TZ)do
if e[1]==t then return e[2]end
end
end
AbstractValue.write(o,t,a)
local a=s(a)or"GMT0"
o.map.uci:set("system",t,"timezone",a)
i.writefile("/etc/TZ",a.."\n")
end
e=t:taboption("logging",Value,"log_size",translate("System log buffer size"),"kiB")
e.optional=true
e.placeholder=16
e.datatype="uinteger"
e=t:taboption("logging",Value,"log_ip",translate("External system log server"))
e.optional=true
e.placeholder="0.0.0.0"
e.datatype="ip4addr"
e=t:taboption("logging",Value,"log_port",translate("External system log server port"))
e.optional=true
e.placeholder=514
e.datatype="port"
e=t:taboption("logging",ListValue,"log_proto",translate("External system log server protocol"))
e:value("udp","UDP")
e:value("tcp","TCP")
e=t:taboption("logging",Value,"log_file",translate("Write system log to file"))
e.optional=true
e.placeholder="/tmp/system.log"
e=t:taboption("logging",ListValue,"conloglevel",translate("Log output level"))
e:value(8,translate("Debug"))
e:value(7,translate("Info"))
e:value(6,translate("Notice"))
e:value(5,translate("Warning"))
e:value(4,translate("Error"))
e:value(3,translate("Critical"))
e:value(2,translate("Alert"))
e:value(1,translate("Emergency"))
e=t:taboption("logging",ListValue,"cronloglevel",translate("Cron Log Level"))
e.default=8
e:value(5,translate("Debug"))
e:value(8,translate("Normal"))
e:value(9,translate("Warning"))
e=t:taboption("language",ListValue,"_lang",translate("Language"))
e:value("auto")
local n=luci.i18n.i18ndir.."base."
for t,o in luci.util.kspairs(s.languages)do
local a=n..t:gsub("_","-")
if t:sub(1,1)~="."and i.access(a..".lmo")then
e:value(t,o)
end
end
function e.cfgvalue(...)
return a.uci:get("luci","main","lang")
end
function e.write(o,o,t)
a.uci:set("luci","main","lang",t)
end
e=t:taboption("language",ListValue,"_mediaurlbase",translate("Design"))
for t,a in pairs(s.themes)do
if t:sub(1,1)~="."then
e:value(a,t)
end
end
function e.cfgvalue(...)
return a.uci:get("luci","main","mediaurlbase")
end
function e.write(t,t,e)
a.uci:set("luci","main","mediaurlbase",e)
end
if h then
if a:formvalue("cbid.system._timeserver._enable")then
a.uci:section("system","timeserver","ntp",
{
server={"0.openwrt.pool.ntp.org","1.openwrt.pool.ntp.org","2.openwrt.pool.ntp.org","3.openwrt.pool.ntp.org"}
}
)
a.uci:save("system")
luci.http.redirect(luci.dispatcher.build_url("admin/system",arg[1]))
return
end
local i=false
a.uci:foreach("system","timeserver",
function(e)
i=true
return false
end)
if not i then
t=a:section(TypedSection,"timeserver",translate("Time Synchronization"))
t.anonymous=true
t.cfgsections=function()return{"_timeserver"}end
x=t:option(Button,"_enable")
x.title=translate("Time Synchronization is not configured yet.")
x.inputtitle=translate("Set up Time Synchronization")
x.inputstyle="apply"
else
t=a:section(TypedSection,"timeserver",translate("Time Synchronization"))
t.anonymous=true
t.addremove=false
e=t:option(Flag,"enable",translate("Enable NTP client"))
e.rmempty=false
function e.cfgvalue(e)
return o.init.enabled("sysntpd")
and e.enabled or e.disabled
end
function e.write(a,i,t)
if t==a.enabled then
o.init.enable("sysntpd")
o.call("env -i /etc/init.d/sysntpd start >/dev/null")
else
o.call("env -i /etc/init.d/sysntpd stop >/dev/null")
o.init.disable("sysntpd")
end
end
e=t:option(Flag,"enable_server",translate("Provide NTP server"))
e:depends("enable","1")
e=t:option(DynamicList,"server",translate("NTP server candidates"))
e.datatype="host(0)"
e:depends("enable","1")
function e.remove()end
end
end
return a
