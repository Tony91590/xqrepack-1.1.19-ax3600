local e=require"nixio.fs"
cpu_freqs=e.readfile("/sys/devices/system/cpu/cpufreq/policy0/scaling_available_frequencies")or"100000"
cpu_freqs=string.sub(cpu_freqs,1,-3)
cpu_governors=e.readfile("/sys/devices/system/cpu/cpufreq/policy0/scaling_available_governors")or"performance"
cpu_governors=string.sub(cpu_governors,1,-3)
function string.split(e,t)
e=tostring(e)
t=tostring(t)
if(t=='')then return false end
local a,o=0,{}
for i,t in function()return string.find(e,t,a,true)end do
table.insert(o,string.sub(e,a,i-1))
a=t+1
end
table.insert(o,string.sub(e,a))
return o
end
freq_array=string.split(cpu_freqs," ")
governor_array=string.split(cpu_governors," ")
mp=Map("cpufreq",translate("CPU Freq Settings"))
mp.description=translate("Set CPU Scaling Governor to Max Performance or Balance Mode")
s=mp:section(NamedSection,"cpufreq","settings")
s.anonymouse=true
governor=s:option(ListValue,"governor",translate("CPU Scaling Governor"))
for t,e in ipairs(governor_array)do
if e~=""then governor:value(e,translate(e,string.upper(e)))end
end
minfreq=s:option(ListValue,"minifreq",translate("Min Idle CPU Freq"))
for t,e in ipairs(freq_array)do
if e~=""then minfreq:value(e)end
end
maxfreq=s:option(ListValue,"maxfreq",translate("Max Turbo Boost CPU Freq"))
for t,e in ipairs(freq_array)do
if e~=""then maxfreq:value(e)end
end
upthreshold=s:option(Value,"upthreshold",translate("CPU Switching Threshold"))
upthreshold.datatype="range(1,99)"
upthreshold.rmempty=false
upthreshold.description=translate("Kernel make a decision on whether it should increase the frequency (%)")
upthreshold.placeholder=50
upthreshold.default=50
factor=s:option(Value,"factor",translate("CPU Switching Sampling rate"))
factor.datatype="range(1,100000)"
factor.rmempty=false
factor.description=translate("The sampling rate determines how frequently the governor checks to tune the CPU (ms)")
factor.placeholder=10
factor.default=10
return mp
