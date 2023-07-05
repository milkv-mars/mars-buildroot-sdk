
################################################################################
#
# usb wifi firmware
#
################################################################################

USB_WIFI_LICENSE = GPL-2.0+

define USB_WIFI_BUILD_CMDS
	cp package/starfive/usb_wifi/ECR6600U_transport.bin $(@D)/
	cp -r package/starfive/usb_wifi/aic8800 $(@D)/
	cp -r package/starfive/usb_wifi/aic8800DC $(@D)/
endef

define USB_WIFI_INSTALL_TARGET_CMDS
	install -m 0755 -D $(@D)/ECR6600U_transport.bin $(TARGET_DIR)/lib/firmware/
	install -d -m 0755 $(TARGET_DIR)/lib/firmware/aic8800
	install -m 0644 -t $(TARGET_DIR)/lib/firmware/aic8800 $(@D)/aic8800/*
	install -d -m 0755 $(TARGET_DIR)/lib/firmware/aic8800DC
	install -m 0644 -t $(TARGET_DIR)/lib/firmware/aic8800DC $(@D)/aic8800DC/*
endef

$(eval $(generic-package))
