# SPDX-License-Identifier: GPL-2.0
#
# Copyright (C) 2022 StarFive Technology Co., Ltd.
#
# Description: E24_TEST
#
E24_TEST_VERSION:=1.0.0
E24_TEST_SITE=$(TOPDIR)/../soft_3rdpart/e24
E24_TEST_SITE_METHOD=local

define E24_TEST_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/client
endef

define E24_TEST_CLEAN_CMDS

endef

define E24_TEST_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/root/e24
	$(INSTALL) -m 0755 $(@D)/client/e24_share_mem $(TARGET_DIR)/root/e24/e24_share_mem
	$(INSTALL) -m 0755 $(@D)/e24_elf $(TARGET_DIR)/lib/firmware/e24_elf
endef

define E24_TEST_UNINSTALL_TARGET_CMDS

endef

$(eval $(generic-package))
