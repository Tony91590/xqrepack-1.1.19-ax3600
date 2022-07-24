local o=require"luci.util"
local e=require"luci.config"
local h=require"luci.template.parser"
local r,t,t=tostring,pairs,loadstring
local s,t=setmetatable,loadfile
local i,d,l=getfenv,setfenv,rawget
local t,t,n=assert,type,error
module"luci.template"
e.template=e.template or{}
viewdir=e.template.viewdir or o.libpath().."/view"
context=o.threadlocal()
function render(e,t)
return Template(e):render(t or i(2))
end
function render_string(t,e)
return Template(nil,t):render(e or i(2))
end
Template=o.class()
Template.cache=s({},{__mode="v"})
function Template.__init__(e,t,i)
if t then
e.template=e.cache[t]
e.name=t
else
e.name="[string]"
end
e.viewns=context.viewns
if not e.template then
local o
local a
if t then
a=viewdir.."/"..t..".htm"
e.template,_,o=h.parse(a)
else
a="[string]"
e.template,_,o=h.parse_string(i)
end
if not e.template then
n("Failed to load template '"..t.."'.\n"..
"Error while parsing template '"..a.."':\n"..
(o or"Unknown syntax error"))
elseif t then
e.cache[t]=e.template
end
end
end
function Template.render(e,t)
t=t or i(2)
d(e.template,s({},{__index=
function(o,a)
return l(o,a)or e.viewns[a]or t[a]
end}))
local t,a=o.copcall(e.template)
if not t then
n("Failed to execute template '"..e.name.."'.\n"..
"A runtime error occured: "..r(a or"(nil)"))
end
end
