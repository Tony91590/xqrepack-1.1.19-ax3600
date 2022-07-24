module("luci.http.protocol.date",package.seeall)
require("luci.sys.zoneinfo")
MONTHS={
"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug",
"Sep","Oct","Nov","Dec"
}
function tz_offset(a)
if type(a)=="string"then
local t,e=a:match("([%+%-])([0-9]+)")
if t=='+'then t=1 else t=-1 end
if e then e=tonumber(e)end
if t and e then
return t*60*(math.floor(e/100)*60+(e%100))
elseif luci.sys.zoneinfo.OFFSET[a:lower()]then
return luci.sys.zoneinfo.OFFSET[a:lower()]
end
end
return 0
end
function to_unix(e)
local t,e,s,n,i,a,o,h=e:match(
"([A-Z][a-z][a-z]), ([0-9]+) "..
"([A-Z][a-z][a-z]) ([0-9]+) "..
"([0-9]+):([0-9]+):([0-9]+) "..
"([A-Z0-9%+%-]+)"
)
if e and s and n and i and a and o then
local t=1
for e=1,12 do
if MONTHS[e]==s then
t=e
break
end
end
return tz_offset(h)+os.time({
year=n,
month=t,
day=e,
hour=i,
min=a,
sec=o
})
end
return 0
end
function to_http(e)
return os.date("%a, %d %b %Y %H:%M:%S GMT",e)
end
function compare(t,e)
if t:match("[^0-9]")then t=to_unix(t)end
if e:match("[^0-9]")then e=to_unix(e)end
if t==e then
return 0
elseif t<e then
return-1
else
return 1
end
end
