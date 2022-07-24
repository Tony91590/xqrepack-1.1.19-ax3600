module("luci.controller.wireguard",package.seeall)
function index()
entry({"admin","status","wireguard"},template("wireguard"),_("WireGuard Status"),92)
end
