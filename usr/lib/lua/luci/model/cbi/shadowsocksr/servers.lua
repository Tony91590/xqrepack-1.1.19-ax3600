require"luci.http"
require"luci.dispatcher"
require"luci.model.uci"
local o,t,e
local a=luci.model.uci.cursor()
local i=0
a:foreach("shadowsocksr","servers",function(e)
i=i+1
end)
o=Map("shadowsocksr",translate("Servers subscription and manage"))
t=o:section(TypedSection,"server_subscribe")
t.anonymous=true
e=t:option(Flag,"auto_update",translate("Auto Update"))
e.rmempty=false
e.description=translate("Auto Update Server subscription, GFW list and CHN route")
e=t:option(ListValue,"auto_update_time",translate("Update time (every day)"))
for t=0,23 do
e:value(t,t..":00")
end
e.default=2
e.rmempty=false
e=t:option(DynamicList,"subscribe_url",translate("Subscribe URL"))
e.rmempty=true
e=t:option(Value,"filter_words",translate("Subscribe Filter Words"))
e.rmempty=true
e.description=translate("Filter Words splited by /")
e=t:option(Value,"save_words",translate("Subscribe Save Words"))
e.rmempty=true
e.description=translate("Save Words splited by /")
e=t:option(Button,"update_Sub",translate("Update Subscribe List"))
e.inputstyle="reload"
e.description=translate("Update subscribe url list first")
e.write=function()
a:commit("shadowsocksr")
luci.http.redirect(luci.dispatcher.build_url("admin","services","shadowsocksr","servers"))
end
e=t:option(Flag,"switch",translate("Subscribe Default Auto-Switch"))
e.rmempty=false
e.description=translate("Subscribe new add server default Auto-Switch on")
e.default="1"
e=t:option(Flag,"proxy",translate("Through proxy update"))
e.rmempty=false
e.description=translate("Through proxy update list, Not Recommended ")
e=t:option(Button,"subscribe",translate("Update All Subscribe Severs"))
e.rawhtml=true
e.template="shadowsocksr/subscribe"
e=t:option(Button,"delete",translate("Delete All Subscribe Severs"))
e.inputstyle="reset"
e.description=string.format(translate("Server Count")..": %d",i)
e.write=function()
a:delete_all("shadowsocksr","servers",function(e)
if e.hashkey or e.isSubscribe then
return true
else
return false
end
end)
a:save("shadowsocksr")
a:commit("shadowsocksr")
luci.http.redirect(luci.dispatcher.build_url("admin","services","shadowsocksr","delete"))
return
end
t=o:section(TypedSection,"servers")
t.anonymous=true
t.addremove=true
t.template="cbi/tblsection"
t.sortable=true
t.extedit=luci.dispatcher.build_url("admin","services","shadowsocksr","servers","%s")
function t.create(...)
local a=TypedSection.create(...)
if a then
luci.http.redirect(t.extedit%a)
return
end
end
e=t:option(DummyValue,"type",translate("Type"))
function e.cfgvalue(a,t)
return o:get(t,"v2ray_protocol")or Value.cfgvalue(a,t)or translate("None")
end
e=t:option(DummyValue,"alias",translate("Alias"))
function e.cfgvalue(...)
return Value.cfgvalue(...)or translate("None")
end
e=t:option(DummyValue,"server_port",translate("Server Port"))
function e.cfgvalue(...)
return Value.cfgvalue(...)or"N/A"
end
e=t:option(DummyValue,"server_port",translate("Socket Connected"))
e.template="shadowsocksr/socket"
e.width="10%"
e.render=function(a,o,i)
a.transport=t:cfgvalue(o).transport
if a.transport=='ws'then
a.ws_path=t:cfgvalue(o).ws_path
a.tls=t:cfgvalue(o).tls
end
DummyValue.render(a,o,i)
end
e=t:option(DummyValue,"server",translate("Ping Latency"))
e.template="shadowsocksr/ping"
e.width="10%"
local i=a:get_first('shadowsocksr','global','global_server')
node=t:option(Button,"apply_node",translate("Apply"))
node.inputstyle="apply"
node.render=function(e,t,a)
if t==i then
e.title=translate("Reapply")
else
e.title=translate("Apply")
end
Button.render(e,t,a)
end
node.write=function(o,t)
a:set("shadowsocksr",'@global[0]','global_server',t)
a:save("shadowsocksr")
a:commit("shadowsocksr")
luci.http.redirect(luci.dispatcher.build_url("admin","services","shadowsocksr","restart"))
end
e=t:option(Flag,"switch_enable",translate("Auto Switch"))
e.rmempty=false
function e.cfgvalue(...)
return Value.cfgvalue(...)or 1
end
o:append(Template("shadowsocksr/server_list"))
return o
