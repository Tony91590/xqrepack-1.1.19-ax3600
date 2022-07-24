local e=luci.model.network:register_protocol("hnet")
function e.get_i18n(e)
return luci.i18n.translate("Automatic Homenet (HNCP)")
end
function e.is_installed(e)
return nixio.fs.access("/lib/netifd/proto/hnet.sh")
end
function e.opkg_package(e)
return"hnet-full"
end
