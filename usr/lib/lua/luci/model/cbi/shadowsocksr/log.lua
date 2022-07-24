require"luci.util"
require"nixio.fs"
f=SimpleForm("logview")
f.reset=false
f.submit=false
t=f:field(TextValue,"conf")
t.rmempty=true
t.rows=20
function t.cfgvalue()
if nixio.fs.access("/var/log/ssrplus.log")then
local t=luci.util.execi("cat /var/log/ssrplus.log")
local e=""
for t in t do
e=t.."\n"..e
end
return e
end
end
t.readonly="readonly"
return f
