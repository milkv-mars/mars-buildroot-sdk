################################################################################
#
# pm
#
################################################################################
PM_LICENSE = GPL-2.0+

define PM_INSTALL_TARGET_CMDS
	install -m 0755 -D package/starfive/pm/S90cpufreq $(TARGET_DIR)/etc/init.d/
	install -m 0755 -D package/starfive/pm/S99hibernation $(TARGET_DIR)/etc/init.d/
endef

$(eval $(generic-package))
