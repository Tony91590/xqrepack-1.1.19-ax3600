module("luci.controller.admin.filebrowser",package.seeall)
function index()
entry({"admin","filebrowser"},template("cbi/filebrowser")).leaf=true
end
