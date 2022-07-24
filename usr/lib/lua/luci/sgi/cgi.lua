exectime=os.clock()
module("luci.sgi.cgi",package.seeall)
local a=require("luci.ltn12")
require("nixio.util")
require("luci.http")
require("luci.sys")
require("luci.dispatcher")
local function o(t,e)
e=e or 0
local a=a.BLOCKSIZE
return function()
if e<1 then
t:close()
return nil
else
local a=(e>a)and a or e
e=e-a
local e=t:read(a)
if not e then t:close()end
return e
end
end
end
function run()
local t=luci.http.Request(
luci.sys.getenv(),
o(io.stdin,tonumber(luci.sys.getenv("CONTENT_LENGTH"))),
a.sink.file(io.stderr)
)
local e=coroutine.create(luci.dispatcher.httpdispatch)
local o=""
local i=true
while coroutine.status(e)~="dead"do
local n,e,t,a=coroutine.resume(e,t)
if not n then
print("Status: 500 Internal Server Error")
print("Content-Type: text/plain\n")
print(e)
break;
end
if i then
if e==1 then
io.write("Status: "..tostring(t).." "..a.."\r\n")
elseif e==2 then
o=o..t..": "..a.."\r\n"
elseif e==3 then
io.write(o)
io.write("\r\n")
elseif e==4 then
io.write(tostring(t or""))
elseif e==5 then
io.flush()
io.close()
i=false
elseif e==6 then
t:copyz(nixio.stdout,a)
t:close()
end
end
end
end
