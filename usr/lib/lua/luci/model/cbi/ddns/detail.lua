local z=require"nixio"
local v=require"nixio.fs"
local m=require"luci.sys"
local d=require"luci.util"
local x=require"luci.http"
local k=require"luci.dispatcher"
local l=require"luci.tools.webadmin"
local r=require"luci.cbi.datatypes"
local y=require"luci.controller.ddns"
local t=require"luci.tools.ddns"
local e=arg[1]
local u="<font color='red'>"
local c="</font>"
local h="<strong>"
local s="</strong>"
local f=translate("IPv6 not supported").." - "..
translate("please select 'IPv4' address version")
local j=h..
u..
translate("IPv6 not supported")..
c..
"<br />"..translate("please select 'IPv4' address version")..
s
local b=h..
u..
translate("IPv6 not supported")..
c..
"<br />"..translate("please select 'IPv4' address version in").." "..
[[<a href="]]..
k.build_url("admin","services","ddns","detail",e)..
"?tab.dns."..e.."=basic"..
[[">]]..
translate("Basic Settings")..
[[</a>]]..
s
function err_tab_basic(e)
return translate("Basic Settings").." - "..e.title..": "
end
function err_tab_adv(e)
return translate("Advanced Settings").." - "..e.title..": "
end
function err_tab_timer(e)
return translate("Timer Settings").." - "..e.title..": "
end
local w={}
local o=io.open("/etc/ddns/services","r")
if o then
local a,e,t
repeat
a=o:read("*l")
e=a and a:match('^%s*".*')
e=e and e:gsub('"','')
t=e and d.split(e,"(%s+)",nil,true)
if t then w[t[1]]=t[2]end
until not a
o:close()
end
local g={}
local o=io.open("/etc/ddns/services_ipv6","r")
if o then
local a,e,t
repeat
a=o:read("*l")
e=a and a:match('^%s*".*')
e=e and e:gsub('"','')
t=e and d.split(e,"(%s+)",nil,true)
if t then g[t[1]]=t[2]end
until not a
o:close()
end
local function q()
local a
local i=usev6:formvalue(e)
local o=(i=="1")
and src6:formvalue(e)
or src4:formvalue(e)
local t=y.luci_helper..[[ -]]
if(i=="1")then t=t..[[6]]end
if o=="network"then
a=(i=="1")
and ipn6:formvalue(e)
or ipn4:formvalue(e)
t=t..[[n ]]..a
elseif o=="web"then
a=(i=="1")
and iurl6:formvalue(e)
or iurl4:formvalue(e)
t=t..[[u ]]..a
a=(pxy)and pxy:formvalue(e)or""
if(a and#a>0)then
t=t..[[ -p ]]..a
end
elseif o=="interface"then
t=t..[[i ]]..ipi:formvalue(e)
elseif o=="script"then
t=t..[[s ]]..ips:formvalue(e)
end
t=t..[[ -- get_local_ip]]
return(m.call(t)==0)
end
local function n(o,e)
local t
local a
local i
if o=="domain"then t,a='%[DOMAIN%]','%$domain'
elseif o=="username"then t,a='%[USERNAME%]','%$username'
elseif o=="password"then t,a='%[PASSWORD%]','%$password'
elseif o=="param_enc"then t,a='%[PARAMENC%]','%$param_enc'
elseif o=="param_opt"then t,a='%[PARAMOPT%]','%$param_opt'
else
error("undefined option")
return-1
end
local o=false
if e:find('http')then
o=(e:find(t))
else
if not e:find("/")then
e="/usr/lib/ddns/"..e
end
if not v.access(e)then return-1 end
local e=io.input(e)
if not e then return-1 end
for i in e:lines()do
repeat
if i:find('^#')then break end
o=(i:find(t)or i:find(a))
until true
if o then break end
end
e:close()
end
return(o and 1 or 0)
end
local function p(i,a,d)
local o=usev6:formvalue(e)or"0"
local h=svc4:formvalue(e)or"-"
local s=svc6:formvalue(e)or"-"
local t,r
if(o=="0"and h=="-")or
(o=="1"and s=="-")then
t=uurl:formvalue(e)or""
if(#t==0)then
t=ush:formvalue(e)or""
end
elseif(o=="0")then
t=w[h]or""
else
t=g[s]or""
end
if(#t==0)then return""end
r=n(i.option,t)
if r<1 then return""end
if not a or(#a==0)then
if d then return nil end
return nil,err_tab_basic(i)..translate("missing / required")
end
return a
end
local o=Map("ddns")
o.title=y.app_title_back()
o.description=y.app_description()
o.redirect=k.build_url("admin","services","ddns")
o.on_after_commit=function(a)
if a.changed then
local e=t.get_pid(e)
if e>0 then
local e=z.kill(e,1)
end
end
end
if o:formvalue("cbid.ddns.%s._switch"%e)then
local t
local a=o:formvalue("cbid.ddns.%s.use_ipv6"%e)or"0"
if a=="1"then
t=o:formvalue("cbid.ddns.%s.ipv6_service_name"%e)or""
else
t=o:formvalue("cbid.ddns.%s.ipv4_service_name"%e)or""
end
if a~=(o:get(e,"use_ipv6")or"0")then
o:set(e,"use_ipv6",a)
end
if t~="-"then
o:set(e,"service_name",t)
else
o:del(e,"service_name")
end
o.uci:save(o.config)
x.redirect(k.build_url("admin","services","ddns","detail",e))
return
end
local k=o.uci:get(o.config,"global","ddns_logdir")or"/var/log/ddns"
local a=o:section(NamedSection,e,"service",
translate("Details for")..([[: <strong>%s</strong>]]%e),
translate("Configure here the details for selected Dynamic DNS service."))
a.instance=e
a:tab("basic",translate("Basic Settings"),nil)
a:tab("advanced",translate("Advanced Settings"),nil)
a:tab("timer",translate("Timer Settings"),nil)
a:tab("logview",translate("Log File Viewer"),nil)
en=a:taboption("basic",Flag,"enabled",
translate("Enabled"),
translate("If this service section is disabled it could not be started.".."<br />"..
"Neither from LuCI interface nor from console"))
en.orientation="horizontal"
luh=a:taboption("basic",Value,"lookup_host",
translate("Lookup Hostname"),
translate("Hostname/FQDN to validate, if IP update happen or necessary"))
luh.rmempty=false
luh.placeholder="myhost.example.com"
function luh.validate(t,e)
if not e
or not(#e>0)
or not r.hostname(e)then
return nil,err_tab_basic(t)..translate("invalid FQDN / required - Sample")..": 'myhost.example.com'"
else
return d.trim(e)
end
end
function luh.parse(e,a,o)
t.value_parse(e,a,o)
end
local i=t.env_info("has_ipv6")
usev6=a:taboption("basic",ListValue,"use_ipv6",
translate("IP address version"),
translate("Defines which IP address 'IPv4/IPv6' is send to the DDNS provider"))
usev6.widget="radio"
usev6.default="0"
usev6:value("0",translate("IPv4-Address"))
function usev6.cfgvalue(t,e)
local e=AbstractValue.cfgvalue(t,e)or"0"
if i or(e=="1"and not i)then
t:value("1",translate("IPv6-Address"))
end
if e=="1"and not i then
t.description=j
end
return e
end
function usev6.validate(t,e)
if(e=="1"and i)or e=="0"then
return e
end
return nil,err_tab_basic(t)..f
end
function usev6.parse(e,o,a)
t.value_parse(e,o,a)
end
svc4=a:taboption("basic",ListValue,"ipv4_service_name",
translate("DDNS Service provider").." [IPv4]")
svc4.default="-"
svc4:depends("use_ipv6","0")
function svc4.cfgvalue(e,a)
local e=t.read_value(e,a,"service_name")
if e and(#e>0)then
for t,a in d.kspairs(w)do
if e==t then return e end
end
end
return"-"
end
function svc4.validate(a,t)
if usev6:formvalue(e)~="1"then
return t
else
return""
end
end
function svc4.write(e,t,a)
if usev6:formvalue(t)~="1"then
e.map:del(t,e.option)
if a~="-"then
e.map:del(t,"update_url")
e.map:del(t,"update_script")
return e.map:set(t,"service_name",a)
else
return e.map:del(t,"service_name")
end
end
end
function svc4.parse(o,a,e)
t.value_parse(o,a,e)
end
svc6=a:taboption("basic",ListValue,"ipv6_service_name",
translate("DDNS Service provider").." [IPv6]")
svc6.default="-"
svc6:depends("use_ipv6","1")
if not i then
svc6.description=j
end
function svc6.cfgvalue(e,a)
local e=t.read_value(e,a,"service_name")
if e and(#e>0)then
for t,a in d.kspairs(w)do
if e==t then return e end
end
end
return"-"
end
function svc6.validate(a,t)
if usev6:formvalue(e)=="1"then
if i then return t end
return nil,err_tab_basic(a)..f
else
return""
end
end
function svc6.write(e,t,a)
if usev6:formvalue(t)=="1"then
e.map:del(t,e.option)
if a~="-"then
e.map:del(t,"update_url")
e.map:del(t,"update_script")
return e.map:set(t,"service_name",a)
else
return e.map:del(t,"service_name")
end
end
end
function svc6.parse(o,a,e)
t.value_parse(o,a,e)
end
svs=a:taboption("basic",Button,"_switch")
svs.title=translate("Really change DDNS provider?")
svs.inputtitle=translate("Change provider")
svs.inputstyle="apply"
uurl=a:taboption("basic",Value,"update_url",
translate("Custom update-URL"),
translate("Update URL to be used for updating your DDNS Provider.".."<br />"..
"Follow instructions you will find on their WEB page."))
function uurl.validate(a,o)
local i=ush:formvalue(e)
local n=usev6:formvalue(e)
if(n~="1"and svc4:formvalue(e)~="-")or
(n=="1"and svc6:formvalue(e)~="-")then
return""
elseif not o or(#o==0)then
if not i or(#i==0)then
return nil,err_tab_basic(a)..translate("missing / required")
else
return""
end
elseif(#i>0)then
return nil,err_tab_basic(a)..translate("either url or script could be set")
end
local e=t.parse_url(o)
if not e.scheme=="http"then
return nil,err_tab_basic(a)..translate("must start with 'http://'")
elseif not e.query then
return nil,err_tab_basic(a).."<QUERY> "..translate("missing / required")
elseif not e.host then
return nil,err_tab_basic(a).."<HOST> "..translate("missing / required")
elseif m.call([[nslookup ]]..e.host..[[ >/dev/null 2>&1]])~=0 then
return nil,err_tab_basic(a)..translate("can not resolve host: ")..e.host
end
return o
end
function uurl.parse(e,a,o)
t.value_parse(e,a,o)
end
ush=a:taboption("basic",Value,"update_script",
translate("Custom update-script"),
translate("Custom update script to be used for updating your DDNS Provider."))
function ush.validate(o,t)
local a=uurl:formvalue(e)
local i=usev6:formvalue(e)
if(i~="1"and svc4:formvalue(e)~="-")or
(i=="1"and svc6:formvalue(e)~="-")then
return""
elseif not t or(#t==0)then
if not a or(#a==0)then
return nil,err_tab_basic(o)..translate("missing / required")
else
return""
end
elseif(#a>0)then
return nil,err_tab_basic(o)..translate("either url or script could be set")
elseif not v.access(t)then
return nil,err_tab_basic(o)..translate("File not found")
end
return t
end
function ush.parse(o,e,a)
t.value_parse(o,e,a)
end
dom=a:taboption("basic",Value,"domain",
translate("Domain"),
translate("Replaces [DOMAIN] in Update-URL"))
dom.placeholder="myhost.example.com"
function dom.validate(t,e)
return p(t,e)
end
function dom.parse(e,a,o)
t.value_parse(e,a,o)
end
user=a:taboption("basic",Value,"username",
translate("Username"),
translate("Replaces [USERNAME] in Update-URL (URL-encoded)"))
function user.validate(e,t)
return p(e,t)
end
function user.parse(e,o,a)
t.value_parse(e,o,a)
end
pw=a:taboption("basic",Value,"password",
translate("Password"),
translate("Replaces [PASSWORD] in Update-URL (URL-encoded)"))
pw.password=true
function pw.validate(e,t)
return p(e,t)
end
function pw.parse(o,e,a)
t.value_parse(o,e,a)
end
pe=a:taboption("basic",Value,"param_enc",
translate("Optional Encoded Parameter"),
translate("Optional: Replaces [PARAMENC] in Update-URL (URL-encoded)"))
function pe.validate(t,e)
return p(t,e,true)
end
function pe.parse(e,a,o)
t.value_parse(e,a,o)
end
po=a:taboption("basic",Value,"param_opt",
translate("Optional Parameter"),
translate("Optional: Replaces [PARAMOPT] in Update-URL (NOT URL-encoded)"))
function po.validate(t,e)
return p(t,e,true)
end
function po.parse(e,a,o)
t.value_parse(e,a,o)
end
local p=svc4:cfgvalue(e)
if p~="-"then
svs:depends("ipv4_service_name","-")
ush:depends("ipv4_service_name","?")
uurl:depends("ipv4_service_name","?")
else
uurl:depends("ipv4_service_name","-")
ush:depends("ipv4_service_name","-")
dom:depends("ipv4_service_name","-")
user:depends("ipv4_service_name","-")
pw:depends("ipv4_service_name","-")
pe:depends("ipv4_service_name","-")
po:depends("ipv4_service_name","-")
end
for e,t in d.kspairs(w)do
svc4:value(e)
if p~=e then
svs:depends("ipv4_service_name",e)
else
dom:depends("ipv4_service_name",((n(dom.option,t)==1)and e or"?"))
user:depends("ipv4_service_name",((n(user.option,t)==1)and e or"?"))
pw:depends("ipv4_service_name",((n(pw.option,t)==1)and e or"?"))
pe:depends("ipv4_service_name",((n(pe.option,t)==1)and e or"?"))
po:depends("ipv4_service_name",((n(po.option,t)==1)and e or"?"))
end
end
svc4:value("-",translate("-- custom --"))
local w=svc6:cfgvalue(e)
if w~="-"then
svs:depends("ipv6_service_name","-")
uurl:depends("ipv6_service_name","?")
ush:depends("ipv6_service_name","?")
else
uurl:depends("ipv6_service_name","-")
ush:depends("ipv6_service_name","-")
dom:depends("ipv6_service_name","-")
user:depends("ipv6_service_name","-")
pw:depends("ipv6_service_name","-")
pe:depends("ipv6_service_name","-")
po:depends("ipv6_service_name","-")
end
for e,t in d.kspairs(g)do
svc6:value(e)
if w~=e then
svs:depends("ipv6_service_name",e)
else
dom:depends("ipv6_service_name",((n(dom.option,t)==1)and e or"?"))
user:depends("ipv6_service_name",((n(user.option,t)==1)and e or"?"))
pw:depends("ipv6_service_name",((n(pw.option,t)==1)and e or"?"))
pe:depends("ipv6_service_name",((n(pe.option,t)==1)and e or"?"))
po:depends("ipv6_service_name",((n(po.option,t)==1)and e or"?"))
end
end
svc6:value("-",translate("-- custom --"))
local n=t.env_info("has_ssl")
if n or((o:get(e,"use_https")or"0")=="1")then
https=a:taboption("basic",Flag,"use_https",
translate("Use HTTP Secure"))
https.orientation="horizontal"
function https.cfgvalue(e,t)
local t=AbstractValue.cfgvalue(e,t)
if not n and t=="1"then
e.description=h..u..
translate("HTTPS not supported")..c.."<br />"..
translate("please disable").." !"..s
else
e.description=translate("Enable secure communication with DDNS provider")
end
return t
end
function https.validate(t,e)
if(e=="1"and n)or e=="0"then return e end
return nil,err_tab_basic(t)..translate("HTTPS not supported").." !"
end
function https.write(e,t,a)
if a=="1"then
return e.map:set(t,e.option,a)
else
e.map:del(t,"cacert")
return e.map:del(t,e.option)
end
end
end
if n then
cert=a:taboption("basic",Value,"cacert",
translate("Path to CA-Certificate"),
translate("directory or path/file").."<br />"..
translate("or")..h.." IGNORE "..s..
translate("to run HTTPS without verification of server certificates (insecure)"))
cert:depends("use_https","1")
cert.placeholder="/etc/ssl/certs"
cert.forcewrite=true
function cert.validate(a,t)
if https:formvalue(e)~="1"then
return""
end
if t then
if r.directory(t)
or r.file(t)
or(t=="IGNORE")
or(#t==0)then
return t
end
end
return nil,err_tab_basic(a)..
translate("file or directory not found or not 'IGNORE'").." !"
end
function cert.parse(o,a,e)
t.value_parse(o,a,e)
end
end
src4=a:taboption("advanced",ListValue,"ipv4_source",
translate("IP address source").." [IPv4]",
translate("Defines the source to read systems IPv4-Address from, that will be send to the DDNS provider"))
src4:depends("use_ipv6","0")
src4.default="network"
src4:value("network",translate("Network"))
src4:value("web",translate("URL"))
src4:value("interface",translate("Interface"))
src4:value("script",translate("Script"))
function src4.cfgvalue(a,e)
return t.read_value(a,e,"ip_source")
end
function src4.validate(a,t)
if usev6:formvalue(e)=="1"then
return""
elseif not q()then
return nil,err_tab_adv(a)..
translate("can not detect local IP. Please select a different Source combination")
else
return t
end
end
function src4.write(t,e,a)
if usev6:formvalue(e)=="1"then
return true
elseif a=="network"then
t.map:del(e,"ip_url")
t.map:del(e,"ip_interface")
t.map:del(e,"ip_script")
elseif a=="web"then
t.map:del(e,"ip_network")
t.map:del(e,"ip_interface")
t.map:del(e,"ip_script")
elseif a=="interface"then
t.map:del(e,"ip_network")
t.map:del(e,"ip_url")
t.map:del(e,"ip_script")
elseif a=="script"then
t.map:del(e,"ip_network")
t.map:del(e,"ip_url")
t.map:del(e,"ip_interface")
end
t.map:del(e,t.option)
return t.map:set(e,"ip_source",a)
end
function src4.parse(e,o,a)
t.value_parse(e,o,a)
end
src6=a:taboption("advanced",ListValue,"ipv6_source",
translate("IP address source").." [IPv6]",
translate("Defines the source to read systems IPv6-Address from, that will be send to the DDNS provider"))
src6:depends("use_ipv6",1)
src6.default="network"
src6:value("network",translate("Network"))
src6:value("web",translate("URL"))
src6:value("interface",translate("Interface"))
src6:value("script",translate("Script"))
if not i then
src6.description=b
end
function src6.cfgvalue(e,a)
return t.read_value(e,a,"ip_source")
end
function src6.validate(t,a)
if usev6:formvalue(e)~="1"then
return""
elseif not i then
return nil,err_tab_adv(t)..f
elseif not q()then
return nil,err_tab_adv(t)..
translate("can not detect local IP. Please select a different Source combination")
else
return a
end
end
function src6.write(e,t,a)
if usev6:formvalue(t)~="1"then
return true
elseif a=="network"then
e.map:del(t,"ip_url")
e.map:del(t,"ip_interface")
e.map:del(t,"ip_script")
elseif a=="web"then
e.map:del(t,"ip_network")
e.map:del(t,"ip_interface")
e.map:del(t,"ip_script")
elseif a=="interface"then
e.map:del(t,"ip_network")
e.map:del(t,"ip_url")
e.map:del(t,"ip_script")
elseif a=="script"then
e.map:del(t,"ip_network")
e.map:del(t,"ip_url")
e.map:del(t,"ip_interface")
end
e.map:del(t,e.option)
return e.map:set(t,"ip_source",a)
end
function src6.parse(a,o,e)
t.value_parse(a,o,e)
end
ipn4=a:taboption("advanced",ListValue,"ipv4_network",
translate("Network").." [IPv4]",
translate("Defines the network to read systems IPv4-Address from"))
ipn4:depends("ipv4_source","network")
ipn4.default="wan"
l.cbi_add_networks(ipn4)
function ipn4.cfgvalue(a,e)
return t.read_value(a,e,"ip_network")
end
function ipn4.validate(a,t)
if usev6:formvalue(e)=="1"
or src4:formvalue(e)~="network"then
return""
else
return t
end
end
function ipn4.write(t,e,a)
if usev6:formvalue(e)=="1"
or src4:formvalue(e)~="network"then
return true
else
t.map:set(e,"interface",a)
t.map:del(e,t.option)
return t.map:set(e,"ip_network",a)
end
end
function ipn4.parse(e,a,o)
t.value_parse(e,a,o)
end
ipn6=a:taboption("advanced",ListValue,"ipv6_network",
translate("Network").." [IPv6]")
ipn6:depends("ipv6_source","network")
ipn6.default="wan6"
l.cbi_add_networks(ipn6)
if i then
ipn6.description=translate("Defines the network to read systems IPv6-Address from")
else
ipn6.description=b
end
function ipn6.cfgvalue(e,a)
return t.read_value(e,a,"ip_network")
end
function ipn6.validate(a,t)
if usev6:formvalue(e)~="1"
or src6:formvalue(e)~="network"then
return""
elseif i then
return t
else
return nil,err_tab_adv(a)..f
end
end
function ipn6.write(t,e,a)
if usev6:formvalue(e)~="1"
or src6:formvalue(e)~="network"then
return true
else
t.map:set(e,"interface",a)
t.map:del(e,t.option)
return t.map:set(e,"ip_network",a)
end
end
function ipn6.parse(e,a,o)
t.value_parse(e,a,o)
end
iurl4=a:taboption("advanced",Value,"ipv4_url",
translate("URL to detect").." [IPv4]",
translate("Defines the Web page to read systems IPv4-Address from"))
iurl4:depends("ipv4_source","web")
iurl4.default="http://checkip.dyndns.com"
function iurl4.cfgvalue(e,a)
return t.read_value(e,a,"ip_url")
end
function iurl4.validate(o,a)
if usev6:formvalue(e)=="1"
or src4:formvalue(e)~="web"then
return""
elseif not a or#a==0 then
return nil,err_tab_adv(o)..translate("missing / required")
end
local e=t.parse_url(a)
if not(e.scheme=="http"or e.scheme=="https")then
return nil,err_tab_adv(o)..translate("must start with 'http://'")
elseif not e.host then
return nil,err_tab_adv(o).."<HOST> "..translate("missing / required")
elseif m.call([[nslookup ]]..e.host..[[>/dev/null 2>&1]])~=0 then
return nil,err_tab_adv(o)..translate("can not resolve host: ")..e.host
else
return a
end
end
function iurl4.write(t,e,a)
if usev6:formvalue(e)=="1"
or src4:formvalue(e)~="web"then
return true
else
t.map:del(e,t.option)
return t.map:set(e,"ip_url",a)
end
end
function iurl4.parse(a,e,o)
t.value_parse(a,e,o)
end
iurl6=a:taboption("advanced",Value,"ipv6_url",
translate("URL to detect").." [IPv6]")
iurl6:depends("ipv6_source","web")
iurl6.default="http://checkipv6.dyndns.com"
if i then
iurl6.description=translate("Defines the Web page to read systems IPv6-Address from")
else
iurl6.description=b
end
function iurl6.cfgvalue(a,e)
return t.read_value(a,e,"ip_url")
end
function iurl6.validate(a,o)
if usev6:formvalue(e)~="1"
or src6:formvalue(e)~="web"then
return""
elseif not i then
return nil,err_tab_adv(a)..f
elseif not o or#o==0 then
return nil,err_tab_adv(a)..translate("missing / required")
end
local e=t.parse_url(o)
if not(e.scheme=="http"or e.scheme=="https")then
return nil,err_tab_adv(a)..translate("must start with 'http://'")
elseif not e.host then
return nil,err_tab_adv(a).."<HOST> "..translate("missing / required")
elseif m.call([[nslookup ]]..e.host..[[>/dev/null 2>&1]])~=0 then
return nil,err_tab_adv(a)..translate("can not resolve host: ")..e.host
else
return o
end
end
function iurl6.write(t,e,a)
if usev6:formvalue(e)~="1"
or src6:formvalue(e)~="web"then
return true
else
t.map:del(e,t.option)
return t.map:set(e,"ip_url",a)
end
end
function iurl6.parse(e,o,a)
t.value_parse(e,o,a)
end
ipi=a:taboption("advanced",ListValue,"ip_interface",
translate("Interface"),
translate("Defines the interface to read systems IP-Address from"))
ipi:depends("ipv4_source","interface")
ipi:depends("ipv6_source","interface")
for t,e in pairs(m.net.devices())do
net=l.iface_get_network(e)
if net and net~="loopback"then
ipi:value(e)
end
end
function ipi.validate(t,a)
local t=usev6:formvalue(e)
if(t~="1"and src4:formvalue(e)~="interface")
or(t=="1"and src6:formvalue(e)~="interface")then
return""
else
return a
end
end
function ipi.write(t,e,o)
local a=usev6:formvalue(e)
if(a~="1"and src4:formvalue(e)~="interface")
or(a=="1"and src6:formvalue(e)~="interface")then
return true
else
local a=l.iface_get_network(o)
t.map:set(e,"interface",a)
return t.map:set(e,t.option,o)
end
end
function ipi.parse(o,e,a)
t.value_parse(o,e,a)
end
ips=a:taboption("advanced",Value,"ip_script",
translate("Script"),
translate("User defined script to read systems IP-Address"))
ips:depends("ipv4_source","script")
ips:depends("ipv6_source","script")
ips.placeholder="/path/to/script.sh"
function ips.validate(i,t)
local o=usev6:formvalue(e)
local a
if t then a=d.split(t," ")end
if(o~="1"and src4:formvalue(e)~="script")
or(o=="1"and src6:formvalue(e)~="script")then
return""
elseif not t or not(#t>0)or not v.access(a[1],"x")then
return nil,err_tab_adv(i)..
translate("not found or not executable - Sample: '/path/to/script.sh'")
else
return t
end
end
function ips.write(t,e,o)
local a=usev6:formvalue(e)
if(a~="1"and src4:formvalue(e)~="script")
or(a=="1"and src6:formvalue(e)~="script")then
return true
else
return t.map:set(e,t.option,o)
end
end
function ips.parse(e,a,o)
t.value_parse(e,a,o)
end
eif4=a:taboption("advanced",ListValue,"ipv4_interface",
translate("Event Network").." [IPv4]",
translate("Network on which the ddns-updater scripts will be started"))
eif4:depends("ipv4_source","web")
eif4:depends("ipv4_source","script")
eif4.default="wan"
l.cbi_add_networks(eif4)
function eif4.cfgvalue(a,e)
return t.read_value(a,e,"interface")
end
function eif4.validate(t,a)
local t=src4:formvalue(e)or""
if usev6:formvalue(e)=="1"
or t=="network"
or t=="interface"then
return""
else
return a
end
end
function eif4.write(t,e,o)
local a=src4:formvalue(e)or""
if usev6:formvalue(e)=="1"
or a=="network"
or a=="interface"then
return true
else
t.map:del(e,t.option)
return t.map:set(e,"interface",o)
end
end
function eif4.parse(a,e,o)
t.value_parse(a,e,o)
end
eif6=a:taboption("advanced",ListValue,"ipv6_interface",
translate("Event Network").." [IPv6]")
eif6:depends("ipv6_source","web")
eif6:depends("ipv6_source","script")
eif6.default="wan6"
l.cbi_add_networks(eif6)
if not i then
eif6.description=b
else
eif6.description=translate("Network on which the ddns-updater scripts will be started")
end
function eif6.cfgvalue(a,e)
return t.read_value(a,e,"interface")
end
function eif6.validate(o,a)
local t=src6:formvalue(e)or""
if usev6:formvalue(e)~="1"
or t=="network"
or t=="interface"then
return""
elseif not i then
return nil,err_tab_adv(o)..f
else
return a
end
end
function eif6.write(t,e,o)
local a=src6:formvalue(e)or""
if usev6:formvalue(e)~="1"
or a=="network"
or a=="interface"then
return true
else
t.map:del(e,t.option)
return t.map:set(e,"interface",o)
end
end
function eif6.parse(a,e,o)
t.value_parse(a,e,o)
end
local i=t.env_info("has_bindnet")
if i or((o:get(e,"bind_network")or"")~="")then
bnet=a:taboption("advanced",ListValue,"bind_network",
translate("Bind Network"))
bnet:depends("ipv4_source","web")
bnet:depends("ipv6_source","web")
bnet.default=""
bnet:value("",translate("-- default --"))
l.cbi_add_networks(bnet)
function bnet.cfgvalue(e,t)
local t=AbstractValue.cfgvalue(e,t)
if not i and t~=""then
e.description=h..u..
translate("Binding to a specific network not supported")..c.."<br />"..
translate("please set to 'default'").." !"..s
else
e.description=translate("OPTIONAL: Network to use for communication")..
"<br />"..translate("Casual users should not change this setting")
end
return t
end
function bnet.validate(t,e)
if((e~="")and i)or(e=="")then return e end
return nil,err_tab_adv(t)..translate("Binding to a specific network not supported").." !"
end
function bnet.parse(e,a,o)
t.value_parse(e,a,o)
end
end
local i=t.env_info("has_forceip")
if i or((o:get(e,"force_ipversion")or"0")~="0")then
fipv=a:taboption("advanced",Flag,"force_ipversion",
translate("Force IP Version"))
fipv.orientation="horizontal"
function fipv.cfgvalue(e,t)
local t=AbstractValue.cfgvalue(e,t)
if not i and t~="0"then
e.description=h..u..
translate("Force IP Version not supported")..c.."<br />"..
translate("please disable").." !"..s
else
e.description=translate("OPTIONAL: Force the usage of pure IPv4/IPv6 only communication.")
end
return t
end
function fipv.validate(t,e)
if(e=="1"and i)or e=="0"then return e end
return nil,err_tab_adv(t)..translate("Force IP Version not supported")
end
end
local i=t.env_info("has_dnsserver")
if i or((o:get(e,"dns_server")or"")~="")then
dns=a:taboption("advanced",Value,"dns_server",
translate("DNS-Server"),
translate("OPTIONAL: Use non-default DNS-Server to detect 'Registered IP'.").."<br />"..
translate("Format: IP or FQDN"))
dns.placeholder="mydns.lan"
function dns.validate(t,a)
if not a or(#a==0)then
return""
elseif not i then
return nil,err_tab_adv(t)..translate("Specifying a DNS-Server is not supported")
elseif not r.host(a)then
return nil,err_tab_adv(t)..translate("use hostname, FQDN, IPv4- or IPv6-Address")
else
local i=usev6:formvalue(e)or"0"
local o=fipv:formvalue(e)or"0"
local e=y.luci_helper..[[ -]]
if(i==1)then e=e..[[6]]end
if(o==1)then e=e..[[f]]end
e=e..[[d ]]..a..[[ -- verify_dns]]
local e=m.call(e)
if e==0 then return a
elseif e==2 then return nil,err_tab_adv(t)..translate("nslookup can not resolve host")
elseif e==3 then return nil,err_tab_adv(t)..translate("nc (netcat) can not connect")
elseif e==4 then return nil,err_tab_adv(t)..translate("Forced IP Version don't matched")
else return nil,err_tab_adv(t)..translate("unspecific error")
end
end
end
function dns.parse(o,a,e)
t.value_parse(o,a,e)
end
end
local i=t.env_info("has_bindhost")
if i or((o:get(e,"force_dnstcp")or"0")~="0")then
tcp=a:taboption("advanced",Flag,"force_dnstcp",
translate("Force TCP on DNS"))
tcp.orientation="horizontal"
function tcp.cfgvalue(e,t)
local t=AbstractValue.cfgvalue(e,t)
if not i and t~="0"then
e.description=h..u..
translate("DNS requests via TCP not supported")..c.."<br />"..
translate("please disable").." !"..s
else
e.description=translate("OPTIONAL: Force the use of TCP instead of default UDP on DNS requests.")
end
return t
end
function tcp.validate(t,e)
if(e=="1"and i)or e=="0"then
return e
end
return nil,err_tab_adv(t)..translate("DNS requests via TCP not supported")
end
end
local i=t.env_info("has_proxy")
if i or((o:get(e,"proxy")or"")~="")then
pxy=a:taboption("advanced",Value,"proxy",
translate("PROXY-Server"))
pxy.placeholder="user:password@myproxy.lan:8080"
function pxy.cfgvalue(e,t)
local t=AbstractValue.cfgvalue(e,t)
if not i and t~=""then
e.description=h..u..
translate("PROXY-Server not supported")..c.."<br />"..
translate("please remove entry").."!"..s
else
e.description=translate("OPTIONAL: Proxy-Server for detection and updates.").."<br />"..
translate("Format")..": "..h.."[user:password@]proxyhost:port"..s.."<br />"..
translate("IPv6 address must be given in square brackets")..": "..
h.." [2001:db8::1]:8080"..s
end
return t
end
function pxy.validate(t,a)
if not a or(#a==0)then
return""
elseif i then
local o=usev6:formvalue(e)or"0"
local i=fipv:formvalue(e)or"0"
local e=y.luci_helper..[[ -]]
if(o==1)then e=e..[[6]]end
if(i==1)then e=e..[[f]]end
e=e..[[p ]]..a..[[ -- verify_proxy]]
local e=m.call(e)
if e==0 then return a
elseif e==2 then return nil,err_tab_adv(t)..translate("nslookup can not resolve host")
elseif e==3 then return nil,err_tab_adv(t)..translate("nc (netcat) can not connect")
elseif e==4 then return nil,err_tab_adv(t)..translate("Forced IP Version don't matched")
elseif e==5 then return nil,err_tab_adv(t)..translate("proxy port missing")
else return nil,err_tab_adv(t)..translate("unspecific error")
end
else
return nil,err_tab_adv(t)..translate("PROXY-Server not supported")
end
end
function pxy.parse(a,e,o)
t.value_parse(a,e,o)
end
end
slog=a:taboption("advanced",ListValue,"use_syslog",
translate("Log to syslog"),
translate("Writes log messages to syslog. Critical Errors will always be written to syslog."))
slog.default="2"
slog:value("0",translate("No logging"))
slog:value("1",translate("Info"))
slog:value("2",translate("Notice"))
slog:value("3",translate("Warning"))
slog:value("4",translate("Error"))
function slog.parse(o,e,a)
t.value_parse(o,e,a)
end
logf=a:taboption("advanced",Flag,"use_logfile",
translate("Log to file"),
translate("Writes detailed messages to log file. File will be truncated automatically.").."<br />"..
translate("File")..[[: "]]..k..[[/]]..e..[[.log"]])
logf.orientation="horizontal"
logf.default="1"
ci=a:taboption("timer",Value,"check_interval",
translate("Check Interval"))
ci.template="ddns/detail_value"
ci.default="10"
function ci.validate(o,a)
if not r.uinteger(a)
or tonumber(a)<1 then
return nil,err_tab_timer(o)..translate("minimum value 5 minutes == 300 seconds")
end
local e=t.calc_seconds(a,cu:formvalue(e))
if e>=300 then
return a
else
return nil,err_tab_timer(o)..translate("minimum value 5 minutes == 300 seconds")
end
end
function ci.write(e,a,o)
local t=t.calc_seconds(o,cu:formvalue(a))
if t~=600 then
return e.map:set(a,e.option,o)
else
e.map:del(a,"check_unit")
return e.map:del(a,e.option)
end
end
function ci.parse(a,e,o)
t.value_parse(a,e,o)
end
cu=a:taboption("timer",ListValue,"check_unit","not displayed, but needed otherwise error",
translate("Interval to check for changed IP".."<br />"..
"Values below 5 minutes == 300 seconds are not supported"))
cu.template="ddns/detail_lvalue"
cu.default="minutes"
cu:value("seconds",translate("seconds"))
cu:value("minutes",translate("minutes"))
cu:value("hours",translate("hours"))
function cu.write(e,a,o)
local t=t.calc_seconds(ci:formvalue(a),o)
if t~=600 then
return e.map:set(a,e.option,o)
else
return true
end
end
function cu.parse(o,a,e)
t.value_parse(o,a,e)
end
fi=a:taboption("timer",Value,"force_interval",
translate("Force Interval"))
fi.template="ddns/detail_value"
fi.default="72"
function fi.validate(n,a)
if not r.uinteger(a)
or tonumber(a)<0 then
return nil,err_tab_timer(n)..translate("minimum value '0'")
end
local i=t.calc_seconds(a,fu:formvalue(e))
if i==0 then
return a
end
local o=ci:formvalue(e)
if not r.uinteger(o)then
return""
end
local e=t.calc_seconds(o,cu:formvalue(e))
if i>=e then
return a
end
return nil,err_tab_timer(n)..translate("must be greater or equal 'Check Interval'")
end
function fi.write(e,a,o)
local t=t.calc_seconds(o,fu:formvalue(a))
if t~=259200 then
return e.map:set(a,e.option,o)
else
e.map:del(a,"force_unit")
return e.map:del(a,e.option)
end
end
function fi.parse(a,o,e)
t.value_parse(a,o,e)
end
fu=a:taboption("timer",ListValue,"force_unit","not displayed, but needed otherwise error",
translate("Interval to force updates send to DDNS Provider".."<br />"..
"Setting this parameter to 0 will force the script to only run once".."<br />"..
"Values lower 'Check Interval' except '0' are not supported"))
fu.template="ddns/detail_lvalue"
fu.default="hours"
fu:value("minutes",translate("minutes"))
fu:value("hours",translate("hours"))
fu:value("days",translate("days"))
function fu.write(i,a,o)
local e=t.calc_seconds(fi:formvalue(a),o)
if e~=259200 and e~=0 then
return i.map:set(a,i.option,o)
else
return true
end
end
function fu.parse(a,e,o)
t.value_parse(a,e,o)
end
rc=a:taboption("timer",Value,"retry_count")
rc.title=translate("Error Retry Counter")
rc.description=translate("On Error the script will stop execution after given number of retrys")
.."<br />"
..translate("The default setting of '0' will retry infinite.")
rc.default="0"
function rc.validate(t,e)
if not r.uinteger(e)then
return nil,err_tab_timer(t)..translate("minimum value '0'")
else
return e
end
end
function rc.parse(e,a,o)
t.value_parse(e,a,o)
end
ri=a:taboption("timer",Value,"retry_interval",
translate("Error Retry Interval"))
ri.template="ddns/detail_value"
ri.default="60"
function ri.validate(t,e)
if not r.uinteger(e)
or tonumber(e)<1 then
return nil,err_tab_timer(t)..translate("minimum value '1'")
else
return e
end
end
function ri.write(e,a,o)
local t=t.calc_seconds(o,ru:formvalue(a))
if t~=60 then
return e.map:set(a,e.option,o)
else
e.map:del(a,"retry_unit")
return e.map:del(a,e.option)
end
end
function ri.parse(o,e,a)
t.value_parse(o,e,a)
end
ru=a:taboption("timer",ListValue,"retry_unit","not displayed, but needed otherwise error",
translate("On Error the script will retry the failed action after given time"))
ru.template="ddns/detail_lvalue"
ru.default="seconds"
ru:value("seconds",translate("seconds"))
ru:value("minutes",translate("minutes"))
function ru.write(o,a,e)
local t=t.calc_seconds(ri:formvalue(a),e)
if t~=60 then
return o.map:set(a,o.option,e)
else
return true
end
end
function ru.parse(e,a,o)
t.value_parse(e,a,o)
end
lv=a:taboption("logview",DummyValue,"_logview")
lv.template="ddns/detail_logview"
lv.inputtitle=translate("Read / Reread log file")
lv.rows=50
function lv.cfgvalue(t,e)
local e=k.."/"..e..".log"
if v.access(e)then
return e.."\n"..translate("Please press [Read] button")
end
return e.."\n"..translate("File not found or empty")
end
return o
