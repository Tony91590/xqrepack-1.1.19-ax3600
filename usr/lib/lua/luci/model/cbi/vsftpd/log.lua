m=Map("vsftpd",translate("FTP Server - Log Settings"))
sl=m:section(NamedSection,"log","log",translate("Log Settings"))
o=sl:option(Flag,"syslog",translate("Enable syslog"))
o.default=false
o=sl:option(Flag,"xreflog",translate("Enable file log"))
o.default=true
o=sl:option(Value,"file",translate("Log file"))
o.default="/var/log/vsftpd.log"
return m
