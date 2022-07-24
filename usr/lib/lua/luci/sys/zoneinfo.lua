local e,o,a,i=setmetatable,require,rawget,rawset
module"luci.sys.zoneinfo"
e(_M,{
__index=function(t,e)
if e=="TZ"and not a(t,e)then
local o=o"luci.sys.zoneinfo.tzdata"
i(t,e,a(o,e))
elseif e=="OFFSET"and not a(t,e)then
local o=o"luci.sys.zoneinfo.tzoffset"
i(t,e,a(o,e))
end
return a(t,e)
end
})
