module("luci.controller.mac-filter", package.seeall)

function index()
    entry({"admin", "services", "mac-filter"}, cbi("mac-filter"), _("MAC Filtering"), 60)
end
