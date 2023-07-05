CROSS_CC_PREFIX = riscv64-buildroot-linux-gnu-
CC  = $(CROSS_CC_PREFIX)gcc
CXX = $(CROSS_CC_PREFIX)g++
LINKER = $(CC)
AR  = $(CROSS_CC_PREFIX)ar

# FLAGS=-I/data/code/fedoral_513/github/freelight-u-sdk_github_old/work/buildroot_initramfs/staging/usr/include/drm/ -ldrm
FLAGS = -I$(STAGING_DIR)/usr/include/drm/ -ldrm
FLAGS += -Wall -O2 -D_FILE_OFFSET_BITS=64

all:
	@echo STAGING_DIR=$(STAGING_DIR)
	$(CC) -o modeset-single-buffer modeset-single-buffer.c $(FLAGS)
	$(CC) -o modeset-double-buffer modeset-double-buffer.c $(FLAGS)
	$(CC) -o modeset-page-flip modeset-page-flip.c $(FLAGS)
	$(CC) -o modeset-plane-test modeset-plane-test.c $(FLAGS)
	$(CC) -o modeset-atomic-crtc modeset-atomic-crtc.c $(FLAGS)
	$(CC) -o modeset-atomic-plane modeset-atomic-plane.c $(FLAGS)
	$(CC) -o modeset-dumb modeset-dumb.c $(FLAGS)

clean:
	rm -rf modeset-single-buffer modeset-double-buffer modeset-page-flip \
	modeset-plane-test modeset-atomic-crtc modeset-dumb

# %.o: %.c
# 	$(CC) -fPIC -shared $(FLAGS) -Wall -Werror -c $< -o $@ -MD -MF $(@:.o=.dep)
