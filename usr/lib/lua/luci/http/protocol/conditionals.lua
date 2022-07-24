module("luci.http.protocol.conditionals",package.seeall)
local e=require("luci.http.protocol.date")
function mk_etag(e)
if e~=nil then
return string.format('"%x-%x-%x"',e.ino,e.size,e.mtime)
end
end
function if_match(e,t)
local e=e.headers
local a=mk_etag(t)
if type(e['If-Match'])=="string"then
for e in e['If-Match']:gmatch("([^, ]+)")do
if(e=='*'or e==a)and t~=nil then
return true
end
end
return false,412
end
return true
end
function if_modified_since(a,t)
local a=a.headers
if type(a['If-Modified-Since'])=="string"then
local a=e.to_unix(a['If-Modified-Since'])
if t==nil or a<t.mtime then
return true
end
return false,304,{
["ETag"]=mk_etag(t);
["Date"]=e.to_http(os.time());
["Last-Modified"]=e.to_http(t.mtime)
}
end
return true
end
function if_none_match(a,t)
local o=a.headers
local i=mk_etag(t)
local n=a.env and a.env.REQUEST_METHOD or"GET"
if type(o['If-None-Match'])=="string"then
for a in o['If-None-Match']:gmatch("([^, ]+)")do
if(a=='*'or a==i)and t~=nil then
if n=="GET"or n=="HEAD"then
return false,304,{
["ETag"]=i;
["Date"]=e.to_http(os.time());
["Last-Modified"]=e.to_http(t.mtime)
}
else
return false,412
end
end
end
end
return true
end
function if_range(e,e)
return false,412
end
function if_unmodified_since(t,a)
local t=t.headers
if type(t['If-Unmodified-Since'])=="string"then
local e=e.to_unix(t['If-Unmodified-Since'])
if a~=nil and e<=a.mtime then
return false,412
end
end
return true
end
