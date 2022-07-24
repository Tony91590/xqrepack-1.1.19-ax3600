module("luci.tools.proto",package.seeall)
function opt_macaddr(t,e,...)
local a=luci.cbi.Value
local t=t:taboption("advanced",a,"macaddr",...)
t.placeholder=e and e:mac()
t.datatype="macaddr"
function t.cfgvalue(o,t)
local e=e and e:get_wifinet()
if e then
return e:get("macaddr")
else
return a.cfgvalue(o,t)
end
end
function t.write(i,o,t)
local e=e and e:get_wifinet()
if e then
e:set("macaddr",t)
elseif t then
a.write(i,o,t)
else
a.remove(i,o)
end
end
function t.remove(e,t)
e:write(t,nil)
end
end
