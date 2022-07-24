local d=require"os"
local e=require"uci"
local r=require"luci.util"
local n=require"table"
local t,t,t=setmetatable,rawget,rawset
local t,o=require,getmetatable
local a,i,t=error,pairs,ipairs
local a,l,h,s=type,tostring,tonumber,unpack
module"luci.model.uci"
cursor=e.cursor
APIVERSION=e.APIVERSION
function cursor_state()
return cursor(nil,"/var/state")
end
inst=cursor()
inst_state=cursor_state()
local e=o(inst)
function e.apply(t,e,a)
e=t:_affected(e)
if a then
return{"/sbin/luci-reload",s(e)}
else
return d.execute("/sbin/luci-reload %s >/dev/null 2>&1"
%n.concat(e," "))
end
end
function e.delete_all(s,n,h,e)
local o={}
if a(e)=="table"then
local t=e
e=function(e)
for a,t in i(t)do
if e[a]~=t then
return false
end
end
return true
end
end
local function a(t)
if not e or e(t)then
o[#o+1]=t[".name"]
end
end
s:foreach(n,h,a)
for t,e in t(o)do
s:delete(n,e)
end
end
function e.section(o,a,i,e,n)
local t=true
if e then
t=o:set(a,e,i)
else
e=o:add(a,i)
t=e and true
end
if t and n then
t=o:tset(a,e,n)
end
return t and e
end
function e.tset(n,a,o,t)
local e=true
for t,i in i(t)do
if t:sub(1,1)~="."then
e=e and n:set(a,o,t,i)
end
end
return e
end
function e.get_bool(e,...)
local e=e:get(...)
return(e=="1"or e=="true"or e=="yes"or e=="on")
end
function e.get_list(i,e,t,o)
if e and t and o then
local e=i:get(e,t,o)
return(a(e)=="table"and e or{e})
end
return{}
end
function e.get_first(n,i,s,e,t)
local o=t
n:foreach(i,s,
function(i)
local e=not e and i['.name']or i[e]
if a(t)=="number"then
e=h(e)
elseif a(t)=="boolean"then
e=(e=="1"or e=="true"or
e=="yes"or e=="on")
end
if e~=nil then
o=e
return false
end
end)
return o
end
function e.set_list(n,t,o,i,e)
if t and o and i then
if not e or#e==0 then
return n:delete(t,o,i)
end
return n:set(
t,o,i,
(a(e)=="table"and e or{e})
)
end
return false
end
function e._affected(o,e)
e=a(e)=="table"and e or{e}
local n=cursor()
n:load("ucitrack")
local a={}
local function o(i)
local a={i}
local e={}
n:foreach("ucitrack",i,
function(a)
if a.affects then
for a,t in t(a.affects)do
e[#e+1]=t
end
end
end)
for i,e in t(e)do
for t,e in t(o(e))do
a[#a+1]=e
end
end
return a
end
for i,e in t(e)do
for t,e in t(o(e))do
if not r.contains(a,e)then
a[#a+1]=e
end
end
end
return a
end
function e.substate(t)
e._substates=e._substates or{}
e._substates[t]=e._substates[t]or cursor_state()
return e._substates[t]
end
local a=e.load
function e.load(t,...)
if e._substates and e._substates[t]then
a(e._substates[t],...)
end
return a(t,...)
end
local a=e.unload
function e.unload(t,...)
if e._substates and e._substates[t]then
a(e._substates[t],...)
end
return a(t,...)
end
