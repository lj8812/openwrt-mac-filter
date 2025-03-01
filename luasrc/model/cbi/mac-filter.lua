local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local ipkg = require("luci.model.ipkg")

m = Map("mac-filter", translate("MAC Address Filtering"))

s = m:section(TypedSection, "rule", translate("Rules"))
s.anonymous = true
s.addremove = false

-- 动态获取 ARP 表中的活跃 MAC 地址
local macs = {}
sys.net.arptable(function(e)
    if e and e.HWaddress and e.Flags and e.Flags.reachable then
        macs[e.HWaddress:upper()] = e.IPaddress
    end
end)

mac_list = s:option(ListValue, "mac", translate("Client MAC"))
mac_list:value("", "-- Select --")
for mac, ip in pairs(macs) do
    mac_list:value(mac, "%s (%s)" % {mac, ip})
end

enabled = s:option(Flag, "enabled", translate("Enable Blocking"))
enabled.default = 0

function m.on_commit(self)
    os.execute("/etc/init.d/mac-filter reload >/dev/null 2>&1")
end

return m
