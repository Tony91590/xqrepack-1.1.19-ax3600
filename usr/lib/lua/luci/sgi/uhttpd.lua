require"nixio.util"
require"luci.http"
require"luci.sys"
require"luci.dispatcher"
require"luci.ltn12"
function handle_request(e)
exectime=os.clock()
local t={
CONTENT_LENGTH=e.CONTENT_LENGTH,
CONTENT_TYPE=e.CONTENT_TYPE,
REQUEST_METHOD=e.REQUEST_METHOD,
REQUEST_URI=e.REQUEST_URI,
PATH_INFO=e.PATH_INFO,
SCRIPT_NAME=e.SCRIPT_NAME:gsub("/+$",""),
SCRIPT_FILENAME=e.SCRIPT_NAME,
SERVER_PROTOCOL=e.SERVER_PROTOCOL,
QUERY_STRING=e.QUERY_STRING
}
local a,a
for e,a in pairs(e.headers)do
e=e:upper():gsub("%-","_")
t["HTTP_"..e]=a
end
local e=tonumber(e.CONTENT_LENGTH)or 0
local function o()
if e>0 then
local t,a=uhttpd.recv(4096)
if t>=0 then
e=e-t
return a
end
end
return nil
end
local e=uhttpd.send
local a=luci.http.Request(
t,o,luci.ltn12.sink.file(io.stderr)
)
local t=coroutine.create(luci.dispatcher.httpdispatch)
local n={}
local i=true
while coroutine.status(t)~="dead"do
local s,t,a,o=coroutine.resume(t,a)
if not s then
e("Status: 500 Internal Server Error\r\n")
e("Content-Type: text/plain\r\n\r\n")
e(tostring(t))
break
end
if i then
if t==1 then
e("Status: ")
e(tostring(a))
e(" ")
e(tostring(o))
e("\r\n")
elseif t==2 then
n[a]=o
elseif t==3 then
for a,t in pairs(n)do
e(tostring(a))
e(": ")
e(tostring(t))
e("\r\n")
end
e("\r\n")
elseif t==4 then
e(tostring(a or""))
elseif t==5 then
i=false
elseif t==6 then
a:copyz(nixio.stdout,o)
end
end
end
end
