# SPDX-License-Identifier: GPL-2.0
#
# Copyright (C) 2022 StarFive Technology Co., Ltd.
#
# Description: HIFI4_SOF
#
HIFI4_SOF_VERSION:=1.0.0
HIFI4_SOF_SITE=$(TOPDIR)/../soft_3rdpart/HiFi4
HIFI4_SOF_SITE_METHOD=local

define HIFI4_SOF_BUILD_CMDS

endef

define HIFI4_SOF_CLEAN_CMDS

endef

define HIFI4_SOF_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/lib/firmware/sof
	$(INSTALL) -m 0755 $(@D)/sof-vf2.ri $(TARGET_DIR)/lib/firmware/sof/sof-vf2.ri
	$(INSTALL) -m 0755 $(@D)/sof-vf2-wm8960-aec.tplg $(TARGET_DIR)/lib/firmware/sof/sof-vf2-wm8960-aec.tplg
	$(INSTALL) -m 0755 $(@D)/sof-vf2-wm8960-mixer.tplg $(TARGET_DIR)/lib/firmware/sof/sof-vf2-wm8960-mixer.tplg
	$(INSTALL) -m 0755 $(@D)/sof-vf2-wm8960.tplg $(TARGET_DIR)/lib/firmware/sof/sof-vf2-wm8960.tplg
endef

define HIFI4_SOF_UNINSTALL_TARGET_CMDS

endef

$(eval $(generic-package))

