module("luci.controller.sqm",package.seeall)
function index()
if not nixio.fs.access("/etc/config/sqm")then
return
end
local e
e=entry({"admin","network","sqm"},cbi("sqm"),_("SQM QoS"))
e.dependent=true
e.acl_depends={"luci-app-sqm"}
end
