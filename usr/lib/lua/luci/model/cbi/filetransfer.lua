local n=require"luci.fs"
local t=luci.http
ful=SimpleForm("upload",translate("Upload"),nil)
ful.reset=false
ful.submit=false
sul=ful:section(SimpleSection,"",translate("Upload file to '/tmp/upload/'"))
fu=sul:option(FileUpload,"")
fu.template="filetransfer/other_upload"
um=sul:option(DummyValue,"",nil)
um.template="filetransfer/other_dvalue"
fdl=SimpleForm("download",translate("Download"),nil)
fdl.reset=false
fdl.submit=false
sdl=fdl:section(SimpleSection,"",translate("Download file"))
fd=sdl:option(FileUpload,"")
fd.template="filetransfer/other_download"
dm=sdl:option(DummyValue,"",nil)
dm.template="filetransfer/other_dvalue"
function Download()
local e,i,a,o
e=t.formvalue("dlfile")
i=nixio.fs.basename(e)
if luci.fs.isdirectory(e)then
a=io.popen('tar -C "%s" -cz .'%{e},"r")
i=i..".tar.gz"
else
a=nixio.open(e,"r")
end
if not a then
dm.value=translate("Couldn't open file: ")..e
return
end
dm.value=nil
t.header('Content-Disposition','attachment; filename="%s"'%{i})
t.prepare_content("application/octet-stream")
while true do
o=a:read(nixio.const.buffersize)
if(not o)or(#o==0)then
break
else
t.write(o)
end
end
a:close()
t.close()
end
local a,e
a="/tmp/upload/"
nixio.fs.mkdir(a)
t.setfilehandler(
function(t,o,i)
if not e then
if not t then return end
if t and o then e=nixio.open(a..t.file,"w")end
if not e then
um.value=translate("Create upload file error.")
return
end
end
if o and e then
e:write(o)
end
if i and e then
e:close()
e=nil
um.value=translate("File saved to")..' "/tmp/upload/'..t.file..'"'
end
end
)
if luci.http.formvalue("upload")then
local e=luci.http.formvalue("ulfile")
if#e<=0 then
um.value=translate("No specify upload file.")
end
elseif luci.http.formvalue("download")then
Download()
end
local function i(e)
local t=0
local a={' kB',' MB',' GB',' TB'}
repeat
e=e/1024
t=t+1
until(e<=1024)
return string.format("%.1f",e)..a[t]
end
local e,a={}
for t,o in ipairs(n.glob("/tmp/upload/*"))do
a=n.stat(o)
if a then
e[t]={}
e[t].name=n.basename(o)
e[t].mtime=os.date("%Y-%m-%d %H:%M:%S",a.mtime)
e[t].modestr=a.modestr
e[t].size=i(a.size)
e[t].remove=0
e[t].install=false
end
end
form=SimpleForm("filelist",translate("Upload file list"),nil)
form.reset=false
form.submit=false
tb=form:section(Table,e)
nm=tb:option(DummyValue,"name",translate("File name"))
mt=tb:option(DummyValue,"mtime",translate("Modify time"))
ms=tb:option(DummyValue,"modestr",translate("Attributes"))
sz=tb:option(DummyValue,"size",translate("Size"))
btnrm=tb:option(Button,"remove",translate("Remove"))
btnrm.render=function(e,a,t)
e.inputstyle="remove"
Button.render(e,a,t)
end
btnrm.write=function(a,t)
local a=luci.fs.unlink("/tmp/upload/"..luci.fs.basename(e[t].name))
if a then table.remove(e,t)end
return a
end
function IsIpkFile(e)
e=e or""
local e=string.lower(string.sub(e,-4,-1))
return e==".ipk"
end
btnis=tb:option(Button,"install",translate("Install"))
btnis.template="filetransfer/other_button"
btnis.render=function(o,a,t)
if not e[a]then return false end
if IsIpkFile(e[a].name)then
t.display=""
else
t.display="none"
end
o.inputstyle="apply"
Button.render(o,a,t)
end
btnis.write=function(a,t)
local e=luci.sys.exec(string.format('opkg --force-depends install "/tmp/upload/%s"',e[t].name))
form.description=string.format('<span style="color: red">%s</span>',e)
end
return ful,fdl,form
