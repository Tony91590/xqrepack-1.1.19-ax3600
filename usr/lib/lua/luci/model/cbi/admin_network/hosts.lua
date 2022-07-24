local e=require"luci.ip"
m=Map("dhcp",translate("Hostnames"))
s=m:section(TypedSection,"domain",translate("Host entries"))
s.addremove=true
s.anonymous=true
s.template="cbi/tblsection"
hn=s:option(Value,"name",translate("Hostname"))
hn.datatype="hostname"
hn.rmempty=true
ip=s:option(Value,"ip",translate("IP address"))
ip.datatype="ipaddr"
ip.rmempty=true
e.neighbors({},function(e)
if e.mac and e.dest and not e.dest:is6linklocal()then
ip:value(e.dest:string(),"%s (%s)"%{e.dest:string(),e.mac})
end
end)
return m
