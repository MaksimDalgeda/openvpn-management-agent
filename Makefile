include $(TOPDIR)/rules.mk

PKG_NAME:=openvpn-management-agent
PKG_RELEASE:=2

include $(INCLUDE_DIR)/package.mk

define Package/openvpn-management-agent
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=OpenVPN Management Agent
  DEPENDS:=+lua +libuci-lua +libubus-lua +libubox-lua +luasocket
endef

define Package/openvpn-management-agent/description
OpenVPN monitoring and management service written in Lua.
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/openvpn-management-agent/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/openvpn-management-agent $(1)/etc/init.d/

	$(INSTALL_DIR) $(1)/usr/lib/openvpn-management-agent
	$(INSTALL_DATA) ./files/usr/lib/openvpn-management-agent/*.lua $(1)/usr/lib/openvpn-management-agent/
endef

$(eval $(call BuildPackage,openvpn-management-agent))