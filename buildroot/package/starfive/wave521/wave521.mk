################################################################################
#
# wave521
#
################################################################################

WAVE521_VERSION:=1.0.0
WAVE521_SITE=$(TOPDIR)/../soft_3rdpart/wave521/code
WAVE521_SITE_METHOD=local
WAVE521_INSTALL_STAGING = YES

export KERNELDIR=$(TOPDIR)/../work/linux

define WAVE521_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) -f $(@D)/WaveEncoder_buildroot.mak
	# $(TARGET_MAKE_ENV) $(MAKE) -C $(@D) -f $(@D)/WaveEncDriver_buildroot.mak
endef

define WAVE521_CLEAN_CMDS

endef

define WAVE521_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0777 $(@D)/vdi/linux/driver/load.sh $(TARGET_DIR)/root/wave521/venc_load.sh
	$(INSTALL) -D -m 0777 $(@D)/vdi/linux/driver/unload.sh $(TARGET_DIR)/root/wave521/venc_unload.sh
	$(INSTALL) -D -m 0644 $(@D)/libsfenc.so $(TARGET_DIR)/usr/lib/libsfenc.so
	$(INSTALL) -D -m 0644 $(@D)/cfg/encoder_defconfig.cfg $(TARGET_DIR)/lib/firmware/encoder_defconfig.cfg
	# $(INSTALL) -D -m 0644 $(@D)/vdi/linux/driver/venc.ko $(TARGET_DIR)/root/wave521/venc.ko
	# $(INSTALL) -D -m 0644 $(WAVE521_SITE)/../firmware/chagall.bin $(TARGET_DIR)/root/wave521/chagall.bin
endef


define WAVE521_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/include/wave521
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/component_list_decoder.h                           $(STAGING_DIR)/usr/include/wave521/sample_v2/component_list_decoder.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/component_list_encoder.h                           $(STAGING_DIR)/usr/include/wave521/sample_v2/component_list_encoder.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/helper/misc/pbu.h                                  $(STAGING_DIR)/usr/include/wave521/sample_v2/helper/misc/pbu.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/helper/misc/header_struct.h                        $(STAGING_DIR)/usr/include/wave521/sample_v2/helper/misc/header_struct.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/helper/misc/json_output.h                          $(STAGING_DIR)/usr/include/wave521/sample_v2/helper/misc/json_output.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/helper/misc/debug.h                                $(STAGING_DIR)/usr/include/wave521/sample_v2/helper/misc/debug.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/helper/misc/bw_monitor.h                           $(STAGING_DIR)/usr/include/wave521/sample_v2/helper/misc/bw_monitor.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/helper/main_helper.h                               $(STAGING_DIR)/usr/include/wave521/sample_v2/helper/main_helper.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/component/component.h                              $(STAGING_DIR)/usr/include/wave521/sample_v2/component/component.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/component/cnm_app_internal.h                       $(STAGING_DIR)/usr/include/wave521/sample_v2/component/cnm_app_internal.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/component/cnm_app.h                                $(STAGING_DIR)/usr/include/wave521/sample_v2/component/cnm_app.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/component/component_list.h                         $(STAGING_DIR)/usr/include/wave521/sample_v2/component/component_list.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/component_list_all.h                               $(STAGING_DIR)/usr/include/wave521/sample_v2/component_list_all.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/component_encoder/encoder_listener.h               $(STAGING_DIR)/usr/include/wave521/sample_v2/component_encoder/encoder_listener.h
	$(INSTALL) -D -m 0644 $(@D)/sample_v2/component_decoder/decoder_listener.h               $(STAGING_DIR)/usr/include/wave521/sample_v2/component_decoder/decoder_listener.h
	$(INSTALL) -D -m 0644 $(@D)/vdi/vdi_osal.h                                               $(STAGING_DIR)/usr/include/wave521/vdi/vdi_osal.h
	$(INSTALL) -D -m 0644 $(@D)/vdi/linux/driver/vmm.h                                       $(STAGING_DIR)/usr/include/wave521/vdi/linux/driver/vmm.h
	$(INSTALL) -D -m 0644 $(@D)/vdi/linux/driver/vpu.h                                       $(STAGING_DIR)/usr/include/wave521/vdi/linux/driver/vpu.h
	$(INSTALL) -D -m 0644 $(@D)/vdi/mm.h                                                     $(STAGING_DIR)/usr/include/wave521/vdi/mm.h
	$(INSTALL) -D -m 0644 $(@D)/vdi/vdi.h                                                    $(STAGING_DIR)/usr/include/wave521/vdi/vdi.h
	$(INSTALL) -D -m 0644 $(@D)/config.h                                                     $(STAGING_DIR)/usr/include/wave521/config.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/product.h                                             $(STAGING_DIR)/usr/include/wave521/vpuapi/product.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/coda9/coda9_vpuconfig.h                               $(STAGING_DIR)/usr/include/wave521/vpuapi/coda9/coda9_vpuconfig.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/coda9/coda9.h                                         $(STAGING_DIR)/usr/include/wave521/vpuapi/coda9/coda9.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/coda9/coda9_regdefine.h                               $(STAGING_DIR)/usr/include/wave521/vpuapi/coda9/coda9_regdefine.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/vpuapi.h                                              $(STAGING_DIR)/usr/include/wave521/vpuapi/vpuapi.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/vpuconfig.h                                           $(STAGING_DIR)/usr/include/wave521/vpuapi/vpuconfig.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/wave/wave5.h                                          $(STAGING_DIR)/usr/include/wave521/vpuapi/wave/wave5.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/wave/wave5_regdefine.h                                $(STAGING_DIR)/usr/include/wave521/vpuapi/wave/wave5_regdefine.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/vpuerror.h                                            $(STAGING_DIR)/usr/include/wave521/vpuapi/vpuerror.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/vputypes.h                                            $(STAGING_DIR)/usr/include/wave521/vpuapi/vputypes.h
	$(INSTALL) -D -m 0644 $(@D)/vpuapi/vpuapifunc.h                                          $(STAGING_DIR)/usr/include/wave521/vpuapi/vpuapifunc.h
endef

define WAVE521_UNINSTALL_TARGET_CMDS
	rm -rf $(TARGET_DIR)/root/venc.ko
	rm -rf $(TARGET_DIR)/root/venc_load.sh
	rm -rf $(TARGET_DIR)/root/venc_unload.sh
endef

wave521_WORK_DIR := $(TARGET_DIR)/../build/wave521-$(WAVE521_VERSION)
wave521driver:
ifneq ($(wildcard $(wave521_WORK_DIR)/WaveEncDriver_buildroot.mak),)
	$(TARGET_MAKE_ENV) $(MAKE) -C $(wave521_WORK_DIR) -f $(wave521_WORK_DIR)/WaveEncDriver_buildroot.mak
	$(INSTALL) -D -m 0644 $(wave521_WORK_DIR)/vdi/linux/driver/venc.ko $(TARGET_DIR)/root/wave521/venc.ko
endif

$(eval $(generic-package))
