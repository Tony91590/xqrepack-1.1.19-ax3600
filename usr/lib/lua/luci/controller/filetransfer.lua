module("luci.controller.filetransfer",package.seeall)
function index()
entry({"admin","system","filetransfer"},form("filetransfer"),_("FileTransfer"),89)
end
