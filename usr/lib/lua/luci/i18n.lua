module("luci.i18n",package.seeall)
require("luci.util")
local e=require"luci.template.parser"
table={}
i18ndir=luci.util.libpath().."/i18n/"
loaded={}
context=luci.util.threadlocal()
default="en"
function clear()
end
function load(e,e,e)
end
function loadc(e,e)
end
function setlanguage(t)
context.lang=t:gsub("_","-")
context.parent=(context.lang:match("^([a-z][a-z])_"))
if not e.load_catalog(context.lang,i18ndir)then
if context.parent then
e.load_catalog(context.parent,i18ndir)
return context.parent
end
end
return context.lang
end
function translate(t)
return e.translate(t)or t
end
function translatef(e,...)
return tostring(translate(e)):format(...)
end
function string(e)
return tostring(translate(e))
end
function stringf(e,...)
return tostring(translate(e)):format(...)
end
