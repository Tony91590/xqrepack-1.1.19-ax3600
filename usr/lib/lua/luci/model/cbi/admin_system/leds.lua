m=Map("system",translate("<abbr title=\"Light Emitting Diode\">LED</abbr> Configuration"),translate("Customizes the behaviour of the device <abbr title=\"Light Emitting Diode\">LED</abbr>s if possible."))
local t="/sys/class/leds/"
local e={}
local a=require"nixio.fs"
local o=require"nixio.util"
local i=require"luci.util"
if a.access(t)then
e=o.consume((a.dir(t)))
end
if#e==0 then
return m
end
s=m:section(TypedSection,"led","")
s.anonymous=true
s.addremove=true
function s.parse(e,...)
TypedSection.parse(e,...)
os.execute("/etc/init.d/led enable")
end
s:option(Value,"name",translate("Name"))
sysfs=s:option(ListValue,"sysfs",translate("<abbr title=\"Light Emitting Diode\">LED</abbr> Name"))
for t,e in ipairs(e)do
sysfs:value(e)
end
s:option(Flag,"default",translate("Default state")).rmempty=false
trigger=s:option(ListValue,"trigger",translate("Trigger"))
local e=a.readfile(t..e[1].."/trigger")
for e in e:gmatch("[%w-]+")do
trigger:value(e,translate(e:gsub("-","")))
end
trigger:value("rssi",translate("rssi"))
delayon=s:option(Value,"delayon",translate("On-State Delay"))
delayon:depends("trigger","timer")
delayoff=s:option(Value,"delayoff",translate("Off-State Delay"))
delayoff:depends("trigger","timer")
dev=s:option(ListValue,"_net_dev",translate("Device"))
dev.rmempty=true
dev:value("")
dev:depends("trigger","netdev")
function dev.cfgvalue(t,e)
return m.uci:get("system",e,"dev")
end
function dev.write(a,t,e)
m.uci:set("system",t,"dev",e)
end
function dev.remove(e,t)
local e=trigger:formvalue(t)
if e~="netdev"and e~="usbdev"then
m.uci:delete("system",t,"dev")
end
end
for t,e in pairs(luci.sys.net.devices())do
if e~="lo"then
dev:value(e)
end
end
mode=s:option(MultiValue,"mode",translate("Trigger Mode"))
mode.rmempty=true
mode:depends("trigger","netdev")
mode:value("link",translate("Link On"))
mode:value("tx",translate("Transmit"))
mode:value("rx",translate("Receive"))
usbdev=s:option(ListValue,"_usb_dev",translate("USB Device"))
usbdev:depends("trigger","usbdev")
usbdev.rmempty=true
usbdev:value("")
port_mask=s:option(Value,"port_mask",translate("Port Mask"))
port_mask:depends("trigger","switch0")
port_mask.rmempty=true
port_mask:value("0x01")
port_mask:value("0x02")
port_mask:value("0x04")
port_mask:value("0x08")
port_mask:value("0x10")
s:option(DynamicList,"port",translate("USB Port")):depends("trigger","usbport")
function usbdev.cfgvalue(t,e)
return m.uci:get("system",e,"dev")
end
function usbdev.write(a,e,t)
m.uci:set("system",e,"dev",t)
end
function usbdev.remove(e,t)
local e=trigger:formvalue(t)
if e~="netdev"and e~="usbdev"then
m.uci:delete("system",t,"dev")
end
end
usbport=s:option(MultiValue,"port",translate("USB Ports"))
usbport:depends("trigger","usbport")
usbport.rmempty=true
usbport.widget="checkbox"
usbport.cast="table"
usbport.size=1
function usbport.valuelist(t,e)
local t,a=nil,{}
for o in i.imatch(m.uci:get("system",e,"port"))do
local t,e=o:match("^usb(%d+)-port(%d+)$")
if not(t and e)then
t,e=o:match("^(%d+)-(%d+)$")
end
if t and e then
a[#a+1]="usb%u-port%u"%{tonumber(t),tonumber(e)}
end
end
return a
end
function usbport.validate(t,e)
return type(e)=="string"and{e}or e
end
for e in nixio.fs.glob("/sys/bus/usb/devices/[0-9]*/manufacturer")do
local e=e:match("%d+-%d+")
local a=nixio.fs.readfile("/sys/bus/usb/devices/"..e.."/manufacturer")or"?"
local t=nixio.fs.readfile("/sys/bus/usb/devices/"..e.."/product")or"?"
usbdev:value(e,"%s (%s - %s)"%{e,a,t})
end
for e in nixio.fs.glob("/sys/bus/usb/devices/*/usb[0-9]*-port[0-9]*")do
local e,t=e:match("usb(%d+)-port(%d+)")
if e and t then
usbport:value("usb%u-port%u"%{tonumber(e),tonumber(t)},
"Hub %u, Port %u"%{tonumber(e),tonumber(t)})
end
end
return m
