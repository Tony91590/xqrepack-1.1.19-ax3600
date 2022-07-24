local t=require"luci.dispatcher"
local o=require"luci.sys"
local a=require"luci.controller.ddns"
local e=require"luci.tools.ddns"
font_red=[[<font color="red">]]
font_off=[[</font>]]
bold_on=[[<strong>]]
bold_off=[[</strong>]]
m=Map("ddns")
m.title=a.app_title_back()
m.description=a.app_description()
m.redirect=t.build_url("admin","services","ddns")
s=m:section(SimpleSection,
translate("Hints"),
translate("Below a list of configuration tips for your system to run Dynamic DNS updates without limitations"))
if not a.service_ok()then
local e=s:option(DummyValue,"_update_needed")
e.titleref=t.build_url("admin","system","packages")
e.rawhtml=true
e.title=font_red..bold_on..
translate("Software update required")..bold_off..font_off
e.value=translate("The currently installed 'ddns-scripts' package did not support all available settings.")..
"<br />"..
translate("Please update to the current version!")
end
if not o.init.enabled("ddns")then
local e=s:option(DummyValue,"_not_enabled")
e.titleref=t.build_url("admin","system","startup")
e.rawhtml=true
e.title=bold_on..
translate("DDNS Autostart disabled")..bold_off
e.value=translate("Currently DDNS updates are not started at boot or on interface events.".."<br />"..
"This is the default if you run DDNS scripts by yourself (i.e. via cron with force_interval set to '0')")
end
if not e.env_info("has_ipv6")then
local e=s:option(DummyValue,"_no_ipv6")
e.titleref='http://www.openwrt.org" target="_blank'
e.rawhtml=true
e.title=bold_on..
translate("IPv6 not supported")..bold_off
e.value=translate("IPv6 is currently not (fully) supported by this system".."<br />"..
"Please follow the instructions on OpenWrt's homepage to enable IPv6 support".."<br />"..
"or update your system to the latest OpenWrt Release")
end
if not e.env_info("has_ssl")then
local e=s:option(DummyValue,"_no_https")
e.titleref=t.build_url("admin","system","packages")
e.rawhtml=true
e.title=bold_on..
translate("HTTPS not supported")..bold_off
e.value=translate("Neither GNU Wget with SSL nor cURL installed to support secure updates via HTTPS protocol.")..
"<br />- "..
translate("You should install 'wget' or 'curl' or 'uclient-fetch' with 'libustream-*ssl' package.")..
"<br />- "..
translate("In some versions cURL/libcurl in OpenWrt is compiled without proxy support.")
end
if not e.env_info("has_bindnet")then
local e=s:option(DummyValue,"_no_bind_network")
e.titleref=t.build_url("admin","system","packages")
e.rawhtml=true
e.title=bold_on..
translate("Binding to a specific network not supported")..bold_off
e.value=translate("Neither GNU Wget with SSL nor cURL installed to select a network to use for communication.")..
"<br />- "..
translate("You should install 'wget' or 'curl' package.")..
"<br />- "..
translate("GNU Wget will use the IP of given network, cURL will use the physical interface.")..
"<br />- "..
translate("In some versions cURL/libcurl in OpenWrt is compiled without proxy support.")
end
if not e.env_info("has_proxy")then
local e=s:option(DummyValue,"_no_proxy")
e.titleref=t.build_url("admin","system","packages")
e.rawhtml=true
e.title=bold_on..
translate("cURL without Proxy Support")..bold_off
e.value=translate("cURL is installed, but libcurl was compiled without proxy support.")..
"<br />- "..
translate("You should install 'wget' or 'uclient-fetch' package or replace libcurl.")..
"<br />- "..
translate("In some versions cURL/libcurl in OpenWrt is compiled without proxy support.")
end
if not e.env_info("has_forceip")then
local a=s:option(DummyValue,"_no_force_ip")
a.titleref=t.build_url("admin","system","packages")
a.rawhtml=true
a.title=bold_on..
translate("Force IP Version not supported")..bold_off
local t=translate("BusyBox's nslookup and Wget do not support to specify "..
"the IP version to use for communication with DDNS Provider!")
if not(e.env_info("has_wgetssl")or e.env_info("has_curl")or e.env_info("has_fetch"))then
t=t.."<br />- "..
translate("You should install 'wget' or 'curl' or 'uclient-fetch' package.")
end
if not e.env_info("has_bindhost")then
t=t.."<br />- "..
translate("You should install 'bind-host' or 'knot-host' or 'drill' package for DNS requests.")
end
a.value=t
end
if not e.env_info("has_bindhost")then
local e=s:option(DummyValue,"_no_dnstcp")
e.titleref=t.build_url("admin","system","packages")
e.rawhtml=true
e.title=bold_on..
translate("DNS requests via TCP not supported")..bold_off
e.value=translate("BusyBox's nslookup and hostip do not support to specify to use TCP "..
"instead of default UDP when requesting DNS server!")..
"<br />- "..
translate("You should install 'bind-host' or 'knot-host' or 'drill' package for DNS requests.")
end
if not e.env_info("has_dnsserver")then
local e=s:option(DummyValue,"_no_dnsserver")
e.titleref=t.build_url("admin","system","packages")
e.rawhtml=true
e.title=bold_on..
translate("Using specific DNS Server not supported")..bold_off
e.value=translate("BusyBox's nslookup in the current compiled version "..
"does not handle given DNS Servers correctly!")..
"<br />- "..
translate("You should install 'bind-host' or 'knot-host' or 'drill' or 'hostip' package, "..
"if you need to specify a DNS server to detect your registered IP.")
end
if e.env_info("has_ssl")and not e.env_info("has_cacerts")then
local e=s:option(DummyValue,"_no_certs")
e.titleref=t.build_url("admin","system","packages")
e.rawhtml=true
e.title=bold_on..
translate("No certificates found")..bold_off
e.value=translate("If using secure communication you should verify server certificates!")..
"<br />- "..
translate("Install 'ca-certificates' package or needed certificates "..
"by hand into /etc/ssl/certs default directory")
end
return m
