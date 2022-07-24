m=Map("vsftpd",translate("FTP Server - Virtual User Settings"))
sv=m:section(NamedSection,"vuser","vuser",translate("Settings"))
o=sv:option(Flag,"enabled",translate("Enabled"))
o.default=false
o=sv:option(Value,"username",translate("Username"),translate("An actual local user to handle virtual users"))
o.default="ftp"
s=m:section(TypedSection,"user",translate("User lists"))
s.template="cbi/tblsection"
s.extedit=luci.dispatcher.build_url("admin/nas/vsftpd/item/%s")
s.addremove=true
s.anonymous=true
function s.create(...)
local e=TypedSection.create(...)
luci.http.redirect(s.extedit%e)
end
function s.remove(t,e)
return TypedSection.remove(t,e)
end
o=s:option(DummyValue,"username",translate("Username"))
function o.cfgvalue(...)
local e=Value.cfgvalue(...)or("<%s>"%translate("Unknown"))
return e
end
o.rmempty=false
o=s:option(DummyValue,"home",translate("Home directory"))
function o.cfgvalue(...)
local e=Value.cfgvalue(...)or("/home/ftp")
return e
end
o.rmempty=false
return m
