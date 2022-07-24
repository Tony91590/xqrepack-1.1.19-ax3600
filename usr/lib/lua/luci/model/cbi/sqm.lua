local t=require"luci.tools.webadmin"
local a=require"nixio.fs"
local h=require"luci.model.network".init()
local t=require"luci.sys"
local r=t.net:devices()
local o="/usr/lib/sqm"
local i="/var/run/sqm/available_qdiscs"
m=Map("sqm",translate("Smart Queue Management"),
translate("With <abbr title=\"Smart Queue Management\">SQM</abbr> you "..
"can enable traffic shaping, better mixing (Fair Queueing),"..
" active queue length management (AQM) "..
" and prioritisation on one "..
"network interface."))
s=m:section(TypedSection,"queue",translate("Queues"))
s:tab("tab_basic",translate("Basic Settings"))
s:tab("tab_qdisc",translate("Queue Discipline"))
s:tab("tab_linklayer",translate("Link Layer Adaptation"))
s.addremove=true
s.anonymous=true
e=s:taboption("tab_basic",Flag,"enabled",translate("Enable this SQM instance."))
e.rmempty=false
function e.write(a,t,e)
if e=="1"then
luci.sys.init.enable("sqm")
m.message=translate("The SQM GUI has just enabled the sqm initscript on your behalf. Remember to disable the sqm initscript manually under System Startup menu in case this change was not wished for.")
end
return Flag.write(a,t,e)
end
n=s:taboption("tab_basic",ListValue,"interface",translate("Interface name"))
for e,t in ipairs(r)do
if not(t=="lo"or t:match("^ifb.*"))then
local e=h:get_interface(t)
e=e and e:get_networks()or{}
for t,a in pairs(e)do
e[t]=e[t].sid
end
e=table.concat(e,",")
n:value(t,((#e>0)and"%s (%s)"%{t,e}or t))
end
end
n.rmempty=false
dl=s:taboption("tab_basic",Value,"download",translate("Download speed (kbit/s) (ingress) set to 0 to selectively disable ingress shaping:"))
dl.datatype="and(uinteger,min(0))"
dl.rmempty=false
ul=s:taboption("tab_basic",Value,"upload",translate("Upload speed (kbit/s) (egress) set to 0 to selectively disable egress shaping:"))
ul.datatype="and(uinteger,min(0))"
ul.rmempty=false
dbl=s:taboption("tab_basic",Flag,"debug_logging",translate("Create log file for this SQM instance under /var/run/sqm/${Interface_name}.[start|stop]-sqm.log."))
dbl.rmempty=false
verb=s:taboption("tab_basic",ListValue,"verbosity",translate("Verbosity of SQM's output into the system log."))
verb:value("0","silent")
verb:value("1","error")
verb:value("2","warning")
verb:value("5","info ("..translate("default")..")")
verb:value("8","debug")
verb:value("10","trace")
verb.default="5"
verb.rmempty=true
local e=""
c=s:taboption("tab_qdisc",ListValue,"qdisc",translate("Queuing disciplines useable on this system. After installing a new qdisc, you need to restart the router to see updates!"))
c:value("fq_codel","fq_codel ("..translate("default")..")")
if a.stat(i)then
for e in a.dir(i)do
c:value(e)
end
end
c.default="fq_codel"
c.rmempty=false
local e=""
sc=s:taboption("tab_qdisc",ListValue,"script",translate("Queue setup script"))
for t in a.dir(o)do
if string.find(t,".qos$")and not a.stat(o.."/"..t..".hidden")then
sc:value(t)
e=e.."<p><b>"..t..":</b><br />"
fh=io.open(o.."/"..t..".help","r")
if fh then
e=e..fh:read("*a").."</p>"
else
e=e.."No help text</p>"
end
end
end
sc.default="simple.qos"
sc.rmempty=false
sc.description=e
ad=s:taboption("tab_qdisc",Flag,"qdisc_advanced",translate("Show and Use Advanced Configuration. Advanced options will only be used as long as this box is checked."))
ad.default=false
ad.rmempty=true
squash_dscp=s:taboption("tab_qdisc",ListValue,"squash_dscp",translate("Squash DSCP on inbound packets (ingress):"))
squash_dscp:value("1","SQUASH")
squash_dscp:value("0","DO NOT SQUASH")
squash_dscp.default="1"
squash_dscp.rmempty=true
squash_dscp:depends("qdisc_advanced","1")
squash_ingress=s:taboption("tab_qdisc",ListValue,"squash_ingress",translate("Ignore DSCP on ingress:"))
squash_ingress:value("1","Ignore")
squash_ingress:value("0","Allow")
squash_ingress.default="1"
squash_ingress.rmempty=true
squash_ingress:depends("qdisc_advanced","1")
iecn=s:taboption("tab_qdisc",ListValue,"ingress_ecn",translate("Explicit congestion notification (ECN) status on inbound packets (ingress):"))
iecn:value("ECN","ECN ("..translate("default")..")")
iecn:value("NOECN")
iecn.default="ECN"
iecn.rmempty=true
iecn:depends("qdisc_advanced","1")
eecn=s:taboption("tab_qdisc",ListValue,"egress_ecn",translate("Explicit congestion notification (ECN) status on outbound packets (egress)."))
eecn:value("NOECN","NOECN ("..translate("default")..")")
eecn:value("ECN")
eecn.default="NOECN"
eecn.rmempty=true
eecn:depends("qdisc_advanced","1")
ad2=s:taboption("tab_qdisc",Flag,"qdisc_really_really_advanced",translate("Show and Use Dangerous Configuration. Dangerous options will only be used as long as this box is checked."))
ad2.default=false
ad2.rmempty=true
ad2:depends("qdisc_advanced","1")
ilim=s:taboption("tab_qdisc",Value,"ilimit",translate("Hard limit on ingress queues; leave empty for default."))
ilim.isnumber=true
ilim.datatype="and(uinteger,min(0))"
ilim.rmempty=true
ilim:depends("qdisc_really_really_advanced","1")
elim=s:taboption("tab_qdisc",Value,"elimit",translate("Hard limit on egress queues; leave empty for default."))
elim.datatype="and(uinteger,min(0))"
elim.rmempty=true
elim:depends("qdisc_really_really_advanced","1")
itarg=s:taboption("tab_qdisc",Value,"itarget",translate("Latency target for ingress, e.g 5ms [units: s, ms, or  us]; leave empty for automatic selection, put in the word default for the qdisc's default."))
itarg.datatype="string"
itarg.rmempty=true
itarg:depends("qdisc_really_really_advanced","1")
etarg=s:taboption("tab_qdisc",Value,"etarget",translate("Latency target for egress, e.g. 5ms [units: s, ms, or  us]; leave empty for automatic selection, put in the word default for the qdisc's default."))
etarg.datatype="string"
etarg.rmempty=true
etarg:depends("qdisc_really_really_advanced","1")
iqdisc_opts=s:taboption("tab_qdisc",Value,"iqdisc_opts",translate("Advanced option string to pass to the ingress queueing disciplines; no error checking, use very carefully."))
iqdisc_opts.rmempty=true
iqdisc_opts:depends("qdisc_really_really_advanced","1")
eqdisc_opts=s:taboption("tab_qdisc",Value,"eqdisc_opts",translate("Advanced option string to pass to the egress queueing disciplines; no error checking, use very carefully."))
eqdisc_opts.rmempty=true
eqdisc_opts:depends("qdisc_really_really_advanced","1")
ll=s:taboption("tab_linklayer",ListValue,"linklayer",translate("Which link layer to account for:"))
ll:value("none","none ("..translate("default")..")")
ll:value("ethernet","Ethernet with overhead: select for e.g. VDSL2.")
ll:value("atm","ATM: select for e.g. ADSL1, ADSL2, ADSL2+.")
ll.default="none"
po=s:taboption("tab_linklayer",Value,"overhead",translate("Per Packet Overhead (byte):"))
po.datatype="and(integer,min(-1500))"
po.default=0
po.isnumber=true
po.rmempty=true
po:depends("linklayer","ethernet")
po:depends("linklayer","atm")
adll=s:taboption("tab_linklayer",Flag,"linklayer_advanced",translate("Show Advanced Linklayer Options, (only needed if MTU > 1500). Advanced options will only be used as long as this box is checked."))
adll.rmempty=true
adll:depends("linklayer","ethernet")
adll:depends("linklayer","atm")
smtu=s:taboption("tab_linklayer",Value,"tcMTU",translate("Maximal Size for size and rate calculations, tcMTU (byte); needs to be >= interface MTU + overhead:"))
smtu.datatype="and(uinteger,min(0))"
smtu.default=2047
smtu.isnumber=true
smtu.rmempty=true
smtu:depends("linklayer_advanced","1")
stsize=s:taboption("tab_linklayer",Value,"tcTSIZE",translate("Number of entries in size/rate tables, TSIZE; for ATM choose TSIZE = (tcMTU + 1) / 16:"))
stsize.datatype="and(uinteger,min(0))"
stsize.default=128
stsize.isnumber=true
stsize.rmempty=true
stsize:depends("linklayer_advanced","1")
smpu=s:taboption("tab_linklayer",Value,"tcMPU",translate("Minimal packet size, MPU (byte); needs to be > 0 for ethernet size tables:"))
smpu.datatype="and(uinteger,min(0))"
smpu.default=0
smpu.isnumber=true
smpu.rmempty=true
smpu:depends("linklayer_advanced","1")
lla=s:taboption("tab_linklayer",ListValue,"linklayer_adaptation_mechanism",translate("Which linklayer adaptation mechanism to use; for testing only"))
lla:value("default","default ("..translate("default")..")")
lla:value("cake")
lla:value("htb_private")
lla:value("tc_stab")
lla.default="default"
lla.rmempty=true
lla:depends("linklayer_advanced","1")
return m
