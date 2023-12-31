// SPDX-License-Identifier: GPL-2.0
/*
 * Copyright (C) 2021 StarFive Technology Co., Ltd.
 */
#ifndef __STF_V4L2_H__
#define __STF_V4L2_H__

#include "common.h"

// reference to enum v4l2_memory

typedef struct V4l2Param_t {
    char        *device_name;// = "/dev/video0";
    int         fd;
    IOMethod    io_mthd;  // IO_METHOD_MMAP
    enum v4l2_memory mem_type;

    // int         dmabuf_fd; // for IO_METHOD_DMABUF

    struct buffer *pBuffers;
    uint32_t  n_buffers;

    uint32_t image_size;
    uint32_t format;  // = V4L2_PIX_FMT_RGB565

    uint32_t width;     // = 1920;
    uint32_t height;    // = 1080;
    uint32_t fps; // = 30;

    int crop_flag;
    struct v4l2_rect   crop_info;

} V4l2Param_t;

extern int xioctl(int fd, int request, void* argp);

extern void sensor_image_size_info(V4l2Param_t *param);
extern void loadfw_start(char *filename, V4l2Param_t *param);

extern void stf_v4l2_open(V4l2Param_t *param, char *device_name);
extern void stf_v4l2_close(V4l2Param_t *param);
extern void stf_v4l2_init(V4l2Param_t *param);
extern void stf_v4l2_uninit(V4l2Param_t *param);
extern void sft_v4l2_prepare_capturing(V4l2Param_t *param,
                                       int *dmabufs, STF_DISP_TYPE disp_type);
extern void sft_v4l2_start_capturing(V4l2Param_t *param);
extern void stf_v4l2_stop_capturing(V4l2Param_t *param);

extern void stf_v4l2_queue_buffer(V4l2Param_t *param, int index);
extern int stf_v4l2_dequeue_buffer(V4l2Param_t *param, struct v4l2_buffer *buf);

#endif // __STF_V4L2_H__
