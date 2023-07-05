################################################################################
#
# wave511
#
################################################################################
WAVE511_SITE=$(TOPDIR)/../soft_3rdpart/wave511/code
WAVE511_SITE_METHOD=local
WAVE511_INSTALL_STAGING = YES

export KERNELDIR=$(TOPDIR)/../work/linux

define WAVE511_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) -f $(@D)/WaveDecode_buildroot.mak
endef

define WAVE511_CLEAN_CMDS

endef

define WAVE511_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/libsfdec.so $(TARGET_DIR)/usr/lib/libsfdec.so
	$(INSTALL) -D -m 0644 $(WAVE511_SITE)/../firmware/chagall.bin $(TARGET_DIR)/lib/firmware/chagall.bin
endef

define WAVE511_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/include/wave511
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/component_list_decoder.h                           $(STAGING_DIR)/usr/include/wave511/sample_v2/component_list_decoder.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/component_list_encoder.h                           $(STAGING_DIR)/usr/include/wave511/sample_v2/component_list_encoder.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/helper/misc/pbu.h                                  $(STAGING_DIR)/usr/include/wave511/sample_v2/helper/misc/pbu.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/helper/misc/header_struct.h                        $(STAGING_DIR)/usr/include/wave511/sample_v2/helper/misc/header_struct.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/helper/misc/json_output.h                          $(STAGING_DIR)/usr/include/wave511/sample_v2/helper/misc/json_output.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/helper/misc/debug.h                                $(STAGING_DIR)/usr/include/wave511/sample_v2/helper/misc/debug.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/helper/misc/bw_monitor.h                           $(STAGING_DIR)/usr/include/wave511/sample_v2/helper/misc/bw_monitor.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/helper/main_helper.h                               $(STAGING_DIR)/usr/include/wave511/sample_v2/helper/main_helper.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/component/component.h                              $(STAGING_DIR)/usr/include/wave511/sample_v2/component/component.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/component/cnm_app_internal.h                       $(STAGING_DIR)/usr/include/wave511/sample_v2/component/cnm_app_internal.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/component/cnm_app.h                                $(STAGING_DIR)/usr/include/wave511/sample_v2/component/cnm_app.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/component/component_list.h                         $(STAGING_DIR)/usr/include/wave511/sample_v2/component/component_list.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/component_list_all.h                               $(STAGING_DIR)/usr/include/wave511/sample_v2/component_list_all.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/component_encoder/encoder_listener.h               $(STAGING_DIR)/usr/include/wave511/sample_v2/component_encoder/encoder_listener.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/component_decoder/decoder_listener.h               $(STAGING_DIR)/usr/include/wave511/sample_v2/component_decoder/decoder_listener.h
	$(INSTALL) -D -m 0644 $(@D)/vdi/vdi_osal.h                                               $(STAGING_DIR)/usr/include/wave511/vdi/vdi_osal.h
	$(INSTALL) -D -m 0644 $(@D)/vdi/linux/driver/vmm.h                                       $(STAGING_DIR)/usr/include/wave511/vdi/linux/driver/vmm.h
	$(INSTALL) -D -m 0644 $(@D)/vdi/linux/driver/vpu.h                                       $(STAGING_DIR)/usr/include/wave511/vdi/linux/driver/vpu.h
	$(INSTALL) -D -m 0644 $(@D)/vdi/mm.h                                                     $(STAGING_DIR)/usr/include/wave511/vdi/mm.h
	$(INSTALL) -D -m 0644 $(@D)/vdi/vdi.h                                                    $(STAGING_DIR)/usr/include/wave511/vdi/vdi.h
	$(INSTALL) -D -m 0644 $(@D)/config.h                                                     $(STAGING_DIR)/usr/include/wave511/config.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/product.h                                             $(STAGING_DIR)/usr/include/wave511/vpuapi/product.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/coda9/coda9_vpuconfig.h                               $(STAGING_DIR)/usr/include/wave511/vpuapi/coda9/coda9_vpuconfig.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/coda9/coda9.h                                         $(STAGING_DIR)/usr/include/wave511/vpuapi/coda9/coda9.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/coda9/coda9_regdefine.h                               $(STAGING_DIR)/usr/include/wave511/vpuapi/coda9/coda9_regdefine.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/vpuapi.h                                              $(STAGING_DIR)/usr/include/wave511/vpuapi/vpuapi.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/vpuconfig.h                                           $(STAGING_DIR)/usr/include/wave511/vpuapi/vpuconfig.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/wave/wave5.h                                          $(STAGING_DIR)/usr/include/wave511/vpuapi/wave/wave5.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/wave/wave5_regdefine.h                                $(STAGING_DIR)/usr/include/wave511/vpuapi/wave/wave5_regdefine.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/vpuerror.h                                            $(STAGING_DIR)/usr/include/wave511/vpuapi/vpuerror.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/vputypes.h                                            $(STAGING_DIR)/usr/include/wave511/vpuapi/vputypes.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/vpuapifunc.h                                          $(STAGING_DIR)/usr/include/wave511/vpuapi/vpuapifunc.h
	$(INSTALL) -D -m 0644 $(@D)/libsfdec.so 						 $(STAGING_DIR)/usr/lib/libsfdec.so
endef

define WAVE511_UNINSTALL_TARGET_CMDS

endef

wave511_WORK_DIR := $(TARGET_DIR)/../build/wave511
wave511driver:
ifneq ($(wildcard $(wave511_WORK_DIR)/WaveDecDriver_buildroot.mak),)
	$(TARGET_MAKE_ENV) INSTALL_MOD_PATH=$(INSTALL_MOD_PATH) \
		$(MAKE) -C $(wave511_WORK_DIR) -f $(wave511_WORK_DIR)/WaveDecDriver_buildroot.mak
endif

$(eval $(generic-package))
