local e=require"nixio"
local n=require"nixio.fs"
local t=require"luci.dispatcher"
local i=require"luci.sys"
local e=require"luci.controller.ddns"
local o=require"luci.tools.ddns"
local a=Map("ddns")
a.title=e.app_title_back()
a.description=e.app_description()
a.redirect=t.build_url("admin","services","ddns")
function a.commit_handler(t)
if t.changed then
local e=e.luci_helper.." -- reload"
os.execute(e)
end
end
local t=a:section(NamedSection,"global","ddns",
translate("Global Settings"),
translate("Configure here the details for all Dynamic DNS services including this LuCI application.")
..[[<br /><strong>]]
..translate("It is NOT recommended for casual users to change settings on this page.")
..[[</strong><br />]]
..[[<a href="https://openwrt.org/docs/guide-user/base-system/ddns#section_ddns" target="_blank">]]
..translate("For detailed information about parameter settings look here.")
..[[</a>]]
)
function t.cfgvalue(e,t)
if not e.map:get(t)then
e.map:set(t,nil,e.sectiontype)
end
return e.map:get(t)
end
local e=t:option(Flag,"upd_privateip")
e.title=translate("Allow non-public IP's")
e.description=translate("Non-public and by default blocked IP's")..":"
..[[<br /><strong>IPv4: </strong>]]
.."0/8, 10/8, 100.64/10, 127/8, 169.254/16, 172.16/12, 192.168/16"
..[[<br /><strong>IPv6: </strong>]]
.."::/32, f000::/4"
e.default="0"
local e=t:option(Value,"ddns_dateformat")
e.title=translate("Date format")
e.description=[[<a href="http://www.cplusplus.com/reference/ctime/strftime/" target="_blank">]]
..translate("For supported codes look here")
..[[</a>]]
e.template="ddns/global_value"
e.default="%F %R"
e.date_string=""
function e.cfgvalue(e,t)
local t=AbstractValue.cfgvalue(e,t)or e.default
local a=os.time()
e.date_string=o.epoch2date(a,t)
return t
end
function e.parse(e,a,t)
o.value_parse(e,a,t)
end
local e=t:option(Value,"ddns_rundir")
e.title=translate("Status directory")
e.description=translate("Directory contains PID and other status information for each running section")
e.default="/var/run/ddns"
function e.parse(a,t,e)
o.value_parse(a,t,e)
end
local e=t:option(Value,"ddns_logdir")
e.title=translate("Log directory")
e.description=translate("Directory contains Log files for each running section")
e.default="/var/log/ddns"
function e.parse(e,t,a)
o.value_parse(e,t,a)
end
local e=t:option(Value,"ddns_loglines")
e.title=translate("Log length")
e.description=translate("Number of last lines stored in log files")
e.default="250"
function e.validate(a,t)
local e=tonumber(t)
if not e or math.floor(e)~=e or e<1 then
return nil,a.title..": "..translate("minimum value '1'")
end
return t
end
function e.parse(t,e,a)
o.value_parse(t,e,a)
end
if(i.call([[ grep -i "\+ssl" /usr/bin/wget >/dev/null 2>&1 ]])==0)
and n.access("/usr/bin/curl")then
local e=t:option(Flag,"use_curl")
e.title=translate("Use cURL")
e.description=translate("If both cURL and GNU Wget are installed, Wget is used by default.")
..[[<br />]]
..translate("To use cURL activate this option.")
e.orientation="horizontal"
e.default="0"
end
return a
