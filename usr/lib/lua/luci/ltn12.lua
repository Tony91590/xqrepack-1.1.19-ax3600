local s=require("string")
local i=require("table")
local t=_G
module("luci.ltn12")
filter={}
source={}
sink={}
pump={}
BLOCKSIZE=2048
_VERSION="LTN12 1.0.1"
function filter.cycle(a,o,i)
t.assert(a)
return function(t)
local e
e,o=a(o,t,i)
return e
end
end
function filter.chain(...)
local n=i.getn(arg)
local o,a=1,1
local i=""
return function(e)
i=e and i
while true do
if a==o then
e=arg[a](e)
if e==""or o==n then return e
elseif e then a=a+1
else
o=o+1
a=o
end
else
e=arg[a](e or"")
if e==""then
a=a-1
e=i
elseif e then
if a==n then return e
else a=a+1 end
else t.error("filter returned inappropriate nil")end
end
end
end
end
local function e()
return nil
end
function source.empty()
return e
end
function source.error(e)
return function()
return nil,e
end
end
function source.file(t,a)
if t then
return function()
local e=t:read(BLOCKSIZE)
if e and e:len()==0 then e=nil end
if not e then t:close()end
return e
end
else return source.error(a or"unable to open file")end
end
function source.simplify(e)
t.assert(e)
return function()
local t,a=e()
e=a or e
if not t then return nil,a
else return t end
end
end
function source.string(t)
if t then
local e=1
return function()
local t=s.sub(t,e,e+BLOCKSIZE-1)
e=e+BLOCKSIZE
if t~=""then return t
else return nil end
end
else return source.empty()end
end
function source.rewind(a)
t.assert(a)
local t={}
return function(e)
if not e then
e=i.remove(t)
if not e then return a()
else return e end
else
t[#t+1]=e
end
end
end
function source.chain(s,n)
t.assert(s and n)
local a,e="",""
local i="feeding"
local o
return function()
if not e then
t.error('source is empty!',2)
end
while true do
if i=="feeding"then
a,o=s()
if o then return nil,o end
e=n(a)
if not e then
if a then
t.error('filter returned inappropriate nil')
else
return nil
end
elseif e~=""then
i="eating"
if a then a=""end
return e
end
else
e=n(a)
if e==""then
if a==""then
i="feeding"
else
t.error('filter returned ""')
end
elseif not e then
if a then
t.error('filter returned inappropriate nil')
else
return nil
end
else
return e
end
end
end
end
end
function source.cat(...)
local e=i.remove(arg,1)
return function()
while e do
local a,t=e()
if a then return a end
if t then return nil,t end
e=i.remove(arg,1)
end
end
end
function sink.table(e)
e=e or{}
local t=function(t,a)
if t then e[#e+1]=t end
return 1
end
return t,e
end
function sink.simplify(e)
t.assert(e)
return function(a,t)
local a,t=e(a,t)
if not a then return nil,t end
e=t or e
return 1
end
end
function sink.file(e,a)
if e then
return function(t,a)
if not t then
e:close()
return 1
else return e:write(t)end
end
else return sink.error(a or"unable to open file")end
end
local function e()
return 1
end
function sink.null()
return e
end
function sink.error(e)
return function()
return nil,e
end
end
function sink.chain(e,o)
t.assert(e and o)
return function(a,i)
if a~=""then
local t=e(a)
local a=a and""
while true do
local i,o=o(t,i)
if not i then return nil,o end
if t==a then return 1 end
t=e(a)
end
else return 1 end
end
end
function pump.step(e,a)
local t,e=e()
local a,o=a(t,e)
if t and a then return 1
else return nil,e or o end
end
function pump.all(a,o,e)
t.assert(a and o)
e=e or pump.step
while true do
local t,e=e(a,o)
if not t then
if e then return nil,e
else return 1 end
end
end
end
