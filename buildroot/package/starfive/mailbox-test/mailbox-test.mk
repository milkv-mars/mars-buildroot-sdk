# SPDX-License-Identifier: GPL-2.0
#
# Copyright (C) 2022 StarFive Technology Co., Ltd.
#
# Description: MAILBOX_TEST
#
MAILBOX_TEST_VERSION:=1.0.0
MAILBOX_TEST_SITE=$(TOPDIR)/../soft_3rdpart/mailbox
MAILBOX_TEST_SITE_METHOD=local

define MAILBOX_TEST_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define MAILBOX_TEST_CLEAN_CMDS

endef

define MAILBOX_TEST_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/root/mailbox
	$(INSTALL) -m 0755 $(@D)/read_test $(TARGET_DIR)/root/mailbox/read_test
endef

define MAILBOX_TEST_UNINSTALL_TARGET_CMDS

endef

$(eval $(generic-package))
