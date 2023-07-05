################################################################################
#
# OMX_IL_TEST
#
################################################################################
SF_OMX_IL_TEST_VERSION:=1.0.0
SF_OMX_IL_TEST_SITE=$(TOPDIR)/../soft_3rdpart/omx-il
SF_OMX_IL_TEST_SITE_METHOD=local

SF_OMX_IL_TEST_DEPENDENCIES=sf-omx-il ffmpeg
define SF_OMX_IL_TEST_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) test
endef

define SF_OMX_IL_TEST_CLEAN_CMDS

endef

define SF_OMX_IL_TEST_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0777 $(@D)/video_dec_test $(TARGET_DIR)/root/video_dec_test
	$(INSTALL) -m 0777 $(@D)/video_enc_test $(TARGET_DIR)/root/video_enc_test
	$(INSTALL) -m 0777 $(@D)/mjpeg_dec_test $(TARGET_DIR)/root/mjpeg_dec_test
endef

define SF_OMX_IL_TEST_UNINSTALL_TARGET_CMDS

endef

$(eval $(generic-package))
