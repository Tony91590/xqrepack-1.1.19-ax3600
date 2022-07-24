local a=require"nixio.fs"
local e="/etc/crontabs/root"
f=SimpleForm("crontab",translate("Scheduled Tasks"),
translate("This is the system crontab in which scheduled tasks can be defined.")..
translate("<br/>Note: you need to manually restart the cron service if the "..
"crontab file was empty before editing."))
t=f:field(TextValue,"crons")
t.rmempty=true
t.rows=10
function t.cfgvalue()
return a.readfile(e)or""
end
function f.handle(i,o,t)
if o==FORM_VALID then
if t.crons then
a.writefile(e,t.crons:gsub("\r\n","\n"))
luci.sys.call("/usr/bin/crontab %q"%e)
else
a.writefile(e,"")
end
end
return true
end
return f
