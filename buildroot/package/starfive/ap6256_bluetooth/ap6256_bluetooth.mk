################################################################################
#
# ap6256 bluetooth firmware and startup scripts
#
################################################################################

SDIO_WIFI_LICENSE = GPL-2.0+

define AP6256_BLUETOOTH_BUILD_CMDS
        cp package/starfive/ap6256_bluetooth/BCM4345C5.hcd $(@D)/
        cp package/starfive/ap6256_bluetooth/S50bluetooth $(@D)/

endef

define AP6256_BLUETOOTH_INSTALL_TARGET_CMDS
        install -m 0755 -D $(@D)/BCM4345C5.hcd $(TARGET_DIR)/lib/firmware/
        install -m 0755 -D $(@D)/S50bluetooth $(TARGET_DIR)/etc/init.d
endef

$(eval $(generic-package))

