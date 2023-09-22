// SPDX-License-Identifier: GPL-2.0
/*
 * Copyright (C) 2021 StarFive Technology Co., Ltd.
 */
#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <getopt.h>
#include <fcntl.h>
#include "libavformat/avformat.h"
#include "libavcodec/avcodec.h"
#include <libv4l2.h>
#include <poll.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/ioctl.h>
#include <sys/msg.h>
#include <sys/mman.h>

#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <sys/stat.h>
#include <time.h>
#include <asm/types.h>
#include <linux/videodev2.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <malloc.h>

#define MAX_BUF_CNT  10
#define BUFCOUNT     5
#define MAX_PLANES   3
#define MAX_VIDEO_CNT 24
#define VPU_DEC_DRV_NAME "wave5-dec"

#define CLEAR(x)  memset (&(x), 0, sizeof (x))
#define PCLEAR(x) memset ((x), 0, sizeof (*x))

//typedef enum __bool { false = 0, true = 1, } bool;

typedef struct v4l2_buffer v4l2_buffer;

typedef enum IOMethod {
    IO_METHOD_MMAP,
    IO_METHOD_USERPTR,
    IO_METHOD_DMABUF,
    IO_METHOD_READ
} IOMethod;

typedef struct buffer {
    void*   start[MAX_PLANES];
    size_t  length[MAX_PLANES];
    int     dmabuf_fd[MAX_PLANES];
    int     index;
}buffer;

typedef struct DecodeTestContext
{
    int fd;
    IOMethod io_mthd;  // IO_METHOD_MMAP
    enum v4l2_memory mem_type;
    char sOutputFilePath[256];
    char sInputFilePath[256];
    char sOutputFormat[64];
    uint32_t  ScaleWidth;
    uint32_t  ScaleHeight;
    uint32_t  StreamFormat;
    uint32_t  format;
    uint32_t  n_inputbuffers;
    uint32_t  n_outputbuffers;
    uint32_t  inputBufSize;
    uint32_t  outputBufSize;
    uint32_t  width;     // = 1920;
    uint32_t  height;    // = 1080;
    v4l2_buffer InputV4L2BufArray[MAX_BUF_CNT];
    v4l2_buffer OutputV4L2BufArray[MAX_BUF_CNT];
    buffer InputBufArray[MAX_BUF_CNT];
    buffer OutputBufArray[MAX_BUF_CNT];
    AVFormatContext *avContext;
    int32_t  video_stream_idx;
} DecodeTestContext;
DecodeTestContext *decodeTestContext;
struct v4l2_plane *gInput_v4l2_plane;
struct v4l2_plane *gOutput_v4l2_plane;

static char devPath[16];

static int32_t FillInputBuffer(DecodeTestContext *decodeTestContext, struct v4l2_buffer *buf, int32_t pIndex);

static bool justQuit = false;
static bool bitsteamEnd = false;
static bool testFPS =false;
static FILE *fb = NULL;

static int xioctl(int fd, int request, void* argp)
{
    int r;

    // TODO: the orign is v4l2_ioctl()
    do r = ioctl(fd, request, argp);
    while (-1 == r && EINTR == errno);

    return r;
}

static void convert_v4l2_mem_type(int iomthd, enum v4l2_memory *mem_type)
{
    if (iomthd < IO_METHOD_MMAP || iomthd > IO_METHOD_READ) {
        printf("iomthd %d out of range\n", iomthd);
        return;
    }

    switch (iomthd) {
    case IO_METHOD_MMAP:
        *mem_type = V4L2_MEMORY_MMAP;
        break;
    case IO_METHOD_USERPTR:
        *mem_type = V4L2_MEMORY_USERPTR;
        break;
    case IO_METHOD_DMABUF:
        *mem_type = V4L2_MEMORY_DMABUF;
        break;
    case IO_METHOD_READ:
        *mem_type = 0;  // not use memory machanism
        break;
    default:
        *mem_type = 0;  // not use memory machanism
        break;
    }
}

