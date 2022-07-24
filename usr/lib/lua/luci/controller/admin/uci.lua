module("luci.controller.admin.uci",package.seeall)
function index()
local e=luci.http.formvalue("redir",true)or
luci.dispatcher.build_url(unpack(luci.dispatcher.context.request))
entry({"admin","uci"},nil,_("Configuration"))
entry({"admin","uci","changes"},call("action_changes"),_("Changes"),40).query={redir=e}
entry({"admin","uci","revert"},post("action_revert"),_("Revert"),30).query={redir=e}
entry({"admin","uci","apply"},post("action_apply"),_("Apply"),20).query={redir=e}
entry({"admin","uci","saveapply"},post("action_apply"),_("Save &#38; Apply"),10).query={redir=e}
end
function action_changes()
local e=luci.model.uci.cursor()
local e=e:changes()
luci.template.render("admin_uci/changes",{
changes=next(e)and e
})
end
function action_apply()
local i=luci.dispatcher.context.path
local e=luci.model.uci.cursor()
local a=e:changes()
local o={}
for t,a in pairs(a)do
table.insert(o,t)
if i[#i]~="apply"then
e:load(t)
e:commit(t)
e:unload(t)
end
end
luci.template.render("admin_uci/apply",{
changes=next(a)and a,
configs=o
})
end
function action_revert()
local e=luci.model.uci.cursor()
local t=e:changes()
for t,a in pairs(t)do
e:load(t)
e:revert(t)
e:unload(t)
end
luci.template.render("admin_uci/revert",{
changes=next(t)and t
})
end
