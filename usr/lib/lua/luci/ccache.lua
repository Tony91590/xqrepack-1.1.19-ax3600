local m=require"io"
local a=require"nixio.fs"
local u=require"luci.util"
local s=require"nixio"
local e=require"debug"
local i=require"string"
local n=require"package"
local c,h=type,loadfile
module"luci.ccache"
function cache_ondemand(...)
if e.getinfo(1,'S').source~="=?"then
cache_enable(...)
end
end
function cache_enable(e,t)
e=e or"/tmp/luci-modulecache"
t=t or"r--r--r--"
local l=n.loaders[2]
local o=s.getuid()
if not a.stat(e)then
a.mkdir(e)
end
local function d(t)
local e=""
for a=1,#t do
e=e..("%2X"%i.byte(t,a))
end
return e
end
local function r(i)
local e=a.stat(i)
if e and e.uid==o and e.modestr==t then
return h(i)
end
end
local function h(i,h)
if s.getuid()==o then
local e=m.open(i,"w")
if e then
e:write(u.get_bytecode(h))
e:close()
a.chmod(i,t)
end
end
end
n.loaders[2]=function(a)
local t=e.."/"..d(a)
local e=r(t)
if e then
return e
end
e=l(a)
if c(e)=="function"then
h(t,e)
end
return e
end
end
