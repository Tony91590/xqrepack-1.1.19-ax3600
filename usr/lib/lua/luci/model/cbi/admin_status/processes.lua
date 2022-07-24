f=SimpleForm("processes",translate("Processes"),translate("This list gives an overview over currently running system processes and their status."))
f.reset=false
f.submit=false
t=f:section(Table,luci.sys.process.list())
t:option(DummyValue,"PID",translate("PID"))
t:option(DummyValue,"USER",translate("Owner"))
t:option(DummyValue,"COMMAND",translate("Command"))
t:option(DummyValue,"%CPU",translate("CPU usage (%)"))
t:option(DummyValue,"%MEM",translate("Memory usage (%)"))
hup=t:option(Button,"_hup",translate("Hang Up"))
hup.inputstyle="reload"
function hup.write(t,e)
null,t.tag_error[e]=luci.sys.process.signal(e,1)
end
term=t:option(Button,"_term",translate("Terminate"))
term.inputstyle="remove"
function term.write(t,e)
null,t.tag_error[e]=luci.sys.process.signal(e,15)
end
kill=t:option(Button,"_kill",translate("Kill"))
kill.inputstyle="reset"
function kill.write(t,e)
null,t.tag_error[e]=luci.sys.process.signal(e,9)
end
return f