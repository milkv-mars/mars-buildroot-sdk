################################################################################
#
# sdio wifi firmware
#
################################################################################

SDIO_WIFI_LICENSE = GPL-2.0+

define SDIO_WIFI_BUILD_CMDS
	cp package/starfive/sdio_wifi/fw_bcm43456c5_ag.bin $(@D)/
	cp package/starfive/sdio_wifi/nvram_ap6256.txt $(@D)/

endef

define SDIO_WIFI_INSTALL_TARGET_CMDS
	install -m 0755 -D $(@D)/fw_bcm43456c5_ag.bin $(TARGET_DIR)/lib/firmware/
	install -m 0755 -D $(@D)/nvram_ap6256.txt $(TARGET_DIR)/lib/firmware/
endef

$(eval $(generic-package))

