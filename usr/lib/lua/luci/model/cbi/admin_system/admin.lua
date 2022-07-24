local t=require"nixio.fs"
m=Map("system",translate("Router Password"),
translate("Changes the administrator password for accessing the device"))
s=m:section(TypedSection,"_dummy","")
s.addremove=false
s.anonymous=true
pw1=s:option(Value,"pw1",translate("Password"))
pw1.password=true
pw2=s:option(Value,"pw2",translate("Confirmation"))
pw2.password=true
function s.cfgsections()
return{"_pass"}
end
function m.parse(a)
local e=pw1:formvalue("_pass")
local t=pw2:formvalue("_pass")
if e and t and#e>0 and#t>0 then
if e==t then
if luci.sys.user.setpasswd(luci.dispatcher.context.authuser,e)==0 then
m.message=translate("Password successfully changed!")
else
m.message=translate("Unknown Error, password not changed!")
end
else
m.message=translate("Given password confirmation did not match, password not changed!")
end
end
Map.parse(a)
end
if t.access("/etc/config/dropbear")then
m2=Map("dropbear",translate("SSH Access"),
translate("Dropbear offers <abbr title=\"Secure Shell\">SSH</abbr> network shell access and an integrated <abbr title=\"Secure Copy\">SCP</abbr> server"))
s=m2:section(TypedSection,"dropbear",translate("Dropbear Instance"))
s.anonymous=true
s.addremove=true
ni=s:option(Value,"Interface",translate("Interface"),
translate("Listen only on the given interface or, if unspecified, on all"))
ni.template="cbi/network_netlist"
ni.nocreate=true
ni.unspecified=true
pt=s:option(Value,"Port",translate("Port"),
translate("Specifies the listening port of this <em>Dropbear</em> instance"))
pt.datatype="port"
pt.default=22
pa=s:option(Flag,"PasswordAuth",translate("Password authentication"),
translate("Allow <abbr title=\"Secure Shell\">SSH</abbr> password authentication"))
pa.enabled="on"
pa.disabled="off"
pa.default=pa.enabled
pa.rmempty=false
ra=s:option(Flag,"RootPasswordAuth",translate("Allow root logins with password"),
translate("Allow the <em>root</em> user to login with password"))
ra.enabled="on"
ra.disabled="off"
ra.default=ra.enabled
gp=s:option(Flag,"GatewayPorts",translate("Gateway ports"),
translate("Allow remote hosts to connect to local SSH forwarded ports"))
gp.enabled="on"
gp.disabled="off"
gp.default=gp.disabled
s2=m2:section(TypedSection,"_dummy",translate("SSH-Keys"),
translate("Here you can paste public SSH-Keys (one per line) for SSH public-key authentication."))
s2.addremove=false
s2.anonymous=true
s2.template="cbi/tblsection"
function s2.cfgsections()
return{"_keys"}
end
keys=s2:option(TextValue,"_data","")
keys.wrap="off"
keys.rows=3
keys.rmempty=false
function keys.cfgvalue()
return t.readfile("/etc/dropbear/authorized_keys")or""
end
function keys.write(a,a,e)
if e then
t.writefile("/etc/dropbear/authorized_keys",e:gsub("\r\n","\n"))
end
end
end
return m,m2
