local e=require"luci.util"
module("luci.config",
function(a)
if pcall(require,"luci.model.uci")then
local t=e.threadlocal()
setmetatable(a,{
__index=function(a,e)
if not t[e]then
t[e]=luci.model.uci.cursor():get_all("luci",e)
end
return t[e]
end
})
end
end)
