################################################################################
#
# WAVE420L
#
################################################################################
WAVE420L_VERSION:=1.0.0
WAVE420L_SITE=$(TOPDIR)/../soft_3rdpart/wave420l/code
WAVE420L_SITE_METHOD=local
WAVE420L_INSTALL_STAGING = YES

export KERNELDIR=$(TOPDIR)/../work/linux

define WAVE420L_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) -f $(@D)/WaveEncoder_buildroot.mak
endef

define WAVE420L_CLEAN_CMDS

endef

define WAVE420L_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/libsfenc.so $(TARGET_DIR)/usr/lib/libsfenc.so
	$(INSTALL) -D -m 0644 $(WAVE420L_SITE)/../firmware/monet.bin $(TARGET_DIR)/lib/firmware/monet.bin
	$(INSTALL) -D -m 0644 $(@D)/cfg/encoder_defconfig.cfg $(TARGET_DIR)/lib/firmware/encoder_defconfig.cfg
endef


define WAVE420L_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/include/wave420l
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/vpuconfig.h                                           $(STAGING_DIR)/usr/include/wave420l/vpuapi/vpuconfig.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/product.h                                             $(STAGING_DIR)/usr/include/wave420l/vpuapi/product.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/vputypes.h                                            $(STAGING_DIR)/usr/include/wave420l/vpuapi/vputypes.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/vpuapi.h                                              $(STAGING_DIR)/usr/include/wave420l/vpuapi/vpuapi.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/vpuapifunc.h                                          $(STAGING_DIR)/usr/include/wave420l/vpuapi/vpuapifunc.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/coda9/coda9_vpuconfig.h                               $(STAGING_DIR)/usr/include/wave420l/vpuapi/coda9/coda9_vpuconfig.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/coda9/coda9.h                                         $(STAGING_DIR)/usr/include/wave420l/vpuapi/coda9/coda9.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/coda9/coda9_regdefine.h                               $(STAGING_DIR)/usr/include/wave420l/vpuapi/coda9/coda9_regdefine.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/wave/coda7q/coda7q_regdefine.h                        $(STAGING_DIR)/usr/include/wave420l/vpuapi/wave/coda7q/coda7q_regdefine.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/wave/coda7q/coda7q.h                                  $(STAGING_DIR)/usr/include/wave420l/vpuapi/wave/coda7q/coda7q.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/wave/wave4/wave4.h                                    $(STAGING_DIR)/usr/include/wave420l/vpuapi/wave/wave4/wave4.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/wave/wave4/wave4_regdefine.h                          $(STAGING_DIR)/usr/include/wave420l/vpuapi/wave/wave4/wave4_regdefine.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/wave/wave5/wave5.h                                    $(STAGING_DIR)/usr/include/wave420l/vpuapi/wave/wave5/wave5.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/wave/wave5/wave5_regdefine.h                          $(STAGING_DIR)/usr/include/wave420l/vpuapi/wave/wave5/wave5_regdefine.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/wave/common/common.h                                  $(STAGING_DIR)/usr/include/wave420l/vpuapi/wave/common/common.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/wave/common/common_vpuconfig.h                        $(STAGING_DIR)/usr/include/wave420l/vpuapi/wave/common/common_vpuconfig.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/wave/common/common_regdefine.h                        $(STAGING_DIR)/usr/include/wave420l/vpuapi/wave/common/common_regdefine.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/vpuerror.h                                            $(STAGING_DIR)/usr/include/wave420l/vpuapi/vpuerror.h
	$(INSTALL) -D -m 0644 $(@D)/sample/helper/misc/pbu.h                                     $(STAGING_DIR)/usr/include/wave420l/sample/helper/misc/pbu.h
	$(INSTALL) -D -m 0644 $(@D)/sample/helper/misc/skip.h                                    $(STAGING_DIR)/usr/include/wave420l/sample/helper/misc/skip.h
	$(INSTALL) -D -m 0644 $(@D)/sample/helper/misc/getopt.h                                  $(STAGING_DIR)/usr/include/wave420l/sample/helper/misc/getopt.h
	$(INSTALL) -D -m 0644 $(@D)/sample/helper/misc/header_struct.h                           $(STAGING_DIR)/usr/include/wave420l/sample/helper/misc/header_struct.h
	$(INSTALL) -D -m 0644 $(@D)/sample/helper/misc/debug.h                                   $(STAGING_DIR)/usr/include/wave420l/sample/helper/misc/debug.h
	$(INSTALL) -D -m 0644 $(@D)/sample/helper/msvc/inttypes.h                                $(STAGING_DIR)/usr/include/wave420l/sample/helper/msvc/inttypes.h
	$(INSTALL) -D -m 0644 $(@D)/sample/helper/msvc/stdint.h                                  $(STAGING_DIR)/usr/include/wave420l/sample/helper/msvc/stdint.h
	$(INSTALL) -D -m 0644 $(@D)/sample/helper/main_helper.h                                  $(STAGING_DIR)/usr/include/wave420l/sample/helper/main_helper.h
	$(INSTALL) -D -m 0644 $(@D)/vdi/mm.h                                                     $(STAGING_DIR)/usr/include/wave420l/vdi/mm.h
	$(INSTALL) -D -m 0644 $(@D)/vdi/linux/driver/vmm.h                                       $(STAGING_DIR)/usr/include/wave420l/vdi/linux/driver/vmm.h
	$(INSTALL) -D -m 0644 $(@D)/vdi/linux/driver/vpu.h                                       $(STAGING_DIR)/usr/include/wave420l/vdi/linux/driver/vpu.h
	$(INSTALL) -D -m 0644 $(@D)/vdi/vdi.h                                                    $(STAGING_DIR)/usr/include/wave420l/vdi/vdi.h
	$(INSTALL) -D -m 0644 $(@D)/vdi/vdi_osal.h                                               $(STAGING_DIR)/usr/include/wave420l/vdi/vdi_osal.h
	$(INSTALL) -D -m 0644 $(@D)/config.h                                                     $(STAGING_DIR)/usr/include/wave420l/config.h
	$(INSTALL) -D -m 0644 $(@D)/libsfenc.so 						 $(STAGING_DIR)/usr/lib/libsfenc.so

endef

define WAVE420L_UNINSTALL_TARGET_CMDS

endef

WAVE420L_WORK_DIR := $(TARGET_DIR)/../build/wave420l-$(WAVE420L_VERSION)
wave420ldriver:
ifneq ($(wildcard $(WAVE420L_WORK_DIR)/WaveEncDriver_buildroot.mak),)
	$(TARGET_MAKE_ENV) INSTALL_MOD_PATH=$(INSTALL_MOD_PATH) \
		$(MAKE) -C $(WAVE420L_WORK_DIR) -f $(WAVE420L_WORK_DIR)/WaveEncDriver_buildroot.mak
endif

$(eval $(generic-package))
