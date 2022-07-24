module("luci.http.protocol",package.seeall)
local h=require("luci.ltn12")
HTTP_MAX_CONTENT=1024*8
function urldecode(e,a)
local function t(e)
return string.char(tonumber(e,16))
end
if type(e)=="string"then
if not a then
e=e:gsub("+"," ")
end
e=e:gsub("%%([a-fA-F0-9][a-fA-F0-9])",t)
end
return e
end
function urldecode_params(e,t)
local t=t or{}
if e:find("?")then
e=e:gsub("^.+%?([^?]+)","%1")
end
for a in e:gmatch("[^&;]+")do
local e=urldecode(a:match("^([^=]+)"))
local a=urldecode(a:match("^[^=]+=(.+)$"))
if type(e)=="string"and e:len()>0 then
if type(a)~="string"then a=""end
if not t[e]then
t[e]=a
elseif type(t[e])~="table"then
t[e]={t[e],a}
else
table.insert(t[e],a)
end
end
end
return t
end
function urlencode(e)
local function t(e)
return string.format(
"%%%02x",string.byte(e)
)
end
if type(e)=="string"then
e=e:gsub(
"([^a-zA-Z0-9$_%-%.%~])",
t
)
end
return e
end
function urlencode_params(t)
local e=""
for a,t in pairs(t)do
if type(t)=="table"then
for o,t in ipairs(t)do
e=e..(#e>0 and"&"or"")..
urlencode(a).."="..urlencode(t)
end
else
e=e..(#e>0 and"&"or"")..
urlencode(a).."="..urlencode(t)
end
end
return e
end
local function u(t,e)
if t[e]==nil then
t[e]=""
elseif type(t[e])=="string"then
t[e]={t[e],""}
else
table.insert(t[e],"")
end
end
local function m(t,e,o,a)
if t[e]==nil then
t[e]={file=o,fd=a,name=e,""}
else
table.insert(t[e],"")
end
end
local function d(t,e,a)
if type(t[e])=="table"then
t[e][#t[e]]=t[e][#t[e]]..a
else
t[e]=t[e]..a
end
end
local function f(e,t,a)
if a then
if type(e[t])=="table"then
e[t][#e[t]]=a(e[t][#e[t]])
else
e[t]=a(e[t])
end
end
end
local r={}
r['magic']=function(e,t,a)
if t~=nil then
if#t==0 then
return true,nil
end
local a,o,i=t:match("^([A-Z]+) ([^ ]+) HTTP/([01]%.[019])$")
if a then
e.type="request"
e.request_method=a:lower()
e.request_uri=o
e.http_version=tonumber(i)
e.headers={}
return true,function(t)
return r['headers'](e,t)
end
else
local o,t,a=t:match("^HTTP/([01]%.[019]) ([0-9]+) ([^\r\n]+)$")
if t then
e.type="response"
e.status_code=t
e.status_message=a
e.http_version=tonumber(o)
e.headers={}
return true,function(t)
return r['headers'](e,t)
end
end
end
end
return nil,"Invalid HTTP message magic"
end
r['headers']=function(o,a)
if a~=nil then
local e,t=a:match("^([A-Za-z][A-Za-z0-9%-_]+): +(.+)$")
if type(e)=="string"and e:len()>0 and
type(t)=="string"and t:len()>0
then
o.headers[e]=t
return true,nil
elseif#a==0 then
return false,nil
else
return nil,"Invalid HTTP header received"
end
else
return nil,"Unexpected EOF"
end
end
function header_source(e)
return h.source.simplify(function()
local e,t,a=e:receive("*l")
if e==nil then
if t~="timeout"then
return nil,a
and"Line exceeds maximum allowed length"
or"Unexpected EOF"
else
return nil,t
end
elseif e~=nil then
e=e:gsub("\r$","")
return e,nil
end
end)
end
function mimedecode_message_body(f,t,c)
if t and t.env.CONTENT_TYPE then
t.mime_boundary=t.env.CONTENT_TYPE:match("^multipart/form%-data; boundary=(.+)$")
end
if not t.mime_boundary then
return nil,"Invalid Content-Type found"
end
local s=0
local r=false
local n=nil
local a=nil
local o=nil
local function l(o,e)
local i
repeat
o,i=o:gsub(
"^([A-Z][A-Za-z0-9%-_]+): +([^\r\n]+)\r\n",
function(a,t)
e.headers[a]=t
return""
end
)
until i==0
o,i=o:gsub("^\r\n","")
if i>0 then
if e.headers["Content-Disposition"]then
if e.headers["Content-Disposition"]:match("^form%-data; ")then
e.name=e.headers["Content-Disposition"]:match('name="(.-)"')
e.file=e.headers["Content-Disposition"]:match('filename="(.+)"$')
end
end
if not e.headers["Content-Type"]then
e.headers["Content-Type"]="text/plain"
end
if e.name and e.file and c then
u(t.params,e.name)
d(t.params,e.name,e.file)
a=c
elseif e.name and e.file then
local o=require"nixio"
local o=o.mkstemp(e.name)
m(t.params,e.name,e.file,o)
if o then
a=function(a,e,t)
o:write(e)
if(t)then
o:seek(0,"set")
end
end
else
a=function(o,a,o)
d(t.params,e.name,a)
end
end
elseif e.name then
u(t.params,e.name)
a=function(o,a,o)
d(t.params,e.name,a)
end
else
a=nil
end
return o,true
end
return o,false
end
local function u(i)
s=s+(i and#i or 0)
if t.env.CONTENT_LENGTH and s>tonumber(t.env.CONTENT_LENGTH)+2 then
return nil,"Message body size exceeds Content-Length"
end
if i and not o then
o="\r\n"..i
elseif o then
local e=o..(i or"")
local s,h,d
repeat
s,h=e:find("\r\n--"..t.mime_boundary.."\r\n",1,true)
if not s then
s,h=e:find("\r\n--"..t.mime_boundary.."--\r\n",1,true)
end
if s then
local t=e:sub(1,s-1)
if r then
t,eof=l(t,n)
if not eof then
return nil,"Invalid MIME section header"
elseif not n.name then
return nil,"Invalid Content-Disposition header"
end
end
if a then
a(n,t,true)
end
n={headers={}}
d=d or true
e,eof=l(e:sub(h+1,#e),n)
r=not eof
end
until not s
if d then
o,e=e,nil
else
if r then
o,eof=l(e,n)
r=not eof
else
a(n,o,false)
o,i=i,nil
end
end
end
return true
end
return h.pump.all(f,u)
end
function urldecode_message_body(s,a)
local o=0
local t=nil
local function n(e)
o=o+(e and#e or 0)
if a.env.CONTENT_LENGTH and o>tonumber(a.env.CONTENT_LENGTH)+2 then
return nil,"Message body size exceeds Content-Length"
elseif o>HTTP_MAX_CONTENT then
return nil,"Message body size exceeds maximum allowed length"
end
if not t and e then
t=e
elseif t then
local e=t..(e or"&")
local o,i
repeat
o,i=e:find("^.-[;&]")
if o then
local o=e:sub(o,i-1)
local t=o:match("^(.-)=")
local o=o:match("=([^%s]*)%s*$")
if t and#t>0 then
u(a.params,t)
d(a.params,t,o)
f(a.params,t,urldecode)
end
e=e:sub(i+1,#e)
end
until not o
t=e
end
return true
end
return h.pump.all(s,n)
end
function parse_message_header(a)
local t=true
local e={}
local o=h.sink.simplify(
function(t)
return r['magic'](e,t)
end
)
while t do
t,err=h.pump.step(a,o)
if not t and err then
return nil,err
elseif not t then
if(e.request_method=="get"or e.request_method=="post")and
e.request_uri:match("?")
then
e.params=urldecode_params(e.request_uri)
else
e.params={}
end
e.env={
CONTENT_LENGTH=e.headers['Content-Length'];
CONTENT_TYPE=e.headers['Content-Type']or e.headers['Content-type'];
REQUEST_METHOD=e.request_method:upper();
REQUEST_URI=e.request_uri;
SCRIPT_NAME=e.request_uri:gsub("?.+$","");
SCRIPT_FILENAME="";
SERVER_PROTOCOL="HTTP/"..string.format("%.1f",e.http_version);
QUERY_STRING=e.request_uri:match("?")
and e.request_uri:gsub("^.+?","")or""
}
for a,t in ipairs({
'Accept',
'Accept-Charset',
'Accept-Encoding',
'Accept-Language',
'Connection',
'Cookie',
'Host',
'Referer',
'User-Agent',
})do
local a='HTTP_'..t:upper():gsub("%-","_")
local t=e.headers[t]
e.env[a]=t
end
end
end
return e
end
function parse_message_body(o,e,t)
if e.env.REQUEST_METHOD=="POST"and e.env.CONTENT_TYPE and
e.env.CONTENT_TYPE:match("^multipart/form%-data")
then
return mimedecode_message_body(o,e,t)
elseif e.env.REQUEST_METHOD=="POST"and e.env.CONTENT_TYPE and
e.env.CONTENT_TYPE:match("^application/x%-www%-form%-urlencoded")
then
return urldecode_message_body(o,e,t)
else
local a
if type(t)=="function"then
local o={
name="raw",
encoding=e.env.CONTENT_TYPE
}
a=function(e)
if e then
return t(o,e,false)
else
return t(o,nil,true)
end
end
else
e.content=""
e.content_length=0
a=function(t)
if t then
if(e.content_length+#t)<=HTTP_MAX_CONTENT then
e.content=e.content..t
e.content_length=e.content_length+#t
return true
else
return nil,"POST data exceeds maximum allowed length"
end
end
return true
end
end
while true do
local t,e=h.pump.step(o,a)
if not t and e then
return nil,e
elseif not t then
return true
end
end
return true
end
end
statusmsg={
[200]="OK",
[206]="Partial Content",
[301]="Moved Permanently",
[302]="Found",
[304]="Not Modified",
[400]="Bad Request",
[403]="Forbidden",
[404]="Not Found",
[405]="Method Not Allowed",
[408]="Request Time-out",
[411]="Length Required",
[412]="Precondition Failed",
[416]="Requested range not satisfiable",
[500]="Internal Server Error",
[503]="Server Unavailable",
}
