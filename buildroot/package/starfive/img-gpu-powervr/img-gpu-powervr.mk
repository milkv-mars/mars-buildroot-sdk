# SPDX-License-Identifier: GPL-2.0
#
# Copyright (C) 2022 StarFive Technology Co., Ltd.
#
# Description: Add support for Imagination PowerVR GPU
#

IMG_GPU_POWERVR_VERSION:=1.17.6210866
IMG_GPU_POWERVR_SITE=$(TOPDIR)/../soft_3rdpart/IMG_GPU/out
IMG_GPU_POWERVR_SITE_METHOD=file
IMG_GPU_POWERVR_SOURCE=img-gpu-powervr-bin-$(IMG_GPU_POWERVR_VERSION).tar.gz

IMG_GPU_POWERVR_INSTALL_STAGING = YES

IMG_GPU_POWERVR_LICENSE = Strictly Confidential
IMG_GPU_POWERVR_REDISTRIBUTE = NO

IMG_GPU_POWERVR_PROVIDES = libgles libopencl
IMG_GPU_POWERVR_LIB_TARGET = $(call qstrip,$(BR2_PACKAGE_IMG_GPU_POWERVR_OUTPUT))

ifeq ($(IMG_GPU_POWERVR_LIB_TARGET),x11)
IMG_GPU_POWERVR_DEPENDENCIES += xlib_libXdamage xlib_libXext xlib_libXfixes
endif

ifneq ($(IMG_GPU_POWERVR_LIB_TARGET)$(BR2_riscv),fby)
IMG_GPU_POWERVR_DEPENDENCIES += libdrm
endif

ifeq ($(IMG_GPU_POWERVR_LIB_TARGET),wayland)
IMG_GPU_POWERVR_DEPENDENCIES += wayland
endif

define IMG_GPU_POWERVR_INSTALL_STAGING_CMDS
	cp -rdpf $(@D)/staging/* $(STAGING_DIR)/
endef

define IMG_GPU_POWERVR_INSTALL_TARGET_CMDS
	cp -rdpf $(@D)/target/* $(TARGET_DIR)/
endef

$(eval $(generic-package))