static void help()
{
    printf("v4l2_dec_test - v4l2 hardware decode unit test case\r\n\r\n");
    printf("Usage:\r\n\r\n");
    printf("./v4l2_dec_test -i <input file>      input file\r\n");
    printf("                 -o <output file>     output file\r\n");
    printf("                 -f <format>          i420/nv12/nv21\r\n");
    printf("                 --scaleW=<width>     (optional) scale width down. ceil32(width/8) <= scaledW <= width\r\n");
    printf("                 --scaleH=<heitht>    (optional) scale height down, ceil8(height/8) <= scaledH <= height\r\n\r\n");
    printf("./v4l2_dec_test --help: show this message\r\n");
}


static void signal_handle(int sig)
{
    printf("[%s,%d]: receive sig=%d \n", __FUNCTION__, __LINE__, sig);
    justQuit = true;
}

static int32_t FillInputBuffer(DecodeTestContext *decodeTestContext, struct v4l2_buffer *buf, int32_t pIndex)
{
    AVFormatContext *avFormatContext = decodeTestContext->avContext;
    AVPacket *avpacket;
    int32_t error = 0;
    avpacket = av_packet_alloc();
    while (error >= 0)
    {
        error = av_read_frame(avFormatContext, avpacket);
        if (avpacket->stream_index == decodeTestContext->video_stream_idx)
            break;
        printf("get audio frame\n");
    }

    if (error < 0)
    {
        if (error == AVERROR_EOF || avFormatContext->pb->eof_reached)
        {
            printf("get stream eos\n");
            buf->m.planes[pIndex].bytesused = 0;
            return 0;
        }
        else
        {
            printf("%s:%d failed to av_read_frame, error: %s\n",
                    __FUNCTION__, __LINE__, av_err2str(error));
            buf->m.planes[pIndex].bytesused = 0;
            return 0;
        }
    }
    if (decodeTestContext->InputBufArray[buf->index].length[pIndex] >= avpacket->size){
        memcpy(decodeTestContext->InputBufArray[buf->index].start[pIndex], avpacket->data, avpacket->size);
        buf->m.planes[pIndex].bytesused = avpacket->size;
        return avpacket->size;
    }else{
        printf("buff size too small %ld<%d\n",decodeTestContext->InputBufArray[buf->index].length[pIndex], avpacket->size);
        buf->m.planes[pIndex].bytesused = 0;
        return 0;
    }
}

