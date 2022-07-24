local e=require"luci.ltn12"
local a=require"luci.http.protocol"
local i=require"luci.util"
local r=require"string"
local t=require"coroutine"
local d=require"table"
local h,o,e,e,n,s=
ipairs,pairs,next,type,tostring,error
module"luci.http"
context=i.threadlocal()
Request=i.class()
function Request.__init__(e,t,o,i)
e.input=o
e.error=i
e.filehandler=nil
e.message={
env=t,
headers={},
params=a.urldecode_params(t.QUERY_STRING or""),
}
e.parsed_input=false
end
function Request.formvalue(e,t,a)
if not a and not e.parsed_input then
e:_parse_input()
end
if t then
return e.message.params[t]
else
return e.message.params
end
end
function Request.formvaluetable(t,e)
local a={}
e=e and e.."."or"."
if not t.parsed_input then
t:_parse_input()
end
local i=t.message.params[nil]
for t,o in o(t.message.params)do
if t:find(e,1,true)==1 then
a[t:sub(#e+1)]=n(o)
end
end
return a
end
function Request.content(e)
if not e.parsed_input then
e:_parse_input()
end
return e.message.content,e.message.content_length
end
function Request.getcookie(t,e)
local t=r.gsub(";"..(t:getenv("HTTP_COOKIE")or"")..";","%s*;%s*",";")
local e=";"..e.."=(.-);"
local t,t,e=t:find(e)
return e and urldecode(e)
end
function Request.getenv(e,t)
if t then
return e.message.env[t]
else
return e.message.env
end
end
function Request.setfilehandler(e,a)
e.filehandler=a
if e.parsed_input then
for t,e in o(e.message.params)do
repeat
if(not e["file"])then break end
if(e["fd"])then
fd=e["fd"]
local t=false
repeat
filedata=fd:read(1024)
if(filedata:len()<1024)then
t=true
end
a({name=e["name"],file=e["file"]},filedata,t)
until(t)
fd:close()
e["fd"]=nil
else
for o,t in h(e)do
a({name=e["name"],file=e["file"]},t,true)
end
end
until true
end
end
end
function Request._parse_input(e)
a.parse_message_body(
e.input,
e.message,
e.filehandler
)
e.parsed_input=true
end
function close()
if not context.eoh then
context.eoh=true
t.yield(3)
end
if not context.closed then
context.closed=true
t.yield(5)
end
end
function content()
return context.request:content()
end
function formvalue(t,e)
return context.request:formvalue(t,e)
end
function formvaluetable(e)
return context.request:formvaluetable(e)
end
function getcookie(e)
return context.request:getcookie(e)
end
function getenv(e)
return context.request:getenv(e)
end
function setfilehandler(e)
return context.request:setfilehandler(e)
end
function header(e,a)
if not context.headers then
context.headers={}
end
context.headers[e:lower()]=a
t.yield(2,e,a)
end
function prepare_content(e)
if not context.headers or not context.headers["content-type"]then
if e=="application/xhtml+xml"then
if not getenv("HTTP_ACCEPT")or
not getenv("HTTP_ACCEPT"):find("application/xhtml+xml",nil,true)then
e="text/html; charset=UTF-8"
end
header("Vary","Accept")
end
header("Content-Type",e)
end
end
function source()
return context.request.input
end
function status(e,a)
e=e or 200
a=a or"OK"
context.status=e
t.yield(1,e,a)
end
function write(e,a)
if not e then
if a then
s(a)
else
close()
end
return true
elseif#e==0 then
return true
else
if not context.eoh then
if not context.status then
status()
end
if not context.headers or not context.headers["content-type"]then
header("Content-Type","text/html; charset=utf-8")
end
if not context.headers["cache-control"]then
header("Cache-Control","no-cache")
header("Pragma","no-cache")
header("Expires","0")
end
context.eoh=true
t.yield(3)
end
t.yield(4,e)
return true
end
end
function splice(e,a)
t.yield(6,e,a)
end
function redirect(e)
if e==""then e="/"end
status(302,"Found")
header("Location",e)
close()
end
function build_querystring(t)
local e={"?"}
for a,t in o(t)do
if#e>1 then e[#e+1]="&"end
e[#e+1]=urldecode(a)
e[#e+1]="="
e[#e+1]=urldecode(t)
end
return d.concat(e,"")
end
urldecode=a.urldecode
urlencode=a.urlencode
function write_json(e)
i.serialize_json(e,write)
end
