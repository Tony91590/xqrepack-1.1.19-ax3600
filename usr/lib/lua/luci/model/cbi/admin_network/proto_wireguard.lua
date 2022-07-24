local u,t,e=...
local l=e:get_interface():name()
local n,a
local o,i,s
local e,h,r,c,d
n=t:taboption(
"general",
Value,
"private_key",
translate("Private Key"),
translate("Required. Base64-encoded private key for this interface.")
)
n.password=true
n.datatype="and(base64,rangelength(44,44))"
n.optional=false
a=t:taboption(
"general",
Value,
"listen_port",
translate("Listen Port"),
translate("Optional. UDP port used for outgoing and incoming packets.")
)
a.datatype="port"
a.placeholder=translate("random")
a.optional=true
addresses=t:taboption(
"general",
DynamicList,
"addresses",
translate("IP Addresses"),
translate("Recommended. IP addresses of the WireGuard interface.")
)
addresses.datatype="ipaddr"
addresses.optional=true
o=t:taboption(
"advanced",
Value,
"metric",
translate("Metric"),
translate("Optional")
)
o.datatype="uinteger"
o.placeholder="0"
o.optional=true
i=t:taboption(
"advanced",
Value,
"mtu",
translate("MTU"),
translate("Optional. Maximum Transmission Unit of tunnel interface.")
)
i.datatype="range(1280,1420)"
i.placeholder="1420"
i.optional=true
fwmark=t:taboption(
"advanced",
Value,
"fwmark",
translate("Firewall Mark"),
translate("Optional. 32-bit mark for outgoing encrypted packets. "..
"Enter value in hex, starting with <code>0x</code>.")
)
fwmark.datatype="hex(4)"
fwmark.optional=true
e=u:section(
TypedSection,
"wireguard_"..l,
translate("Peers"),
translate("Further information about WireGuard interfaces and peers "..
"at <a href=\"http://wireguard.io\">wireguard.io</a>.")
)
e.template="cbi/tsection"
e.anonymous=true
e.addremove=true
h=e:option(
Value,
"public_key",
translate("Public Key"),
translate("Required. Base64-encoded public key of peer.")
)
h.datatype="and(base64,rangelength(44,44))"
h.optional=false
s=e:option(
Value,
"preshared_key",
translate("Preshared Key"),
translate("Optional. Base64-encoded preshared key. "..
"Adds in an additional layer of symmetric-key "..
"cryptography for post-quantum resistance.")
)
s.password=true
s.datatype="and(base64,rangelength(44,44))"
s.optional=true
r=e:option(
DynamicList,
"allowed_ips",
translate("Allowed IPs"),
translate("Required. IP addresses and prefixes that this peer is allowed "..
"to use inside the tunnel. Usually the peer's tunnel IP "..
"addresses and the networks the peer routes through the tunnel.")
)
r.datatype="ipaddr"
r.optional=false
route_allowed_ips=e:option(
Flag,
"route_allowed_ips",
translate("Route Allowed IPs"),
translate("Optional. Create routes for Allowed IPs for this peer.")
)
endpoint_host=e:option(
Value,
"endpoint_host",
translate("Endpoint Host"),
translate("Optional. Host of peer. Names are resolved "..
"prior to bringing up the interface."))
endpoint_host.placeholder="vpn.example.com"
endpoint_host.datatype="host"
endpoint_port=e:option(
Value,
"endpoint_port",
translate("Endpoint Port"),
translate("Optional. Port of peer."))
endpoint_port.placeholder="51820"
endpoint_port.datatype="port"
d=e:option(
Value,
"persistent_keepalive",
translate("Persistent Keep Alive"),
translate("Optional. Seconds between keep alive messages. "..
"Default is 0 (disabled). Recommended value if "..
"this device is behind a NAT is 25."))
d.datatype="range(0,65535)"
d.placeholder="0"
