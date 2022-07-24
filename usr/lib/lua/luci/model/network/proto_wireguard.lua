local t=luci.model.network
local a=luci.model.network.interface
local e=t:register_protocol("wireguard")
function e.get_i18n(e)
return luci.i18n.translate("WireGuard VPN")
end
function e.ifname(e)
return e.sid
end
function e.get_interface(e)
return a(e:ifname(),e)
end
function e.opkg_package(e)
return"wireguard-tools"
end
function e.is_installed(e)
return nixio.fs.access("/lib/netifd/proto/wireguard.sh")
end
function e.is_floating(e)
return true
end
function e.is_virtual(e)
return true
end
function e.get_interfaces(e)
return nil
end
function e.contains_interface(e,a)
return(t:ifnameof(a)==e:ifname())
end
