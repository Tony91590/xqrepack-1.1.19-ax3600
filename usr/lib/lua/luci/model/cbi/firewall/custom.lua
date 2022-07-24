local a=require"nixio.fs"
local t=SimpleForm("firewall",
translate("Firewall - Custom Rules"),
translate("Custom rules allow you to execute arbitrary iptables commands \
		which are not otherwise covered by the firewall framework. \
		The commands are executed after each firewall restart, right after \
		the default ruleset has been loaded."))
local e=t:field(Value,"_custom")
e.template="cbi/tvalue"
e.rows=20
function e.cfgvalue(e,e)
return a.readfile("/etc/firewall.user")
end
function e.write(o,o,e)
e=e:gsub("\r\n?","\n")
a.writefile("/etc/firewall.user",e)
require("luci.sys").call("/etc/init.d/firewall restart >/dev/null 2<&1")
require("nixio").syslog('info','Restarting firewall on custom /etc/firewall.user change')
end
t.submit=translate("Restart Firewall")
return t
