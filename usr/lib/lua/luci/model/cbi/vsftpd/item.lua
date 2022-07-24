local e=arg[1]
local t=require"luci.util"
m=Map("vsftpd",translate("FTP Server - Virtual User &lt;new&gt;"))
m.redirect=luci.dispatcher.build_url("admin/nas/vsftpd/users")
if m.uci:get("vsftpd",e)~="user"then
luci.http.redirect(m.redirect)
return
end
m.uci:foreach("vsftpd","user",
function(t)
if t['.name']==e and t.username then
m.title=translatef("FTP Server - Virtual User %q",t.username)
return false
end
end)
s=m:section(NamedSection,e,"settings",translate("User Settings"))
s.addremove=false
o=s:option(Value,"username",translate("Username"))
o.rmempty=false
function o.validate(t,e)
if e==""then
return nil,translate("Username cannot be empty")
end
return e
end
o=s:option(Value,"password",translate("Password"))
o.password=true
o=s:option(Value,"home",translate("Home directory"))
o.default="/home/ftp"
o=s:option(Value,"umask",translate("File mode umask"))
o.default="022"
o=s:option(Value,"maxrate",translate("Max transmit rate"),translate("0 means no limitation"))
o.default="0"
o=s:option(Flag,"writemkdir",translate("Enable write/mkdir"))
o.default=false
o=s:option(Flag,"upload",translate("Enable upload"))
o.default=false
o=s:option(Flag,"others",translate("Enable other rights"),translate("Include rename, deletion ..."))
o.default=false
return m
