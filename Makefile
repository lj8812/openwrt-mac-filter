include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-mac-filter
PKG_VERSION:=1.0
PKG_RELEASE:=1

LUCI_TITLE:=MAC Address Filtering Plugin
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+iptables +kmod-ipt-core +kmod-ipt-filter +luci-compat

include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)/install
    # 安装 LuCI 文件
    $(INSTALL_DIR) $(1)/usr/lib/lua/luci/{controller,model/cbi}
    $(INSTALL_DATA) ./luasrc/controller/*.lua $(1)/usr/lib/lua/luci/controller/
    $(INSTALL_DATA) ./luasrc/model/cbi/*.lua $(1)/usr/lib/lua/luci/model/cbi/
    
    # 安装 init 脚本和配置文件到系统目录
    $(INSTALL_DIR) $(1)/etc/init.d
    $(INSTALL_BIN) ./etc/init.d/mac-filter $(1)/etc/init.d/
    
    $(INSTALL_DIR) $(1)/etc/config
    $(INSTALL_DATA) ./etc/config/mac-filter $(1)/etc/config/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
