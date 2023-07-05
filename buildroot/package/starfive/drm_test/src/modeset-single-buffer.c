#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <time.h>
#include <unistd.h>
#include <xf86drm.h>
#include <xf86drmMode.h>
#include <signal.h>

#define DRM_MODULE_NAME "starfive"
#define DRM_BUSID NULL

struct buffer_object {
    uint32_t width;
    uint32_t height;
    uint32_t pitch;
    uint32_t handle;
    uint32_t size;
    uint8_t *vaddr;
    uint32_t fb_id;
};

struct buffer_object buf;

static int modeset_create_fb(int fd, struct buffer_object *bo)
{
    struct drm_mode_create_dumb create = {};
    struct drm_mode_map_dumb map = {};

    create.width = bo->width;
    create.height = bo->height;
    create.bpp = 32;
    drmIoctl(fd, DRM_IOCTL_MODE_CREATE_DUMB, &create);
    bo->pitch = create.pitch;
    bo->size = create.size;
    bo->handle = create.handle;
    // {24, 32}
    drmModeAddFB(fd, bo->width, bo->height, 32, 32, bo->pitch,
               bo->handle, &bo->fb_id);
    map.handle = create.handle;
    drmIoctl(fd, DRM_IOCTL_MODE_MAP_DUMB, &map);
    bo->vaddr = mmap(0, create.size, PROT_READ | PROT_WRITE,
            MAP_SHARED, fd, map.offset);
    //memset(bo->vaddr, 0xff, bo->size);
    int i =0;
    for (i=0;i<bo->size;i+=4) {
        bo->vaddr[i]   = 0x0F;
        bo->vaddr[i+1] = 0x00;
        bo->vaddr[i+2] = 0xF0;
        bo->vaddr[i+3] = 0x00;
    }
    return 0;
}

static void modeset_destroy_fb(int fd, struct buffer_object *bo)
{
    struct drm_mode_destroy_dumb destroy = {};

    drmModeRmFB(fd, bo->fb_id);
    munmap(bo->vaddr, bo->size);
    destroy.handle = bo->handle;
    drmIoctl(fd, DRM_IOCTL_MODE_DESTROY_DUMB, &destroy);
}

static int terminate = 0;
static void sigint_handler(int arg)
{
    terminate = 1;
}
int main(int argc, char **argv)
{
    int fd;
    drmModeConnector *conn;
    drmModeRes *res;
    uint32_t conn_id;
    uint32_t crtc_id;
    int ret = -1;
    int i =0;

    signal(SIGINT, sigint_handler);
    fd = drmOpen(DRM_MODULE_NAME, DRM_BUSID);
    res = drmModeGetResources(fd);
    crtc_id = res->crtcs[0];
    conn_id = res->connectors[0];
    conn = drmModeGetConnector(fd, conn_id);
    buf.width = conn->modes[0].hdisplay;
    buf.height = conn->modes[0].vdisplay;
    modeset_create_fb(fd, &buf);
    ret = drmModeSetCrtc(fd, crtc_id, buf.fb_id,
            0, 0, &conn_id, 1, &conn->modes[0]);
    if (ret) {
        fprintf(stderr, "cannot set CRTC for connector %u (%d): %m\n",
                crtc_id, errno);
    }

    getchar();

    uint32_t cnt = 10;
    uint8_t v1 = 0xFF;
    uint8_t v2 = 0x00;
    uint8_t v3 = 0x00;
    uint8_t v4 = 0x00;
    while (!terminate && cnt--) {
        for (i=0;i<buf.size;i+=4) {
#if 0
            if (cnt % 2) {
                buf.vaddr[i]   = 0x0F;
                buf.vaddr[i+1] = 0x00;
                buf.vaddr[i+2] = 0x00;
                buf.vaddr[i+3] = 0xFF;
            } else {
                buf.vaddr[i]   = 0x00;
                buf.vaddr[i+1] = 0xF0;
                buf.vaddr[i+2] = 0xFF;
                buf.vaddr[i+3] = 0x00;
            }
#else
            buf.vaddr[i]   = v1 - cnt * 20;
            buf.vaddr[i+1] = v2 + cnt * 20;
            buf.vaddr[i+2] = v3;
            buf.vaddr[i+3] = v4;
#endif
        }
        ret = drmModeSetCrtc(fd, crtc_id, buf.fb_id,
                0, 0, &conn_id, 1, &conn->modes[0]);
        if (ret) {
            fprintf(stderr, "cannot set CRTC for connector %u (%d): %m\n",
                    crtc_id, errno);
        }
        sleep(1);
    }

    modeset_destroy_fb(fd, &buf);
    drmModeFreeConnector(conn);
    drmModeFreeResources(res);
    close(fd);
    return 0;
}
