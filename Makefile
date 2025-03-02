include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-mac-filter
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=Services
  TITLE:=MAC Address Filtering (iptables-based)
  DEPENDS:=+luci-base +iptables-mod-mac
  PKGARCH:=all
endef

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

    # 安装 LuCI 模板
    $(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/cbi
    $(INSTALL_DATA) ./luasrc/view/cbi/mac-filter.htm $(1)/usr/lib/lua/luci/view/cbi/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
