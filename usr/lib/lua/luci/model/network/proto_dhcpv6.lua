local e=luci.model.network:register_protocol("dhcpv6")
function e.get_i18n(e)
return luci.i18n.translate("DHCPv6 client")
end
function e.is_installed(e)
return nixio.fs.access("/lib/netifd/proto/dhcpv6.sh")
end
function e.opkg_package(e)
return"odhcp6c"
end