static void mainloop()
{
    int r, i, j, fps, dec_cnt = 0;
    uint64_t diff_time;
    struct pollfd* fds = NULL;
    struct v4l2_event event;
    struct v4l2_format fmt;
    struct v4l2_requestbuffers req;
    struct v4l2_buffer buf;
    struct v4l2_plane planes[MAX_PLANES];
    struct timeval tv_old, tv;
    enum v4l2_buf_type type;

    fds = (struct pollfd*)malloc(sizeof(struct pollfd));
    PCLEAR(fds);
    fds->fd = decodeTestContext->fd;
    fds->events = POLLIN | POLLOUT | POLLPRI;

    while (true){
        if (justQuit)
            break;
        r = poll(fds, 1, 3000);
        if (-1 == r) {
            if (EINTR == errno) {
                continue;
            }
           printf("error in poll %d", errno);
            break;
        }
        if (0 == r) {
            printf("poll timeout, %d\n", errno);
            break;
        }

        if (fds->revents & POLLPRI) {
            if (-1 == xioctl(decodeTestContext->fd, VIDIOC_DQEVENT, &event)) {
                printf("get event fail\n");
                break;
            }
            printf("get event %d\n",event.type);
            if (event.type == V4L2_EVENT_SOURCE_CHANGE &&
                    event.u.src_change.changes == V4L2_EVENT_SRC_CH_RESOLUTION){

                printf("request dist buffer\n");
                CLEAR(req);
                req.count = BUFCOUNT;
                req.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
                req.memory = V4L2_MEMORY_MMAP;
                if (-1 == xioctl(decodeTestContext->fd, VIDIOC_REQBUFS, &req)) {
                    printf("%s request buffer fail %d\n", devPath, errno);
                    break;
                }
                decodeTestContext->n_outputbuffers = req.count;

                printf("get dist q format\n");
                CLEAR(fmt);
                fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
                fmt.fmt.pix_mp.field = V4L2_FIELD_NONE;
                if (-1 == ioctl(decodeTestContext->fd, VIDIOC_G_FMT, &fmt)) {
                    printf("VIDIOC_G_FMT fail\n");
                    break;
                }
                printf("VIDIOC_G_FMT: type=%d, Fourcc format=%c%c%c%c\n",
                        fmt.type, fmt.fmt.pix_mp.pixelformat & 0xff,
                        (fmt.fmt.pix_mp.pixelformat >> 8) &0xff,
                        (fmt.fmt.pix_mp.pixelformat >> 16) &0xff,
                        (fmt.fmt.pix_mp.pixelformat >> 24) &0xff);
                printf(" \t width=%d, height=%d, field=%d, bytesperline=%d, sizeimage=%d\n",
                        fmt.fmt.pix_mp.width, fmt.fmt.pix_mp.height, fmt.fmt.pix_mp.field,
                        fmt.fmt.pix_mp.plane_fmt[0].bytesperline, fmt.fmt.pix_mp.plane_fmt[0].sizeimage);

                if (fmt.fmt.pix_mp.pixelformat != decodeTestContext->format) {
                    printf("v4l2 didn't accept format %d. Can't proceed.\n", decodeTestContext->format);
                    break;
                }

                /* Note VIDIOC_S_FMT may change width and height. */
                if (decodeTestContext->width != fmt.fmt.pix_mp.width) {
                    decodeTestContext->width = fmt.fmt.pix_mp.width;
                    printf("Correct image width set to %i by device %s.\n", decodeTestContext->width, devPath);
                }

                if (decodeTestContext->height != fmt.fmt.pix_mp.height) {
                    decodeTestContext->height = fmt.fmt.pix_mp.height;
                    printf("Correct image height set to %i by device %s.\n", decodeTestContext->height, devPath);
                }

                for (i = 0; i < decodeTestContext->n_outputbuffers; i++) {
                    decodeTestContext->OutputV4L2BufArray[i].type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
                    decodeTestContext->OutputV4L2BufArray[i].memory = V4L2_MEMORY_MMAP;
                    decodeTestContext->OutputV4L2BufArray[i].index = i;
                    // VIDIOC_PREPARE_BUF
                    if (-1 == xioctl(decodeTestContext->fd, VIDIOC_PREPARE_BUF, &decodeTestContext->OutputV4L2BufArray[i]))
                    {
                        printf("VIDIOC_PREPARE_BUF fail\n");
                        break;
                    }
                    // VIDIOC_PREPARE_BUF end
                    if (-1 == xioctl(decodeTestContext->fd, VIDIOC_QUERYBUF, &decodeTestContext->OutputV4L2BufArray[i]))
                    {
                        printf("VIDIOC_QUERYBUF fail\n");
                        break;
                    }
                    printf("src buffer %d type %d method %d n_plane %d\n",i ,decodeTestContext->OutputV4L2BufArray[i].type,
                                decodeTestContext->OutputV4L2BufArray[i].memory, decodeTestContext->OutputV4L2BufArray[i].length);

                    for (j = 0; j < decodeTestContext->OutputV4L2BufArray[i].length; j++){
                        printf("    plane %d length 0x%x offset 0x%x\n", j,
                                decodeTestContext->OutputV4L2BufArray[i].m.planes[j].length, decodeTestContext->OutputV4L2BufArray[i].m.planes[j].m.mem_offset);

                        decodeTestContext->OutputBufArray[i].length[j] = decodeTestContext->OutputV4L2BufArray[i].m.planes[j].length;
                        decodeTestContext->OutputBufArray[i].start[j] = v4l2_mmap(NULL, /* start anywhere */
                                decodeTestContext->OutputV4L2BufArray[i].m.planes[j].length, PROT_READ | PROT_WRITE, /* required */
                                MAP_SHARED, /* recommended */
                                decodeTestContext->fd, decodeTestContext->OutputV4L2BufArray[i].m.planes[j].m.mem_offset);
                        if (MAP_FAILED == decodeTestContext->OutputBufArray[i].start[j]) {
                            printf("map fail %d err %d\n",i, errno);
                            break;
                        }
                    }
                }

                for (i = 0; i < decodeTestContext->n_outputbuffers; i++){
                    if (-1 == xioctl(decodeTestContext->fd, VIDIOC_QBUF, &decodeTestContext->OutputV4L2BufArray[i])) {
                        printf("VIDIOC_QBUF fail\n");
                        break;
                    }
                }

                printf("start dst stream\n");
                type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
                if (-1 == xioctl(decodeTestContext->fd, VIDIOC_STREAMON, &type)) {
                    printf("start dst stream fail\n");
                    break;
                }
            }else if (event.type == V4L2_EVENT_EOS){
                printf("finished, end\n");
                break;
            }
        }

        if (fds->revents & POLLIN) {
            CLEAR(buf);
            memset(planes, 0, sizeof(struct v4l2_plane) * MAX_PLANES);
            buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
            buf.memory = decodeTestContext->mem_type;
            buf.length = MAX_PLANES;
            buf.m.planes = planes;
            if (-1 == xioctl(decodeTestContext->fd, VIDIOC_DQBUF, &buf)) {
                switch (errno) {
                case EAGAIN:
                    continue;
                case EIO:
                    /* Could ignore EIO, see spec. */
                    /* fall through */
                default:
                    printf("pollin VIDIOC_DQBUF fail\n");
                }
            }

            if (buf.index > decodeTestContext->n_outputbuffers)
            {
                printf("error capture index %d\n",buf.index);
                break;
            }

            if (testFPS)
            {
                if (dec_cnt == 0) {
                    gettimeofday(&tv_old, NULL);
                }
                if (dec_cnt++ >= 50) {
                    gettimeofday(&tv, NULL);
                    diff_time = (tv.tv_sec - tv_old.tv_sec) * 1000 + (tv.tv_usec - tv_old.tv_usec) / 1000;
                    fps = 1000  * (dec_cnt - 1) / diff_time;
                    dec_cnt = 0;
                    printf("Decoding fps: %d \r\n", fps);
                }
            }
            else
            {
                for (i = 0; i < buf.length; i++){
                    fwrite(decodeTestContext->OutputBufArray[buf.index].start[i], 1, buf.m.planes[i].bytesused, fb);
                }
            }
 
            if (-1 == xioctl(decodeTestContext->fd, VIDIOC_QBUF, &buf)) {
                printf("VIDIOC_QBUF fail\n");
                break;
            }

            if (buf.flags & V4L2_BUF_FLAG_LAST){
                printf("get last buffer\n");
                justQuit = true;
            }
        }

        if (fds->revents & POLLOUT) {
            CLEAR(buf);
            memset(planes, 0, sizeof(struct v4l2_plane) * MAX_PLANES);
            buf.type = V4L2_BUF_TYPE_VIDEO_OUTPUT_MPLANE;
            buf.memory = decodeTestContext->mem_type;
            buf.length = MAX_PLANES;
            buf.m.planes = planes;
            if (-1 == xioctl(decodeTestContext->fd, VIDIOC_DQBUF, &buf)) {
                switch (errno) {
                case EAGAIN:
                    continue;
                case EIO:
                    /* Could ignore EIO, see spec. */
                    /* fall through */
                default:
                    printf("pollout VIDIOC_DQBUF fail %d\n", errno);
                }
            }

            if (buf.index > decodeTestContext->n_inputbuffers)
            {
                printf("error out index %d\n",buf.index);
                break;
            }

            //if (bitsteamEnd)
            //    continue;

            if(!FillInputBuffer(decodeTestContext, &buf, 0)){
                bitsteamEnd = true;
            }

            if (-1 == xioctl(decodeTestContext->fd, VIDIOC_QBUF, &buf)) {
                printf("VIDIOC_QBUF fail\n");
                break;
            }
        }
    }

    if (fds) {
        free(fds);
        fds = NULL;
    }
}

