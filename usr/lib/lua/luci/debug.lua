local e=require"debug"
local t=require"io"
local d,h=collectgarbage,math.floor
module"luci.debug"
__file__=e.getinfo(1,'S').source:sub(2)
function trap_memtrace(o,a)
o=o or"clr"
local i=t.open(a or"/tmp/memtrace","w")
local a=0
local function r(n,s)
local t=e.getinfo(2,"Sn")
local o=h(d("count"))
if o>a then
a=o
end
if i then
i:write(
"[",n,"] ",t.source,":",(s or"?"),"\t",
(t.namewhat or""),"\t",
(t.name or""),"\t",
o," (",a,")\n"
)
end
end
e.sethook(r,o)
return function()
e.sethook()
i:close()
end
end
