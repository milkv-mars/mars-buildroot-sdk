################################################################################
#
# drmtest
#
################################################################################
DRM_TEST_VERSION:=1.0.0
DRM_TEST_SITE=$(TOPDIR)/package/starfive/drm_test/src
DRM_TEST_SITE_METHOD=local

define DRM_TEST_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) -f $(@D)/Makefile
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/dvdhrm/ -f $(@D)/dvdhrm/Makefile
endef

define DRM_TEST_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/modeset-single-buffer $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/modeset-double-buffer $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/modeset-page-flip $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/modeset-plane-test $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/modeset-atomic-crtc $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/modeset-atomic-plane $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/modeset-dumb $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/dvdhrm/modeset $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/dvdhrm/modeset-double-buffered $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/dvdhrm/modeset-vsync $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/dvdhrm/modeset-atomic $(TARGET_DIR)/usr/bin/

endef

DRM_TEST_DEPENDENCIES = libdrm
$(eval $(generic-package))
