# xxxx-gcc -o dumb dumb.c `pkg-config --cflags --libs libdrm`
CROSS_CC_PREFIX = riscv64-buildroot-linux-gnu-
CC  = $(CROSS_CC_PREFIX)gcc
CXX = $(CROSS_CC_PREFIX)g++
LINKER = $(CC)
AR  = $(CROSS_CC_PREFIX)ar

# FLAGS=-I/data/code/fedoral_513/github/freelight-u-sdk_github_old/work/buildroot_initramfs/staging/usr/include/drm/ -ldrm
FLAGS = -I$(STAGING_DIR)/usr/include/drm/ -ldrm
FLAGS += -Wall -O2 -D_FILE_OFFSET_BITS=64

all:
	$(CC) -o modeset modeset.c $(FLAGS)
	$(CC) -o modeset-double-buffered modeset-double-buffered.c $(FLAGS)
	$(CC) -o modeset-vsync modeset-vsync.c $(FLAGS)
	$(CC) -o modeset-atomic modeset-atomic.c $(FLAGS)

clean:
	rm -rf modeset modeset-double-buffered modeset-vsync modeset-atomic
