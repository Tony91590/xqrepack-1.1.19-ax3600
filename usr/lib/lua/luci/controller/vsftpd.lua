require("luci.sys")
module("luci.controller.vsftpd",package.seeall)
function index()
if not nixio.fs.access("/etc/config/vsftpd")then
return
end
entry({"admin","nas"},firstchild(),"NAS",44).dependent=false
entry({"admin","nas","vsftpd"},alias("admin","nas","vsftpd","general"),_("FTP Server"))
entry({"admin","nas","vsftpd","general"},cbi("vsftpd/general"),_("General Settings"),10).leaf=true
entry({"admin","nas","vsftpd","users"},cbi("vsftpd/users"),_("Virtual Users"),20).leaf=true
entry({"admin","nas","vsftpd","anonymous"},cbi("vsftpd/anonymous"),_("Anonymous User"),30).leaf=true
entry({"admin","nas","vsftpd","log"},cbi("vsftpd/log"),_("Log Settings"),40).leaf=true
entry({"admin","nas","vsftpd","item"},cbi("vsftpd/item"),nil).leaf=true
end
