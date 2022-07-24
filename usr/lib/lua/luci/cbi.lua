module("luci.cbi",package.seeall)
require("luci.template")
local s=require("luci.util")
require("luci.http")
local a=require("nixio.fs")
local u=require("luci.model.uci")
local r=require("luci.cbi.datatypes")
local h=require("luci.dispatcher")
local t=s.class
local o=s.instanceof
FORM_NODATA=0
FORM_PROCEED=0
FORM_VALID=1
FORM_DONE=1
FORM_INVALID=-1
FORM_CHANGED=2
FORM_SKIP=4
AUTO=true
CREATE_PREFIX="cbi.cts."
REMOVE_PREFIX="cbi.rts."
RESORT_PREFIX="cbi.sts."
FEXIST_PREFIX="cbi.cbe."
function load(t,...)
local s=require"nixio.fs"
local i=require"luci.i18n"
require("luci.config")
require("luci.util")
local l="/etc/luci-uploads/"
local n=luci.util.libpath().."/model/cbi/"
local e,a
if s.access(n..t..".lua")then
e,a=loadfile(n..t..".lua")
elseif s.access(t)then
e,a=loadfile(t)
else
e,a=nil,"Model '"..t.."' not found!"
end
assert(e,a)
local t={
translate=i.translate,
translatef=i.translatef,
arg={...}
}
setfenv(e,setmetatable(t,{__index=
function(t,e)
return rawget(t,e)or _M[e]or _G[e]
end}))
local s={e()}
local h={}
local t=false
for a,e in ipairs(s)do
if not o(e,Node)then
error("CBI map returns no valid map object!")
return nil
else
e:prepare()
if e.upload_fields then
t=true
for t,e in ipairs(e.upload_fields)do
h[
e.config..'.'..
(e.section.sectiontype or'1')..'.'..
e.option
]=true
end
end
end
end
if t then
local d=luci.model.uci.cursor()
local u=luci.http.context.request.message.params
local e,a
luci.http.setfilehandler(
function(t,r,s)
if not t then return end
if t.name and not a then
local o,i,n=t.name:gmatch(
"cbid%.([^%.]+)%.([^%.]+)%.([^%.]+)"
)()
if o and i and n then
local i=d:get(o,i)or i
if h[o.."."..i.."."..n]then
local o=l..t.name
e=io.open(o,"w")
if e then
a=t.name
u[a]=o
end
end
end
end
if t.name==a and e then
e:write(r)
end
if s and e then
e:close()
e=nil
a=nil
end
end
)
end
return s
end
local i={}
function compile_datatype(s)
local e
local i=0
local t=false
local a=0
local e={}
for o=1,#s+1 do
local n=s:byte(o)or 44
if t then
t=false
elseif n==92 then
t=true
elseif n==40 or n==44 then
if a<=0 then
if i<o then
local t=s:sub(i,o-1)
:gsub("\\(.)","%1")
:gsub("^%s+","")
:gsub("%s+$","")
if#t>0 and tonumber(t)then
e[#e+1]=tonumber(t)
elseif t:match("^'.*'$")or t:match('^".*"$')then
e[#e+1]=t:gsub("[\"'](.*)[\"']","%1")
elseif type(r[t])=="function"then
e[#e+1]=r[t]
e[#e+1]={}
else
error("Datatype error, bad token %q"%t)
end
end
i=o+1
end
a=a+(n==40 and 1 or 0)
elseif n==41 then
a=a-1
if a<=0 then
if type(e[#e-1])~="function"then
error("Datatype error, argument list follows non-function")
end
e[#e]=compile_datatype(s:sub(i,o-1))
i=o+1
end
end
end
return e
end
function verify_datatype(e,a)
if e and#e>0 then
if not i[e]then
local t=compile_datatype(e)
if t and type(t[1])=="function"then
i[e]=t
else
error("Datatype error, not a function expression")
end
end
if i[e]then
return i[e][1](a,unpack(i[e][2]))
end
end
return true
end
Node=t()
function Node.__init__(e,t,a)
e.children={}
e.title=t or""
e.description=a or""
e.template="cbi/node"
end
function Node._run_hook(e,t)
if type(e[t])=="function"then
return e[t](e)
end
end
function Node._run_hooks(e,...)
local t
local a=false
for o,t in ipairs(arg)do
if type(e[t])=="function"then
e[t](e)
a=true
end
end
return a
end
function Node.prepare(e,...)
for t,e in ipairs(e.children)do
e:prepare(...)
end
end
function Node.append(t,e)
table.insert(t.children,e)
end
function Node.parse(e,...)
for t,e in ipairs(e.children)do
e:parse(...)
end
end
function Node.render(t,e)
e=e or{}
e.self=t
luci.template.render(t.template,e)
end
function Node.render_children(a,...)
local e,e
for t,e in ipairs(a.children)do
e.last_child=(t==#a.children)
e.index=t
e:render(...)
end
end
Template=t(Node)
function Template.__init__(e,t)
Node.__init__(e)
e.template=t
end
function Template.render(e)
luci.template.render(e.template,{self=e})
end
function Template.parse(e,t)
e.readinput=(t~=false)
return Map.formvalue(e,"cbi.submit")and FORM_DONE or FORM_NODATA
end
Map=t(Node)
function Map.__init__(e,t,...)
Node.__init__(e,...)
e.config=t
e.parsechain={e.config}
e.template="cbi/map"
e.apply_on_parse=nil
e.readinput=true
e.proceed=false
e.flow={}
e.uci=u.cursor()
e.save=true
e.changed=false
local o="%s/%s"%{e.uci:get_confdir(),e.config}
if a.stat(o,"type")~="reg"then
a.writefile(o,"")
end
local t,i=e.uci:load(e.config)
if not t then
local s=h.build_url(unpack(h.context.request))
local n=e:formvalue("cbi.source")
if type(n)=="string"then
a.writefile(o,n:gsub("\r\n","\n"))
t,i=e.uci:load(e.config)
if t then
luci.http.redirect(s)
end
end
e.save=false
end
if not t then
e.template="cbi/error"
e.error=i
e.source=a.readfile(o)or""
e.pageaction=false
end
end
function Map.formvalue(e,t)
return e.readinput and luci.http.formvalue(t)or nil
end
function Map.formvaluetable(t,e)
return t.readinput and luci.http.formvaluetable(e)or{}
end
function Map.get_scheme(e,t,a)
if not a then
return e.scheme and e.scheme.sections[t]
else
return e.scheme and e.scheme.variables[t]
and e.scheme.variables[t][a]
end
end
function Map.submitstate(e)
return e:formvalue("cbi.submit")
end
function Map.chain(t,e)
table.insert(t.parsechain,e)
end
function Map.state_handler(t,e)
return e
end
function Map.parse(e,t,...)
if e:formvalue("cbi.skip")then
e.state=FORM_SKIP
elseif not e.save then
e.state=FORM_INVALID
elseif not e:submitstate()then
e.state=FORM_NODATA
end
if e.state~=nil then
return e:state_handler(e.state)
end
e.readinput=(t~=false)
e:_run_hooks("on_parse")
Node.parse(e,...)
if e.save then
e:_run_hooks("on_save","on_before_save")
for a,t in ipairs(e.parsechain)do
e.uci:save(t)
end
e:_run_hooks("on_after_save")
if(not e.proceed and e.flow.autoapply)or luci.http.formvalue("cbi.apply")then
e:_run_hooks("on_before_commit")
for a,t in ipairs(e.parsechain)do
e.uci:commit(t)
e.uci:load(t)
end
e:_run_hooks("on_commit","on_after_commit","on_before_apply")
if e.apply_on_parse then
e.uci:apply(e.parsechain)
e:_run_hooks("on_apply","on_after_apply")
else
e.apply_needed=true
end
Node.parse(e,true)
end
for a,t in ipairs(e.parsechain)do
e.uci:unload(t)
end
if type(e.commit_handler)=="function"then
e:commit_handler(e:submitstate())
end
end
if not e.save then
e.state=FORM_INVALID
elseif e.proceed then
e.state=FORM_PROCEED
elseif e.changed then
e.state=FORM_CHANGED
else
e.state=FORM_VALID
end
return e:state_handler(e.state)
end
function Map.render(e,...)
e:_run_hooks("on_init")
Node.render(e,...)
end
function Map.section(e,t,...)
if o(t,AbstractSection)then
local t=t(e,...)
e:append(t)
return t
else
error("class must be a descendent of AbstractSection")
end
end
function Map.add(e,t)
return e.uci:add(e.config,t)
end
function Map.set(e,o,a,t)
if type(t)~="table"or#t>0 then
if a then
return e.uci:set(e.config,o,a,t)
else
return e.uci:set(e.config,o,t)
end
else
return Map.del(e,o,a)
end
end
function Map.del(e,a,t)
if t then
return e.uci:delete(e.config,a,t)
else
return e.uci:delete(e.config,a)
end
end
function Map.get(e,t,a)
if not t then
return e.uci:get_all(e.config)
elseif a then
return e.uci:get(e.config,t,a)
else
return e.uci:get_all(e.config,t)
end
end
Compound=t(Node)
function Compound.__init__(e,...)
Node.__init__(e)
e.template="cbi/compound"
e.children={...}
end
function Compound.populate_delegator(e,t)
for a,e in ipairs(e.children)do
e.delegator=t
end
end
function Compound.parse(a,...)
local t,e=0
for o,a in ipairs(a.children)do
t=a:parse(...)
e=(not e or t<e)and t or e
end
return e
end
Delegator=t(Node)
function Delegator.__init__(e,...)
Node.__init__(e,...)
e.nodes={}
e.defaultpath={}
e.pageaction=false
e.readinput=true
e.allow_reset=false
e.allow_cancel=false
e.allow_back=false
e.allow_finish=false
e.template="cbi/delegator"
end
function Delegator.set(e,t,a)
assert(not e.nodes[t],"Duplicate entry")
e.nodes[t]=a
end
function Delegator.add(e,a,t)
t=e:set(a,t)
e.defaultpath[#e.defaultpath+1]=a
end
function Delegator.insert_after(e,a,o)
local t=#e.chain+1
for a,e in ipairs(e.chain)do
if e==o then
t=a+1
break
end
end
table.insert(e.chain,t,a)
end
function Delegator.set_route(o,...)
local t,e,a=0,o.chain,{...}
for a=1,#e do
if e[a]==o.current then
t=a
break
end
end
for o=1,#a do
t=t+1
e[t]=a[o]
end
for t=t+1,#e do
e[t]=nil
end
end
function Delegator.get(e,t)
local e=e.nodes[t]
if type(e)=="string"then
e=load(e,t)
end
if type(e)=="table"and getmetatable(e)==nil then
e=Compound(unpack(e))
end
return e
end
function Delegator.parse(e,...)
if e.allow_cancel and Map.formvalue(e,"cbi.cancel")then
if e:_run_hooks("on_cancel")then
return FORM_DONE
end
end
if not Map.formvalue(e,"cbi.delg.current")then
e:_run_hooks("on_init")
end
local t
e.chain=e.chain or e:get_chain()
e.current=e.current or e:get_active()
e.active=e.active or e:get(e.current)
assert(e.active,"Invalid state")
local a=FORM_DONE
if type(e.active)~="function"then
e.active:populate_delegator(e)
a=e.active:parse()
else
e:active()
end
if a>FORM_PROCEED then
if Map.formvalue(e,"cbi.delg.back")then
t=e:get_prev(e.current)
else
t=e:get_next(e.current)
end
elseif a<FORM_PROCEED then
return a
end
if not Map.formvalue(e,"cbi.submit")then
return FORM_NODATA
elseif a>FORM_PROCEED
and(not t or not e:get(t))then
return e:_run_hook("on_done")or FORM_DONE
else
e.current=t or e.current
e.active=e:get(e.current)
if type(e.active)~="function"then
e.active:populate_delegator(e)
local t=e.active:parse(false)
if t==FORM_SKIP then
return e:parse(...)
else
return FORM_PROCEED
end
else
return e:parse(...)
end
end
end
function Delegator.get_next(e,t)
for a,o in ipairs(e.chain)do
if o==t then
return e.chain[a+1]
end
end
end
function Delegator.get_prev(e,o)
for a,t in ipairs(e.chain)do
if t==o then
return e.chain[a-1]
end
end
end
function Delegator.get_chain(e)
local e=Map.formvalue(e,"cbi.delg.path")or e.defaultpath
return type(e)=="table"and e or{e}
end
function Delegator.get_active(e)
return Map.formvalue(e,"cbi.delg.current")or e.chain[1]
end
Page=t(Node)
Page.__init__=Node.__init__
Page.parse=function()end
SimpleForm=t(Node)
function SimpleForm.__init__(e,o,i,a,t)
Node.__init__(e,i,a)
e.config=o
e.data=t or{}
e.template="cbi/simpleform"
e.dorender=true
e.pageaction=false
e.readinput=true
end
SimpleForm.formvalue=Map.formvalue
SimpleForm.formvaluetable=Map.formvaluetable
function SimpleForm.parse(e,t,...)
e.readinput=(t~=false)
if e:formvalue("cbi.skip")then
return FORM_SKIP
end
if e:formvalue("cbi.cancel")and e:_run_hooks("on_cancel")then
return FORM_DONE
end
if e:submitstate()then
Node.parse(e,1,...)
end
local t=true
for a,e in ipairs(e.children)do
for a,e in ipairs(e.children)do
t=t
and(not e.tag_missing or not e.tag_missing[1])
and(not e.tag_invalid or not e.tag_invalid[1])
and(not e.error)
end
end
local t=
not e:submitstate()and FORM_NODATA
or t and FORM_VALID
or FORM_INVALID
e.dorender=not e.handle
if e.handle then
local o,a=e:handle(t,e.data)
e.dorender=e.dorender or(o~=false)
t=a or t
end
return t
end
function SimpleForm.render(e,...)
if e.dorender then
Node.render(e,...)
end
end
function SimpleForm.submitstate(e)
return e:formvalue("cbi.submit")
end
function SimpleForm.section(t,e,...)
if o(e,AbstractSection)then
local e=e(t,...)
t:append(e)
return e
else
error("class must be a descendent of AbstractSection")
end
end
function SimpleForm.field(t,a,...)
local e
for a,t in ipairs(t.children)do
if o(t,SimpleSection)then
e=t
break
end
end
if not e then
e=t:section(SimpleSection)
end
if o(a,AbstractValue)then
local t=a(t,e,...)
t.track_missing=true
e:append(t)
return t
else
error("class must be a descendent of AbstractValue")
end
end
function SimpleForm.set(t,o,e,a)
t.data[e]=a
end
function SimpleForm.del(e,a,t)
e.data[t]=nil
end
function SimpleForm.get(t,a,e)
return t.data[e]
end
function SimpleForm.get_scheme()
return nil
end
Form=t(SimpleForm)
function Form.__init__(e,...)
SimpleForm.__init__(e,...)
e.embedded=true
end
AbstractSection=t(Node)
function AbstractSection.__init__(e,t,a,...)
Node.__init__(e,...)
e.sectiontype=a
e.map=t
e.config=t.config
e.optionals={}
e.defaults={}
e.fields={}
e.tag_error={}
e.tag_invalid={}
e.tag_deperror={}
e.changed=false
e.optional=true
e.addremove=false
e.dynamic=false
end
function AbstractSection.tab(e,t,a,o)
e.tabs=e.tabs or{}
e.tab_names=e.tab_names or{}
e.tab_names[#e.tab_names+1]=t
e.tabs[t]={
title=a,
description=o,
childs={}
}
end
function AbstractSection.has_tabs(e)
return(e.tabs~=nil)and(next(e.tabs)~=nil)
end
function AbstractSection.option(e,t,a,...)
if o(t,AbstractValue)then
local t=t(e.map,e,a,...)
e:append(t)
e.fields[a]=t
return t
elseif t==true then
error("No valid class was given and autodetection failed.")
else
error("class must be a descendant of AbstractValue")
end
end
function AbstractSection.taboption(t,e,...)
assert(e and t.tabs and t.tabs[e],
"Cannot assign option to not existing tab %q"%tostring(e))
local a=t.tabs[e].childs
local e=AbstractSection.option(t,...)
if e then a[#a+1]=e end
return e
end
function AbstractSection.render_tab(t,e,...)
assert(e and t.tabs and t.tabs[e],
"Cannot render not existing tab %q"%tostring(e))
local a,a
for o,a in ipairs(t.tabs[e].childs)do
a.last_child=(o==#t.tabs[e].childs)
a.index=o
a:render(...)
end
end
function AbstractSection.parse_optionals(e,a,o)
if not e.optional then
return
end
e.optionals[a]={}
local t=nil
if not o then
t=e.map:formvalue("cbi.opt."..e.config.."."..a)
end
for i,o in ipairs(e.children)do
if o.optional and not o:cfgvalue(a)and not e:has_tabs()then
if t==o.option then
t=nil
e.map.proceed=true
else
table.insert(e.optionals[a],o)
end
end
end
if t and#t>0 and e.dynamic then
e:add_dynamic(t)
end
end
function AbstractSection.add_dynamic(t,e,a)
local e=t:option(Value,e,e)
e.optional=a
end
function AbstractSection.parse_dynamic(e,t)
if not e.dynamic then
return
end
local a=luci.util.clone(e:cfgvalue(t))
local t=e.map:formvaluetable("cbid."..e.config.."."..t)
for t,e in pairs(t)do
a[t]=e
end
for t,a in pairs(a)do
local a=true
for o,e in ipairs(e.children)do
if e.option==t then
a=false
end
end
if a and t:sub(1,1)~="."then
e.map.proceed=true
e:add_dynamic(t,true)
end
end
end
function AbstractSection.cfgvalue(t,e)
return t.map:get(e)
end
function AbstractSection.push_events(e)
e.map.changed=true
end
function AbstractSection.remove(e,t)
e.map.proceed=true
return e.map:del(t)
end
function AbstractSection.create(e,t)
local a
if t then
a=t:match("^[%w_]+$")and e.map:set(t,nil,e.sectiontype)
else
t=e.map:add(e.sectiontype)
a=t
end
if a then
for o,a in pairs(e.children)do
if a.default then
e.map:set(t,a.option,a.default)
end
end
for o,a in pairs(e.defaults)do
e.map:set(t,o,a)
end
end
e.map.proceed=true
return a
end
SimpleSection=t(AbstractSection)
function SimpleSection.__init__(e,t,...)
AbstractSection.__init__(e,t,nil,...)
e.template="cbi/nullsection"
end
Table=t(AbstractSection)
function Table.__init__(t,e,o,...)
local e={}
local a=t
e.config="table"
t.data=o or{}
e.formvalue=Map.formvalue
e.formvaluetable=Map.formvaluetable
e.readinput=true
function e.get(o,e,t)
return a.data[e]and a.data[e][t]
end
function e.submitstate(e)
return Map.formvalue(e,"cbi.submit")
end
function e.del(...)
return true
end
function e.get_scheme()
return nil
end
AbstractSection.__init__(t,e,"table",...)
t.template="cbi/tblsection"
t.rowcolors=true
t.anonymous=true
end
function Table.parse(e,t)
e.map.readinput=(t~=false)
for a,t in ipairs(e:cfgsections())do
if e.map:submitstate()then
Node.parse(e,t)
end
end
end
function Table.cfgsections(t)
local e={}
for t,a in luci.util.kspairs(t.data)do
table.insert(e,t)
end
return e
end
function Table.update(e,t)
e.data=t
end
NamedSection=t(AbstractSection)
function NamedSection.__init__(e,a,o,t,...)
AbstractSection.__init__(e,a,t,...)
e.addremove=false
e.template="cbi/nsection"
e.section=o
end
function NamedSection.prepare(e)
AbstractSection.prepare(e)
AbstractSection.parse_optionals(e,e.section,true)
end
function NamedSection.parse(e,t)
local t=e.section
local a=e:cfgvalue(t)
if e.addremove then
local o=e.config.."."..t
if a then
if e.map:formvalue("cbi.rns."..o)and e:remove(t)then
e:push_events()
return
end
else
if e.map:formvalue("cbi.cns."..o)then
e:create(t)
return
end
end
end
if a then
AbstractSection.parse_dynamic(e,t)
if e.map:submitstate()then
Node.parse(e,t)
end
AbstractSection.parse_optionals(e,t)
if e.changed then
e:push_events()
end
end
end
TypedSection=t(AbstractSection)
function TypedSection.__init__(e,t,a,...)
AbstractSection.__init__(e,t,a,...)
e.template="cbi/tsection"
e.deps={}
e.anonymous=false
end
function TypedSection.prepare(e)
AbstractSection.prepare(e)
local t,t
for a,t in ipairs(e:cfgsections())do
AbstractSection.parse_optionals(e,t,true)
end
end
function TypedSection.cfgsections(e)
local t={}
e.map.uci:foreach(e.map.config,e.sectiontype,
function(a)
if e:checkscope(a[".name"])then
table.insert(t,a[".name"])
end
end)
return t
end
function TypedSection.depends(t,a,e)
table.insert(t.deps,{option=a,value=e})
end
function TypedSection.parse(e,a)
if e.addremove then
local t=REMOVE_PREFIX..e.config
local t=e.map:formvaluetable(t)
for t,a in pairs(t)do
if t:sub(-2)==".x"then
t=t:sub(1,#t-2)
end
if e:cfgvalue(t)and e:checkscope(t)then
e:remove(t)
end
end
end
local t
for o,t in ipairs(e:cfgsections())do
AbstractSection.parse_dynamic(e,t)
if e.map:submitstate()then
Node.parse(e,t,a)
end
AbstractSection.parse_optionals(e,t)
end
if e.addremove then
local a
local t=CREATE_PREFIX..e.config.."."..e.sectiontype
local o,t=next(e.map:formvaluetable(t))
if e.anonymous then
if t then
a=e:create(nil,o)
end
else
if t then
if e:cfgvalue(t)then
t=nil;
end
t=e:checkscope(t)
if not t then
e.err_invalid=true
end
if t and#t>0 then
a=e:create(t,o)and t
if not a then
e.invalid_cts=true
end
end
end
end
if a then
AbstractSection.parse_optionals(e,a)
end
end
if e.sortable then
local t=RESORT_PREFIX..e.config.."."..e.sectiontype
local a=e.map:formvalue(t)
if a and#a>0 then
local t
local t=0
for a in s.imatch(a)do
e.map.uci:reorder(e.config,a,t)
t=t+1
end
e.changed=(t>0)
end
end
if created or e.changed then
e:push_events()
end
end
function TypedSection.checkscope(e,t)
if e.filter and not e:filter(t)then
return nil
end
if#e.deps>0 and e:cfgvalue(t)then
local o=false
for i,a in ipairs(e.deps)do
if e:cfgvalue(t)[a.option]==a.value then
o=true
end
end
if not o then
return nil
end
end
return e:validate(t)
end
function TypedSection.validate(t,e)
return e
end
AbstractValue=t(Node)
function AbstractValue.__init__(e,t,a,o,...)
Node.__init__(e,...)
e.section=a
e.option=o
e.map=t
e.config=t.config
e.tag_invalid={}
e.tag_missing={}
e.tag_reqerror={}
e.tag_error={}
e.deps={}
e.track_missing=false
e.rmempty=true
e.default=nil
e.size=nil
e.optional=false
end
function AbstractValue.prepare(e)
e.cast=e.cast or"string"
end
function AbstractValue.depends(a,t,o)
local e
if type(t)=="string"then
e={}
e[t]=o
else
e=t
end
table.insert(a.deps,e)
end
function AbstractValue.deplist2json(a,n,e)
local o,t,t={}
if type(a.deps)=="table"then
for t,e in ipairs(e or a.deps)do
local t,i,i={}
for e,i in pairs(e)do
if e:find("!",1,true)then
t[e]=i
elseif e:find(".",1,true)then
t['cbid.%s'%e]=i
else
t['cbid.%s.%s.%s'%{a.config,n,e}]=i
end
end
o[#o+1]=t
end
end
return s.serialize_json(o)
end
function AbstractValue.cbid(e,t)
return"cbid."..e.map.config.."."..t.."."..e.option
end
function AbstractValue.formcreated(e,t)
local t="cbi.opt."..e.config.."."..t
return(e.map:formvalue(t)==e.option)
end
function AbstractValue.formvalue(e,t)
return e.map:formvalue(e:cbid(t))
end
function AbstractValue.additional(e,t)
e.optional=t
end
function AbstractValue.mandatory(t,e)
t.rmempty=not e
end
function AbstractValue.add_error(e,t,a,o)
e.error=e.error or{}
e.error[t]=o or a
e.section.error=e.section.error or{}
e.section.error[t]=e.section.error[t]or{}
table.insert(e.section.error[t],o or a)
if a=="invalid"then
e.tag_invalid[t]=true
elseif a=="missing"then
e.tag_missing[t]=true
end
e.tag_error[t]=true
e.map.save=false
end
function AbstractValue.parse(t,a,i)
local e=t:formvalue(a)
local o=t:cfgvalue(a)
if type(e)=="table"and type(o)=="table"then
local t=#e==#o
if t then
for a=1,#e do
if o[a]~=e[a]then
t=false
end
end
end
if t then
e=o
end
end
if e and#e>0 then
local n
e,n=t:validate(e,a)
e=t:transform(e)
if not e and not i then
t:add_error(a,"invalid",n)
end
if e and(t.forcewrite or not(e==o))then
if t:write(a,e)then
t.section.changed=true
end
end
else
if t.rmempty or t.optional then
if t:remove(a)then
t.section.changed=true
end
elseif o~=e and not i then
local o,e=t:validate(nil,a)
t:add_error(a,"missing",e)
end
end
end
function AbstractValue.render(e,a,t)
if not e.optional or e.section:has_tabs()or e:cfgvalue(a)or e:formcreated(a)then
t=t or{}
t.section=a
t.cbid=e:cbid(a)
Node.render(e,t)
end
end
function AbstractValue.cfgvalue(t,a)
local e
if t.tag_error[a]then
e=t:formvalue(a)
else
e=t.map:get(a,t.option)
end
if not e then
return nil
elseif not t.cast or t.cast==type(e)then
return e
elseif t.cast=="string"then
if type(e)=="table"then
return e[1]
end
elseif t.cast=="table"then
return{e}
end
end
function AbstractValue.validate(t,e)
if t.datatype and e then
if type(e)=="table"then
local a
for a,e in ipairs(e)do
if e and#e>0 and not verify_datatype(t.datatype,e)then
return nil
end
end
else
if not verify_datatype(t.datatype,e)then
return nil
end
end
end
return e
end
AbstractValue.transform=AbstractValue.validate
function AbstractValue.write(e,a,t)
return e.map:set(a,e.option,t)
end
function AbstractValue.remove(e,t)
return e.map:del(t,e.option)
end
Value=t(AbstractValue)
function Value.__init__(e,...)
AbstractValue.__init__(e,...)
e.template="cbi/value"
e.keylist={}
e.vallist={}
e.readonly=nil
end
function Value.reset_values(e)
e.keylist={}
e.vallist={}
end
function Value.value(t,a,e)
e=e or a
table.insert(t.keylist,tostring(a))
table.insert(t.vallist,tostring(e))
end
function Value.parse(e,a,t)
if e.readonly then return end
AbstractValue.parse(e,a,t)
end
DummyValue=t(AbstractValue)
function DummyValue.__init__(e,...)
AbstractValue.__init__(e,...)
e.template="cbi/dvalue"
e.value=nil
end
function DummyValue.cfgvalue(e,a)
local t
if e.value then
if type(e.value)=="function"then
t=e:value(a)
else
t=e.value
end
else
t=AbstractValue.cfgvalue(e,a)
end
return t
end
function DummyValue.parse(e)
end
Flag=t(AbstractValue)
function Flag.__init__(e,...)
AbstractValue.__init__(e,...)
e.template="cbi/fvalue"
e.enabled="1"
e.disabled="0"
e.default=e.disabled
end
function Flag.parse(e,t,i)
local a=e.map:formvalue(
FEXIST_PREFIX..e.config.."."..t.."."..e.option)
if a then
local a=e:formvalue(t)and e.enabled or e.disabled
local n=e:cfgvalue(t)
local o
a,o=e:validate(a,t)
if not a then
if not i then
e:add_error(t,"invalid",o)
end
return
end
if a==e.default and(e.optional or e.rmempty)then
e:remove(t)
else
e:write(t,a)
end
if(a~=n)then e.section.changed=true end
else
e:remove(t)
e.section.changed=true
end
end
function Flag.cfgvalue(e,t)
return AbstractValue.cfgvalue(e,t)or e.default
end
function Flag.validate(t,e)
return e
end
ListValue=t(AbstractValue)
function ListValue.__init__(e,...)
AbstractValue.__init__(e,...)
e.template="cbi/lvalue"
e.size=1
e.widget="select"
e:reset_values()
end
function ListValue.reset_values(e)
e.keylist={}
e.vallist={}
e.deplist={}
end
function ListValue.value(e,a,t,...)
if luci.util.contains(e.keylist,a)then
return
end
t=t or a
table.insert(e.keylist,tostring(a))
table.insert(e.vallist,tostring(t))
table.insert(e.deplist,{...})
end
function ListValue.validate(t,e)
if luci.util.contains(t.keylist,e)then
return e
else
return nil
end
end
MultiValue=t(AbstractValue)
function MultiValue.__init__(e,...)
AbstractValue.__init__(e,...)
e.template="cbi/mvalue"
e.widget="checkbox"
e.delimiter=" "
e:reset_values()
end
function MultiValue.render(e,...)
if e.widget=="select"and not e.size then
e.size=#e.vallist
end
AbstractValue.render(e,...)
end
function MultiValue.reset_values(e)
e.keylist={}
e.vallist={}
e.deplist={}
end
function MultiValue.value(a,e,t)
if luci.util.contains(a.keylist,e)then
return
end
t=t or e
table.insert(a.keylist,tostring(e))
table.insert(a.vallist,tostring(t))
end
function MultiValue.valuelist(e,t)
local t=e:cfgvalue(t)
if not(type(t)=="string")then
return{}
end
return luci.util.split(t,e.delimiter)
end
function MultiValue.validate(a,e)
e=(type(e)=="table")and e or{e}
local t
for o,e in ipairs(e)do
if luci.util.contains(a.keylist,e)then
t=t and(t..a.delimiter..e)or e
end
end
return t
end
StaticList=t(MultiValue)
function StaticList.__init__(e,...)
MultiValue.__init__(e,...)
e.cast="table"
e.valuelist=e.cfgvalue
if not e.override_scheme
and e.map:get_scheme(e.section.sectiontype,e.option)then
local t=e.map:get_scheme(e.section.sectiontype,e.option)
if e.value and t.values and not e.override_values then
for a,t in pairs(t.values)do
e:value(a,t)
end
end
end
end
function StaticList.validate(a,e)
e=(type(e)=="table")and e or{e}
local t={}
for o,e in ipairs(e)do
if luci.util.contains(a.keylist,e)then
table.insert(t,e)
end
end
return t
end
DynamicList=t(AbstractValue)
function DynamicList.__init__(e,...)
AbstractValue.__init__(e,...)
e.template="cbi/dynlist"
e.cast="table"
e:reset_values()
end
function DynamicList.reset_values(e)
e.keylist={}
e.vallist={}
end
function DynamicList.value(a,t,e)
e=e or t
table.insert(a.keylist,tostring(t))
table.insert(a.vallist,tostring(e))
end
function DynamicList.write(a,o,e)
local t={}
if type(e)=="table"then
local a
for a,e in ipairs(e)do
if e and#e>0 then
t[#t+1]=e
end
end
else
t={e}
end
if a.cast=="string"then
e=table.concat(t," ")
else
e=t
end
return AbstractValue.write(a,o,e)
end
function DynamicList.cfgvalue(e,t)
local e=AbstractValue.cfgvalue(e,t)
if type(e)=="string"then
local t
local t={}
for a in e:gmatch("%S+")do
if#a>0 then
t[#t+1]=a
end
end
e=t
end
return e
end
function DynamicList.formvalue(t,e)
local e=AbstractValue.formvalue(t,e)
if type(e)=="string"then
if t.cast=="string"then
local t
local t={}
for a in e:gmatch("%S+")do
t[#t+1]=a
end
e=t
else
e={e}
end
end
return e
end
TextValue=t(AbstractValue)
function TextValue.__init__(e,...)
AbstractValue.__init__(e,...)
e.template="cbi/tvalue"
end
Button=t(AbstractValue)
function Button.__init__(e,...)
AbstractValue.__init__(e,...)
e.template="cbi/button"
e.inputstyle=nil
e.rmempty=true
e.unsafeupload=false
end
FileUpload=t(AbstractValue)
function FileUpload.__init__(e,...)
AbstractValue.__init__(e,...)
e.template="cbi/upload"
if not e.map.upload_fields then
e.map.upload_fields={e}
else
e.map.upload_fields[#e.map.upload_fields+1]=e
end
end
function FileUpload.formcreated(e,t)
if e.unsafeupload then
return AbstractValue.formcreated(e,t)or
e.map:formvalue("cbi.rlf."..t.."."..e.option)or
e.map:formvalue("cbi.rlf."..t.."."..e.option..".x")or
e.map:formvalue("cbid."..e.map.config.."."..t.."."..e.option..".textbox")
else
return AbstractValue.formcreated(e,t)or
e.map:formvalue("cbid."..e.map.config.."."..t.."."..e.option..".textbox")
end
end
function FileUpload.cfgvalue(t,e)
local e=AbstractValue.cfgvalue(t,e)
if e and a.access(e)then
return e
end
return nil
end
function FileUpload.formvalue(e,o)
local t=AbstractValue.formvalue(e,o)
if t then
if e.unsafeupload then
if not e.map:formvalue("cbi.rlf."..o.."."..e.option)and
not e.map:formvalue("cbi.rlf."..o.."."..e.option..".x")
then
return t
end
a.unlink(t)
e.value=nil
return nil
elseif t~=""then
return t
end
end
t=luci.http.formvalue("cbid."..e.map.config.."."..o.."."..e.option..".textbox")
if t==""then
t=nil
end
if not e.unsafeupload then
if not t then
t=e.map:formvalue("cbi.rlf."..o.."."..e.option)
end
end
return t
end
function FileUpload.remove(t,o)
if t.unsafeupload then
local e=AbstractValue.formvalue(t,o)
if e and a.access(e)then a.unlink(e)end
return AbstractValue.remove(t,o)
else
return nil
end
end
FileBrowser=t(AbstractValue)
function FileBrowser.__init__(e,...)
AbstractValue.__init__(e,...)
e.template="cbi/browser"
end
