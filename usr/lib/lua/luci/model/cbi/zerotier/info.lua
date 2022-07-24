local e=require"nixio.fs"
local a="/tmp/zero.info"
f=SimpleForm("logview")
t=f:field(TextValue,"conf")
t.rmempty=true
t.rows=19
function t.cfgvalue()
luci.sys.exec("for i in $(ifconfig | grep 'zt' | awk '{print $1}'); do ifconfig $i; done > /tmp/zero.info")
return e.readfile(a)or""
end
t.readonly="readonly"
return f
