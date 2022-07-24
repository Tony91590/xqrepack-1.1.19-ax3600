local o={}
o.util=require"luci.util"
o.sys=require"luci.sys"
o.ip=require"luci.ip"
local s=pcall
local r=require"io"
local i,n,h=tonumber,ipairs,table
module("luci.sys.iptparser")
IptParser=o.util.class()
function IptParser.__init__(e,t)
e._family=(i(t)==6)and 6 or 4
e._rules={}
e._chains={}
e._tables={}
local t=e._tables
local a=e:_supported_tables(e._family)
if a.filter then t[#t+1]="filter"end
if a.nat then t[#t+1]="nat"end
if a.mangle then t[#t+1]="mangle"end
if a.raw then t[#t+1]="raw"end
if e._family==4 then
e._nulladdr="0.0.0.0/0"
e._command="iptables -t %s --line-numbers -nxvL"
else
e._nulladdr="::/0"
e._command="ip6tables -t %s --line-numbers -nxvL"
end
e:_parse_rules()
end
function IptParser._supported_tables(e,t)
local e={}
local a,t=s(r.lines,
(t==6)and"/proc/net/ip6_tables_names"
or"/proc/net/ip_tables_names")
if a and t then
local a
for t in t do
e[t]=true
end
end
return e
end
function IptParser.find(o,e)
local e=e or{}
local i={}
e.source=e.source and o:_parse_addr(e.source)
e.destination=e.destination and o:_parse_addr(e.destination)
for t,a in n(o._rules)do
local t=true
if not(not e.table or e.table:lower()==a.table)then
t=false
end
if not(t==true and(
not e.chain or e.chain==a.chain
))then
t=false
end
if not(t==true and(
not e.target or e.target==a.target
))then
t=false
end
if not(t==true and(
not e.protocol or a.protocol=="all"or
e.protocol:lower()==a.protocol
))then
t=false
end
if not(t==true and(
not e.source or a.source==o._nulladdr or
o:_parse_addr(a.source):contains(e.source)
))then
t=false
end
if not(t==true and(
not e.destination or a.destination==o._nulladdr or
o:_parse_addr(a.destination):contains(e.destination)
))then
t=false
end
if not(t==true and(
not e.inputif or a.inputif=="*"or
e.inputif==a.inputif
))then
t=false
end
if not(t==true and(
not e.outputif or a.outputif=="*"or
e.outputif==a.outputif
))then
t=false
end
if not(t==true and(
not e.flags or a.flags==e.flags
))then
t=false
end
if not(t==true and(
not e.options or
o:_match_options(a.options,e.options)
))then
t=false
end
if t==true then
i[#i+1]=a
end
end
return i
end
function IptParser.resync(e)
e._rules={}
e._chain=nil
e:_parse_rules()
end
function IptParser.tables(e)
return e._tables
end
function IptParser.chains(o,e)
local a={}
local t={}
for o,e in n(o:find({table=e}))do
if not a[e.chain]then
a[e.chain]=true
t[#t+1]=e.chain
end
end
return t
end
function IptParser.chain(t,e,a)
return t._chains[e:lower()]and t._chains[e:lower()][a]
end
function IptParser.is_custom_target(e,t)
for a,e in n(e._rules)do
if e.chain==t then
return true
end
end
return false
end
function IptParser._parse_addr(t,e)
if t._family==4 then
return o.ip.IPv4(e)
else
return o.ip.IPv6(e)
end
end
function IptParser._parse_rules(a)
for e,s in n(a._tables)do
a._chains[s]={}
for e,n in n(o.util.execl(a._command%s))do
if n:find("^Chain ")==1 then
local t
local e,h,o,r=n:match(
"^Chain ([^%s]*) %(policy (%w+) "..
"(%d+) packets, (%d+) bytes%)"
)
if not e then
e,t=n:match(
"^Chain ([^%s]*) %((%d+) references%)"
)
end
a._chain=e
a._chains[s][e]={
policy=h,
packets=i(o or 0),
bytes=i(r or 0),
references=i(t or 0),
rules={}
}
else
if n:find("%d")==1 then
local t=o.util.split(n,"%s+",nil,true)
local e={}
if n:match("^%d+%s+%d+%s+%d+%s%s")then
h.insert(t,4,nil)
end
if a._family==6 then
h.insert(t,6,"--")
end
e["table"]=s
e["chain"]=a._chain
e["index"]=i(t[1])
e["packets"]=i(t[2])
e["bytes"]=i(t[3])
e["target"]=t[4]
e["protocol"]=t[5]
e["flags"]=t[6]
e["inputif"]=t[7]
e["outputif"]=t[8]
e["source"]=t[9]
e["destination"]=t[10]
e["options"]={}
for o=11,#t do
if#t[o]>0 then
e["options"][o-10]=t[o]
end
end
a._rules[#a._rules+1]=e
a._chains[s][a._chain].rules[
#a._chains[s][a._chain].rules+1
]=e
end
end
end
end
a._chain=nil
end
function IptParser._match_options(e,t,a)
local e={}
for a,t in n(t)do e[t]=true end
for a,t in n(a)do
if not e[t]then
return false
end
end
return true
end
