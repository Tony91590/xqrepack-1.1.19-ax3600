local o=require"os"
local s=require"io"
local a=require"nixio.fs"
local l=require"luci.util"
local h=type
local t=pairs
local r=error
local n=table
local d="opkg --force-removal-of-dependent-packages --force-overwrite --nocase"
local c="/etc/opkg.conf"
module"luci.model.ipkg"
local function i(i,...)
local e=""
for a,t in t({...})do
e=e.." '"..t:gsub("'","").."'"
end
local e="%s %s %s >/tmp/opkg.stdout 2>/tmp/opkg.stderr"%{d,i,e}
local o=o.execute(e)
local t=a.readfile("/tmp/opkg.stderr")
local e=a.readfile("/tmp/opkg.stdout")
a.unlink("/tmp/opkg.stderr")
a.unlink("/tmp/opkg.stdout")
return o,e or"",t or""
end
local function u(t)
if h(t)~="function"then
r("OPKG: Invalid rawdata given")
end
local n={}
local e={}
local i=nil
for o in t do
if o:sub(1,1)~=" "then
local t,a=o:match("(.-): ?(.*)%s*")
if t and a then
if t=="Package"then
e={Package=a}
n[a]=e
elseif t=="Status"then
e.Status={}
for t in a:gmatch("([^ ]+)")do
e.Status[t]=true
end
else
e[t]=a
end
i=t
end
else
e[i]=e[i].."\n"..o
end
end
return n
end
local function h(e,t)
local e=d.." "..e
if t then
e=e.." '"..t:gsub("'","").."'"
end
local t=o.tmpname()
o.execute(e..(" >%s 2>/dev/null"%t))
local e=u(s.lines(t))
o.remove(t)
return e
end
function info(e)
return h("info",e)
end
function status(e)
return h("status",e)
end
function install(...)
return i("install",...)
end
function installed(e)
local e=status(e)[e]
return(e and e.Status and e.Status.installed)
end
function remove(...)
return i("remove",...)
end
function update()
return i("update")
end
function upgrade()
return i("upgrade")
end
local function h(t,e,h)
local n=s.popen(d.." "..t..
(e and(" '%s'"%e:gsub("'",""))or""))
if n then
local t,e,a,o
while true do
local i=n:read("*l")
if not i then break end
t,e,a,o=i:match("^(.-) %- (.-) %- (.-) %- (.+)")
if not t then
t,e,a=i:match("^(.-) %- (.-) %- (.+)")
o=""
end
if t and e then
if#e>26 then
e=e:sub(1,21)..".."..e:sub(-3,-1)
end
h(t,e,a,o)
end
t=nil
e=nil
a=nil
o=nil
end
n:close()
end
end
function list_all(t,e)
h("list --size",t,e)
end
function list_installed(e,t)
h("list_installed --size",e,t)
end
function find(t,e)
h("find --size",t,e)
end
function overlay_root()
local t="/"
local o=s.open(c,"r")
if o then
local e
repeat
e=o:read("*l")
if e and e:match("^%s*option%s+overlay_root%s+")then
t=e:match("^%s*option%s+overlay_root%s+(%S+)")
local e=a.stat(t)
if not e or e.type~="dir"then
t="/"
end
break
end
until not e
o:close()
end
return t
end
function compare_versions(t,e,a)
if not t or not a
or not e or not(#e>0)then
r("Invalid parameters")
return nil
end
if e=="<>"or e=="><"or e=="!="or e=="~="then e="~="
elseif e=="<="or e=="<"or e=="=<"then e="<="
elseif e==">="or e==">"or e=="=>"then e=">="
elseif e=="="or e=="=="then e="=="
elseif e=="<<"then e="<"
elseif e==">>"then e=">"
else
r("Invalid compare string")
return nil
end
local t=l.split(t,"[%.%-]",nil,true)
local a=l.split(a,"[%.%-]",nil,true)
local o=n.getn(t)
if(n.getn(t)<n.getn(a))then
o=n.getn(a)
end
for o=1,o,1 do
local t=t[o]or""
local a=a[o]or""
if e=="~="and(t~=a)then return true end
if(e=="<"or e=="<=")and(t<a)then return true end
if(e==">"or e==">=")and(t>a)then return true end
if(t~=a)then return false end
end
return not(e=="<"or e==">")
end
