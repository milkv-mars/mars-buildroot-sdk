################################################################################
#
# OMX_IL
#
################################################################################


SF_OMX_IL_VERSION:=1.0.0
SF_OMX_IL_SITE=$(TOPDIR)/../soft_3rdpart/omx-il
SF_OMX_IL_SITE_METHOD=local
SF_OMX_IL_INSTALL_STAGING = YES

SF_OMX_IL_DEPENDENCIES=wave511 wave420l codaj12
define SF_OMX_IL_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define SF_OMX_IL_CLEAN_CMDS

endef

define SF_OMX_IL_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0644 $(@D)/libsf-omx-il.so $(TARGET_DIR)/usr/lib/libsf-omx-il.so
	ln -sf libsf-omx-il.so $(TARGET_DIR)/usr/lib/libOMX_Core.so
	$(INSTALL) -d $(@D)/include/khronos $(TARGET_DIR)/usr/include/omx-il
	$(INSTALL) -m 0644 $(@D)/include/khronos/* $(TARGET_DIR)/usr/include/omx-il
endef

define SF_OMX_IL_INSTALL_STAGING_CMDS
	$(INSTALL) -m 0644 $(@D)/libsf-omx-il.so $(STAGING_DIR)/usr/lib/libsf-omx-il.so
	ln -sf libsf-omx-il.so $(STAGING_DIR)/usr/lib/libOMX_Core.so
	$(INSTALL) -d $(@D)/include/khronos $(STAGING_DIR)/usr/include/omx-il
	$(INSTALL) -m 0644 $(@D)/include/khronos/* $(STAGING_DIR)/usr/include/omx-il
endef

define SF_OMX_IL_UNINSTALL_TARGET_CMDS

endef

$(eval $(generic-package))

