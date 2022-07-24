local h=require"nixio.fs"
local o=require"luci.sys"
local a={}
for t,e in ipairs(o.init.names())do
local t=o.init.index(e)
local o=o.init.enabled(e)
if t<255 then
a["%02i.%s"%{t,e}]={
name=e,
index=tostring(t),
enabled=o
}
end
end
m=SimpleForm("initmgr",translate("Initscripts"),translate("You can enable or disable installed init scripts here. Changes will applied after a device reboot.<br /><strong>Warning: If you disable essential init scripts like \"network\", your device might become inaccessible!</strong>"))
m.reset=false
m.submit=false
s=m:section(Table,a)
i=s:option(DummyValue,"index",translate("Start priority"))
n=s:option(DummyValue,"name",translate("Initscript"))
e=s:option(Button,"endisable",translate("Enable/Disable"))
e.render=function(t,o,i)
if a[o].enabled then
t.title=translate("Enabled")
t.inputstyle="save"
else
t.title=translate("Disabled")
t.inputstyle="reset"
end
Button.render(t,o,i)
end
e.write=function(t,e)
if a[e].enabled then
a[e].enabled=false
return o.init.disable(a[e].name)
else
a[e].enabled=true
return o.init.enable(a[e].name)
end
end
start=s:option(Button,"start",translate("Start"))
start.inputstyle="apply"
start.write=function(t,e)
o.call("/etc/init.d/%s %s >/dev/null"%{a[e].name,t.option})
end
restart=s:option(Button,"restart",translate("Restart"))
restart.inputstyle="reload"
restart.write=start.write
stop=s:option(Button,"stop",translate("Stop"))
stop.inputstyle="remove"
stop.write=start.write
f=SimpleForm("rc",translate("Local Startup"),
translate("This is the content of /etc/rc.local. Insert your own commands here (in front of 'exit 0') to execute them at the end of the boot process."))
t=f:field(TextValue,"rcs")
t.rmempty=true
t.rows=20
function t.cfgvalue()
return h.readfile("/etc/rc.local")or""
end
function f.handle(a,t,e)
if t==FORM_VALID then
if e.rcs then
h.writefile("/etc/rc.local",e.rcs:gsub("\r\n","\n"))
end
end
return true
end
return m,f
