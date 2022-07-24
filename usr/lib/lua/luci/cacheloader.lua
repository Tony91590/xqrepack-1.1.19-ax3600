local e=require"luci.config"
local t=require"luci.ccache"
module"luci.cacheloader"
if e.ccache and e.ccache.enable=="1"then
t.cache_ondemand()
end