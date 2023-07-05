################################################################################
#
# sf-gst-omx
#
################################################################################

SF_GST_OMX_VERSION = 1.18.5
SF_GST_OMX_SOURCE = gst-omx-$(GST_OMX_VERSION).tar.xz
SF_GST_OMX_SITE = https://gstreamer.freedesktop.org/src/gst-omx
SF_GST_OMX_INSTALL_STAGING = YES

SF_GST_OMX_LICENSE = LGPL-2.1
SF_GST_OMX_LICENSE_FILES = COPYING

SF_GST_OMX_CONF_OPTS = \
	-Dexamples=disabled \
	-Dtests=disabled \
	-Dtools=disabled \
	-Ddoc=disabled


SF_GST_OMX_VARIANT = stf
SF_GST_OMX_CONF_OPTS += -Dheader_path=$(STAGING_DIR)/usr/include/omx-il

SF_GST_OMX_CONF_OPTS += -Dtarget=$(SF_GST_OMX_VARIANT)

SF_GST_OMX_DEPENDENCIES = gstreamer1 gst1-plugins-base sf-omx-il

# adjust library paths to where buildroot installs them
define SF_GST_OMX_FIXUP_CONFIG_PATHS
	find $(@D)/config -name gstomx.conf | \
		xargs $(SED) 's|/usr/local|/usr|g' -e 's|/opt/vc|/usr|g'
endef

SF_GST_OMX_POST_PATCH_HOOKS += SF_GST_OMX_FIXUP_CONFIG_PATHS

$(eval $(meson-package))
