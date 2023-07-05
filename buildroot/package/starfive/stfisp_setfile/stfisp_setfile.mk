################################################################################
#
# stfisp_setfile 
#
################################################################################

STFISP_SETFILE_LICENSE = GPL-2.0+

define HOST_STFISP_SETFILE_BUILD_CMDS
	cp package/starfive/stfisp_setfile/stfisp_setfile.c $(@D)/
        (cd $(@D); $(HOSTCC) -Wall -O2 stfisp_setfile.c -o stfisp_setfile; ./stfisp_setfile)
        install -m 0755 -D $(@D)/ov4689_stf_isp_fw.bin $(TARGET_DIR)/lib/firmware/stf_isp0_fw.bin
        install -m 0755 -D $(@D)/ov4689_stf_isp_fw_dump.bin $(TARGET_DIR)/lib/firmware/stf_isp0_fw_dump.bin
        install -m 0755 -D $(@D)/sc2235_stf_isp_fw.bin $(TARGET_DIR)/lib/firmware/stf_isp1_fw.bin
endef

$(eval $(host-generic-package))
