################################################################################
#
# libcamera-apps
#
################################################################################

LIBCAMERA_APPS_SITE = https://github.com/raspberrypi/libcamera-apps.git
LIBCAMERA_APPS_VERSION = 87f807f4eacf7d62021e3b4061348e64b2ecadc3
LIBCAMERA_APPS_SITE_METHOD = git
LIBCAMERA_APPS_INSTALL_STAGING = YES

LIBCAMERA_APPS_DEPENDENCIES = libcamera libexif tiff boost host-pkgconf

$(eval $(cmake-package))