int main(int argc, char **argv)
{
    printf("=============================\r\n");
    int32_t error,i,j;
    struct stat st;
    struct v4l2_capability cap;
    struct v4l2_format fmt;
    struct v4l2_requestbuffers req;
    struct v4l2_event_subscription argp;
    enum v4l2_buf_type type;
    decodeTestContext = malloc(sizeof(DecodeTestContext));
    gInput_v4l2_plane = malloc(sizeof(struct v4l2_plane) * MAX_BUF_CNT * MAX_PLANES);
    gOutput_v4l2_plane = malloc(sizeof(struct v4l2_plane) * MAX_BUF_CNT * MAX_PLANES);
    if (!decodeTestContext || !gInput_v4l2_plane || !gInput_v4l2_plane){
        return -1;
    }
    PCLEAR(decodeTestContext);
    PCLEAR(gInput_v4l2_plane);
    PCLEAR(gOutput_v4l2_plane);
    for (i = 0; i < MAX_BUF_CNT; i++){
        decodeTestContext->InputV4L2BufArray[i].m.planes = gInput_v4l2_plane + i * MAX_PLANES;
        decodeTestContext->OutputV4L2BufArray[i].m.planes = gOutput_v4l2_plane + i * MAX_PLANES;
        decodeTestContext->InputV4L2BufArray[i].length = MAX_PLANES;
        decodeTestContext->OutputV4L2BufArray[i].length = MAX_PLANES;
    }

    struct option longOpt[] = {
        {"output", required_argument, NULL, 'o'},
        {"input", required_argument, NULL, 'i'},
        {"format", required_argument, NULL, 'f'},
        {"scaleW", required_argument, NULL, 'w'},
        {"scaleH", required_argument, NULL, 'h'},
        {"test", required_argument, NULL, 't'},
        {"help", no_argument, NULL, '0'},
        {NULL, no_argument, NULL, 0},
    };
    char *shortOpt = "i:o:f:w:h:t";
    uint32_t c;
    int32_t l;

    if (argc == 0)
    {
        help();
        return -1;
    }

    while ((c = getopt_long(argc, argv, shortOpt, longOpt, (int *)&l)) != -1)
    {
        switch (c)
        {
        case 'i':
            printf("input: %s\r\n", optarg);
            if (access(optarg, R_OK) != -1)
            {
                memcpy(decodeTestContext->sInputFilePath, optarg, strlen(optarg));
            }
            else
            {
                printf("input file not exist!\r\n");
                return -1;
            }
            break;
        case 'o':
            printf("output: %s\r\n", optarg);
            memcpy(decodeTestContext->sOutputFilePath, optarg, strlen(optarg));
            break;
        case 'f':
            printf("format: %s\r\n", optarg);
            memcpy(decodeTestContext->sOutputFormat, optarg, strlen(optarg));
            break;
        case 'w':
            printf("ScaleWidth: %s\r\n", optarg);
            decodeTestContext->ScaleWidth = atoi(optarg);
            break;
        case 'h':
            printf("ScaleHeight: %s\r\n", optarg);
            decodeTestContext->ScaleHeight = atoi(optarg);
            break;
        case 't':
            testFPS = true;
            break;
        case '0':
        default:
            help();
            return -1;
        }
    }

    decodeTestContext->io_mthd = IO_METHOD_MMAP; //for now
    if (strstr(decodeTestContext->sOutputFormat, "nv12") != NULL)
    {
        decodeTestContext->format = V4L2_PIX_FMT_NV12M;
    }
    else if (strstr(decodeTestContext->sOutputFormat, "nv21") != NULL)
    {
        decodeTestContext->format = V4L2_PIX_FMT_NV21M;
    }
    else if (strstr(decodeTestContext->sOutputFormat, "i420") != NULL)
    {
        decodeTestContext->format = V4L2_PIX_FMT_YUV420M;
    }
    else
    {
        printf("Unsupported color format!\r\n");
        return -1;
    }

    /*ffmpeg init*/
    printf("init ffmpeg\r\n");
    AVFormatContext *avContext = NULL;
    AVCodecParameters *codecParameters = NULL;
    AVInputFormat *avfmt = NULL;
    int32_t videoIndex;
    if ((avContext = avformat_alloc_context()) == NULL)
    {
        printf("avformat_alloc_context fail\r\n");
        return -1;
    }
    avContext->flags |= AV_CODEC_FLAG_TRUNCATED;

    printf("avformat_open_input\r\n");
    if ((error = avformat_open_input(&avContext, decodeTestContext->sInputFilePath, avfmt, NULL)))
    {
        printf("%s:%d failed to av_open_input_file error(%s), %s\n",
               __FILE__, __LINE__, av_err2str(error), decodeTestContext->sInputFilePath);
        avformat_free_context(avContext);
        return -1;
    }

    printf("avformat_find_stream_info\r\n");
    if ((error = avformat_find_stream_info(avContext, NULL)) < 0)
    {
        printf("%s:%d failed to avformat_find_stream_info. error(%s)\n",
               __FUNCTION__, __LINE__, av_err2str(error));
        avformat_close_input(&avContext);
        avformat_free_context(avContext);
        return -1;
    }

    printf("av_find_best_stream\r\n");
    videoIndex = av_find_best_stream(avContext, AVMEDIA_TYPE_VIDEO, -1, -1, NULL, 0);
    if (videoIndex < 0)
    {
        printf("%s:%d failed to av_find_best_stream.\n", __FUNCTION__, __LINE__);
        return -1;
    }
    printf("video index = %d\r\n", videoIndex);
    decodeTestContext->video_stream_idx = videoIndex;
    decodeTestContext->avContext = avContext;
    /*get video info*/
    codecParameters = avContext->streams[videoIndex]->codecpar;
    printf("codec_id = %d, width = %d, height = %d\r\n", (int)codecParameters->codec_id,
           codecParameters->width, codecParameters->height);
    decodeTestContext->width = codecParameters->width;
    decodeTestContext->height = codecParameters->height;

    if (codecParameters->codec_id == AV_CODEC_ID_H264)
    {
        decodeTestContext->StreamFormat = V4L2_PIX_FMT_H264;
    }
    else if (codecParameters->codec_id == AV_CODEC_ID_HEVC)
    {
        decodeTestContext->StreamFormat = V4L2_PIX_FMT_HEVC;
    }
    else
    {
        printf("not support stream %d \n",(int)codecParameters->codec_id);
        goto end;
    }

    if (decodeTestContext->ScaleWidth)
    {
        int scalew = codecParameters->width / decodeTestContext->ScaleWidth;
        if (scalew > 8 || scalew < 1)
        {
            printf("orign width %d scale width %d.\n",codecParameters->width, decodeTestContext->ScaleWidth);
            printf("Scaling should be 1 to 1/8 (down-scaling only)! Use input parameter, end.\n");
            goto end;
        }
    }

    if (decodeTestContext->ScaleHeight)
    {
        int scaleh= codecParameters->height / decodeTestContext->ScaleHeight;
        if (scaleh > 8 || scaleh < 1)
        {
            printf("orign height %d scale height %d.\n",codecParameters->height, decodeTestContext->ScaleHeight);
            printf("Scaling should be 1 to 1/8 (down-scaling only)! Use input parameter, end.\n");
            goto end;
        }
    }

    signal(SIGINT, signal_handle);

    /* find video device */
    for (i = 0; i < MAX_VIDEO_CNT; i++){
        sprintf(devPath, "/dev/video%d", i);
        if (-1 == stat(devPath, &st)) {
            continue;
        }
        decodeTestContext->fd = v4l2_open(devPath, O_RDWR /* required */ | O_NONBLOCK, 0);
        if (-1 == decodeTestContext->fd) {
            printf("Cannot open '%s': %d, %s\n", devPath, errno, strerror(errno));
            continue;
        }

        if (-1 == xioctl(decodeTestContext->fd, VIDIOC_QUERYCAP, &cap)) {
            if (EINVAL == errno) {
                printf("%s is no V4L2 device\n", devPath);
                v4l2_close(decodeTestContext->fd);
                continue;
            } else {
                printf("%s can not VIDIOC_QUERYCAP fail\n", devPath);
                v4l2_close(decodeTestContext->fd);
                continue;
            }
        }

        if (strncmp((const char *)cap.driver, VPU_DEC_DRV_NAME, 9)) {
            v4l2_close(decodeTestContext->fd);
            continue;
        }
        printf("find %s %s\n", VPU_DEC_DRV_NAME, devPath);
        break;
    }

    if (i == MAX_VIDEO_CNT){
        printf("can not find decoder, end\n");
        goto end;
    }

    fb = fopen(decodeTestContext->sOutputFilePath, "wb+");
    if (!fb)
    {
        fprintf(stderr, "output file open err or no output file patch  %d\n", errno);
        goto end;
    }


    printf("init V4L2 device\n");

    switch (decodeTestContext->io_mthd) {
    case IO_METHOD_MMAP:
    case IO_METHOD_USERPTR:
    case IO_METHOD_DMABUF:
        if (!(cap.capabilities & V4L2_CAP_STREAMING)) {
            printf("%s does not support streaming i/o\n", devPath);
            goto end;
        }
        break;
    default:
        printf("%s does not specify streaming i/o\n", devPath);
        goto end;
        break;
    }

    argp.type = V4L2_EVENT_SOURCE_CHANGE;
    argp.id = 0;
    if (-1 == xioctl(decodeTestContext->fd, VIDIOC_SUBSCRIBE_EVENT, &argp)) {
        printf("VIDIOC_SUBSCRIBE_EVENT fail\n");
        goto end;
    }

    argp.type = V4L2_EVENT_EOS;
    argp.id = 0;
    if (-1 == xioctl(decodeTestContext->fd, VIDIOC_SUBSCRIBE_EVENT, &argp)) {
        printf("VIDIOC_SUBSCRIBE_EVENT fail\n");
        goto end;
    }

    printf("set src q format\n");

    fmt.type = V4L2_BUF_TYPE_VIDEO_OUTPUT_MPLANE;
    fmt.fmt.pix_mp.width = codecParameters->width;
    fmt.fmt.pix_mp.height = codecParameters->height;
    fmt.fmt.pix_mp.field = V4L2_FIELD_NONE;
    fmt.fmt.pix_mp.pixelformat = decodeTestContext->StreamFormat;
    if (-1 == xioctl(decodeTestContext->fd, VIDIOC_S_FMT, &fmt)) {
        printf("VIDIOC_S_FMT fail\n");
        goto end;
    }

    CLEAR(fmt);
    fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
    fmt.fmt.pix_mp.width = decodeTestContext->ScaleWidth? decodeTestContext->ScaleWidth: codecParameters->width;
    fmt.fmt.pix_mp.height = decodeTestContext->ScaleHeight? decodeTestContext->ScaleHeight: codecParameters->height;
    fmt.fmt.pix_mp.field = V4L2_FIELD_NONE;
    fmt.fmt.pix_mp.pixelformat = decodeTestContext->format;
    if (-1 == xioctl(decodeTestContext->fd, VIDIOC_S_FMT, &fmt)) {
        printf("VIDIOC_S_FMT fail\n");
        goto end;
    }

    convert_v4l2_mem_type(decodeTestContext->io_mthd, &decodeTestContext->mem_type);

    printf("get dist q format\n");
    CLEAR(fmt);
    fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
    fmt.fmt.pix_mp.field = V4L2_FIELD_NONE;
    if (-1 == ioctl(decodeTestContext->fd, VIDIOC_G_FMT, &fmt)) {
        printf("VIDIOC_G_FMT fail\n");
        goto end;
    }
    printf("VIDIOC_G_FMT: type=%d, Fourcc format=%c%c%c%c\n",
            fmt.type, fmt.fmt.pix_mp.pixelformat & 0xff,
            (fmt.fmt.pix_mp.pixelformat >> 8) &0xff,
            (fmt.fmt.pix_mp.pixelformat >> 16) &0xff,
            (fmt.fmt.pix_mp.pixelformat >> 24) &0xff);
    printf(" \t width=%d, height=%d, field=%d, bytesperline=%d, sizeimage=%d\n",
            fmt.fmt.pix_mp.width, fmt.fmt.pix_mp.height, fmt.fmt.pix_mp.field,
            fmt.fmt.pix_mp.plane_fmt[0].bytesperline, fmt.fmt.pix_mp.plane_fmt[0].sizeimage);

    if (fmt.fmt.pix_mp.pixelformat != decodeTestContext->format) {
        printf("v4l2 didn't accept format %d. Can't proceed.\n", decodeTestContext->format);
        goto end;
    }

    /* Note VIDIOC_S_FMT may change width and height. */
    if (decodeTestContext->width != fmt.fmt.pix_mp.width) {
        decodeTestContext->width = fmt.fmt.pix_mp.width;
        printf("Correct image width set to %i by device %s.\n", decodeTestContext->width, devPath);
    }

    if (decodeTestContext->height != fmt.fmt.pix_mp.height) {
        decodeTestContext->height = fmt.fmt.pix_mp.height;
        printf("Correct image height set to %i by device %s.\n", decodeTestContext->height,devPath);
    }

    /* prepare and start v4l2 stream */
    printf("request src buffer\n");
    CLEAR(req);
    req.count = BUFCOUNT;
    req.type = V4L2_BUF_TYPE_VIDEO_OUTPUT_MPLANE;
    req.memory = V4L2_MEMORY_MMAP;
    if (-1 == xioctl(decodeTestContext->fd, VIDIOC_REQBUFS, &req)) {
         printf("%s request buffer fail %d\n", devPath, errno);
         goto end;
    }
    decodeTestContext->n_inputbuffers = req.count;

    for (i = 0; i < decodeTestContext->n_inputbuffers; i++) {
        if (bitsteamEnd)
            break;

        decodeTestContext->InputV4L2BufArray[i].type = V4L2_BUF_TYPE_VIDEO_OUTPUT_MPLANE;
        decodeTestContext->InputV4L2BufArray[i].memory = V4L2_MEMORY_MMAP;
        decodeTestContext->InputV4L2BufArray[i].index = i;

        // test prepare
        //if (-1 == xioctl(decodeTestContext->fd, VIDIOC_PREPARE_BUF, &decodeTestContext->InputV4L2BufArray[i]))
        //{
        //    printf("VIDIOC_PREPARE_BUF fail %d\n",errno);
        //    goto end;
        //}
        // test prepare end

        if (-1 == xioctl(decodeTestContext->fd, VIDIOC_QUERYBUF, &decodeTestContext->InputV4L2BufArray[i]))
        {
            printf("VIDIOC_QUERYBUF fail %d\n",errno);
            goto end;
        }
        printf("src buffer %d type %d method %d n_plane %d\n",i ,decodeTestContext->InputV4L2BufArray[i].type,
                    decodeTestContext->InputV4L2BufArray[i].memory, decodeTestContext->InputV4L2BufArray[i].length);

        for (j = 0; j < decodeTestContext->InputV4L2BufArray[i].length; j++){
            printf("    plane %d length 0x%x offset 0x%x\n", j,
                    decodeTestContext->InputV4L2BufArray[i].m.planes[j].length, decodeTestContext->InputV4L2BufArray[i].m.planes[j].m.mem_offset);

            decodeTestContext->InputBufArray[i].length[j] = decodeTestContext->InputV4L2BufArray[i].m.planes[j].length;
            decodeTestContext->InputBufArray[i].start[j] = v4l2_mmap(NULL, /* start anywhere */
                    decodeTestContext->InputV4L2BufArray[i].m.planes[j].length, PROT_READ | PROT_WRITE, /* required */
                    MAP_SHARED, /* recommended */
                    decodeTestContext->fd, decodeTestContext->InputV4L2BufArray[i].m.planes[j].m.mem_offset);
            if (MAP_FAILED == decodeTestContext->InputBufArray[i].start[j]) {
                printf("map fail %d\n",i);
                goto end;
            }
        }

        if(!FillInputBuffer(decodeTestContext, &decodeTestContext->InputV4L2BufArray[i], 0)){
            bitsteamEnd = true;
        }
        if (-1 == xioctl(decodeTestContext->fd, VIDIOC_QBUF, &decodeTestContext->InputV4L2BufArray[i])) {
            printf("VIDIOC_QBUF fail\n");
            goto end;
        }
    }

    printf("start src stream\n");
    type = V4L2_BUF_TYPE_VIDEO_OUTPUT_MPLANE;
    if (-1 == xioctl(decodeTestContext->fd, VIDIOC_STREAMON, &type)) {
        printf("start src stream fail\n");
        goto end;
    }

    mainloop();

    printf("stop src stream\n");
    type = V4L2_BUF_TYPE_VIDEO_OUTPUT_MPLANE;
    if (-1 == xioctl(decodeTestContext->fd, VIDIOC_STREAMOFF, &type)) {
        printf("stop src stream fail\n");
        goto end;
    }
    printf("stop dist stream\n");
    type = V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE;
    if (-1 == xioctl(decodeTestContext->fd, VIDIOC_STREAMOFF, &type)) {
        printf("stop dist stream fail\n");
        goto end;
    }
    v4l2_close(decodeTestContext->fd);


end:
    /*free resource*/
    if (fb)
        fclose(fb);
    avformat_close_input(&avContext);
    avformat_free_context(avContext);
}
