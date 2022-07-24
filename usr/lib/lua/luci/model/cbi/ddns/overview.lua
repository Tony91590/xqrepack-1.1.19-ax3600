local t=require"luci.dispatcher"
local d=require"luci.http"
local n=require"luci.sys"
local i=require"luci.controller.ddns"
local e=require"luci.tools.ddns"
local h=not(e.env_info("has_ipv6")
and e.env_info("has_ssl")
and e.env_info("has_proxy")
and e.env_info("has_bindhost")
and e.env_info("has_forceip")
and e.env_info("has_dnsserver")
and e.env_info("has_bindnet")
and e.env_info("has_cacerts")
)
local r=not n.init.enabled("ddns")
local o=not i.service_ok()
font_red=[[<font color="red">]]
font_off=[[</font>]]
bold_on=[[<strong>]]
bold_off=[[</strong>]]
m=Map("ddns")
m.title=i.app_title_main()
m.description=i.app_description()
m.on_after_commit=function(e)
if e.changed then
local e=i.luci_helper
if n.init.enabled("ddns")then
e=e.." -- restart"
os.execute(e)
else
e=e.." -- reload"
os.execute(e)
end
end
end
a=m:section(SimpleSection)
a.template="ddns/overview_status"
if h or o or r then
s=m:section(SimpleSection,translate("Hints"))
if o then
local e=s:option(DummyValue,"_update_needed")
e.titleref=t.build_url("admin","system","packages")
e.rawhtml=true
e.title=font_red..bold_on..
translate("Software update required")..bold_off..font_off
e.value=translate("The currently installed 'ddns-scripts' package did not support all available settings.")..
"<br />"..
translate("Please update to the current version!")
end
if r then
local e=s:option(DummyValue,"_not_enabled")
e.titleref=t.build_url("admin","system","startup")
e.rawhtml=true
e.title=bold_on..
translate("DDNS Autostart disabled")..bold_off
e.value=translate("Currently DDNS updates are not started at boot or on interface events.".."<br />"..
"You can start/stop each configuration here. It will run until next reboot.")
end
if h then
local e=s:option(DummyValue,"_separate")
e.titleref=t.build_url("admin","services","ddns","hints")
e.rawhtml=true
e.title=bold_on..
translate("Show more")..bold_off
e.value=translate("Follow this link".."<br />"..
"You will find more hints to optimize your system to run DDNS scripts with all options")
end
end
ts=m:section(TypedSection,"service",
translate("Overview"),
translate("Below is a list of configured DDNS configurations and their current state.")
.."<br />"
..translate("If you want to send updates for IPv4 and IPv6 you need to define two separate Configurations "
.."i.e. 'myddns_ipv4' and 'myddns_ipv6'")
.."<br />"
..[[<a href="]]..t.build_url("admin","services","ddns","global")..[[">]]
..translate("To change global settings click here")..[[</a>]])
ts.sectionhead=translate("Configuration")
ts.template="cbi/tblsection"
ts.addremove=true
ts.extedit=t.build_url("admin","services","ddns","detail","%s")
function ts.create(e,t)
AbstractSection.create(e,t)
d.redirect(e.extedit:format(t))
end
dom=ts:option(DummyValue,"_lookupIP",
translate("Lookup Hostname").."<br />"..translate("Registered IP"))
dom.template="ddns/overview_doubleline"
function dom.set_one(t,e)
local e=t.map:get(e,"lookup_host")or""
if e~=""then
return e
else
return[[<em>]]..translate("config error")..[[</em>]]
end
end
function dom.set_two(a,t)
local o=e.calc_seconds(
tonumber(a.map:get(t,"check_interval")or"")or 10,
a.map:get(t,"check_unit")or"minutes")
local o=e.get_regip(t,o)
if o=="NOFILE"then
local h=a.map:get(t,"lookup_host")or""
if h==""then return""end
local s=a.map:get(t,"dnsserver")or""
local l=tonumber(a.map:get(t,"use_ipv6")or 0)
local r=tonumber(a.map:get(t,"force_ipversion")or 0)
local d=tonumber(a.map:get(t,"force_dnstcp")or 0)
local a=tonumber(a.map:get(t,"is_glue")or 0)
local e=i.luci_helper..[[ -]]
if(l==1)then e=e..[[6]]end
if(r==1)then e=e..[[f]]end
if(d==1)then e=e..[[t]]end
if(a==1)then e=e..[[g]]end
e=e..[[l ]]..h
e=e..[[ -S ]]..t
if(#s>0)then e=e..[[ -d ]]..s end
e=e..[[ -- get_registered_ip]]
o=n.exec(e)
end
if o==""then o=translate("no data")end
return o
end
ena=ts:option(Flag,"enabled",
translate("Enabled"))
ena.template="ddns/overview_enabled"
ena.rmempty=false
upd=ts:option(DummyValue,"_update",
translate("Last Update").."<br />"..translate("Next Update"))
upd.template="ddns/overview_doubleline"
function upd.set_one(a,t)
local a=n.uptime()
local t=e.get_lastupd(t)
if t>a then
t=0
end
if t==0 then
return translate("never")
else
local t=os.time()-a+t
return e.epoch2date(t)
end
end
function upd.set_two(a,o)
local h=tonumber(a.map:get(o,"enabled")or 0)
local t=translate("unknown error")
local i=tonumber(a.map:get(o,"force_interval")or 72)
local a=a.map:get(o,"force_unit")or"hours"
local s=e.calc_seconds(i,a)
local i=n.uptime()
local a=e.get_lastupd(o)
if a>i then
a=0
end
local o=e.get_pid(o)
if a>0 then
local t=os.time()-i+a+s
datelast=e.epoch2date(t)
end
if o>0 and(a+s-i)<0 then
t=translate("Verify")
elseif s==0 then
t=translate("Run once")
elseif o==0 and h==0 then
t=translate("Disabled")
elseif o==0 and h~=0 then
t=translate("Stopped")
end
return t
end
btn=ts:option(Button,"_startstop",
translate("Process ID").."<br />"..translate("Start / Stop"))
btn.template="ddns/overview_startstop"
function btn.cfgvalue(a,t)
local e=e.get_pid(t)
if e>0 then
btn.inputtitle="PID: "..e
btn.inputstyle="reset"
btn.disabled=false
elseif(a.map:get(t,"enabled")or"0")~="0"then
btn.inputtitle=translate("Start")
btn.inputstyle="apply"
btn.disabled=false
else
btn.inputtitle="----------"
btn.inputstyle="button"
btn.disabled=true
end
return true
end
return m
