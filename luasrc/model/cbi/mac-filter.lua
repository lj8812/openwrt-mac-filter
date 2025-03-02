local uci = require("luci.model.uci").cursor()
local sys = require("luci.sys")
local fs = require "nixio.fs"

m = Map("mac-filter", translate("MAC Address Filter (iptables)"))

-- 动态获取当前网络中的 MAC 地址（ARP + DHCP）
local function get_live_macs()
    local macs = {}
    
    -- 从 ARP 表获取
    local arp = fs.readfile("/proc/net/arp")
    if arp then
        for line in arp:gmatch("[^\r\n]+") do
            if not line:match("IP address") then
                local ip, _, _, mac = line:match("^(%S+)%s+%S+%s+%S+%s+(%S+)")
                if mac and mac ~= "00:00:00:00:00:00" then
                    macs[mac:upper()] = ip and ("%s (%s)" % {mac:upper(), ip}) or mac:upper()
                end
            end
        end
    end
    
    -- 从 DHCP 租约获取
    local leases = fs.readfile("/tmp/dhcp.leases")
    if leases then
        for line in leases:gmatch("[^\r\n]+") do
            local ts, mac, ip, name = line:match("^(%d+) (%S+) (%S+) (%S+)")
            if mac then
                macs[mac:upper()] = macs[mac:upper()] or ("%s (DHCP)" % mac:upper())
            end
        end
    end
    
    return macs
end

-- 全局设置
s = m:section(NamedSection, "global", "macfilter", translate("Global Settings"))
s.addremove = false

o = s:option(Flag, "enable", translate("Enable Filtering"))
o.default = 1

o = s:option(Flag, "log", translate("Log Dropped Packets"))
o.default = 1

-- 规则列表
s = m:section(TypedSection, "rule", translate("Filter Rules"))
s.template = "cbi/tblsection"
s.addremove = true
s.anonymous = true

-- MAC 地址下拉选择（带动态更新）
mac = s:option(Value, "mac", translate("MAC Address"))
mac.datatype = "macaddr"
mac.rmempty = false

-- 添加动态 MAC 地址选项
local live_macs = get_live_macs()
for mac_addr, desc in pairs(live_macs) do
    mac:value(mac_addr, desc)
end

-- 动作选择
action = s:option(ListValue, "action", translate("Action"))
action:value("deny", translate("Block"))
action:value("allow", translate("Allow"))
action.default = "deny"

-- 注释
comment = s:option(Value, "comment", translate("Comment"))

-- 提交时应用规则
function m.on_commit(self)
    os.execute("/etc/init.d/mac-filter reload >/dev/null")
end

return m  -- 正确结束
