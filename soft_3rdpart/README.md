# Soft Third Part for Starfive's Platforms

------

This Repository contain the soft of third party for starfive's JH7110 platform, such as: wave511, wave420l, codaj12, omx-il, e24, mailbox, IMG_GPU, ispsdk, spl_tool. The repo could be built by the buildroot through the JH7110 SDK.

## Prerequisites

this repository use the git lfs to pull/push the big binary package. So before git clone the repo, we must make sure the ubuntu host support Git LFS, if not, use the below

```
$ curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
$ sudo apt-get install git-lfs
```

------

### CODAJ12

CODAJ12 is the codja12 vendor development package, contain the linux driver and user space app. CODAJ12 is a standalone and high-performance JPEG Codec IP from Chip&Media, and performs the JPEG baseline/extended sequential and M-JPEG decoding and encoding. codaj12 was also called **JPU**, note the sdk support JPEG/M-JPEG decoding currently.

### WAVE511

WAVE511 is the wave511 vendor development package, contain the linux driver and user space app. WAVE511 is a 4K multi-format decoder IP from Chip&Media to support both HEVC/H.265 and AVC/H.264 video formats which provide high-performance decode capability. WAVE511 was also called **VPU Dec**.

### WAVE420L

WAVE420L is the wave420l vendor development package, contain the linux driver and user space app. WAVE420L is a low-cost HEVC/H.265 HW encoder IP from Chip&Media and is capable of encoding FHD/UHD HEVC/H.265 main profile L4.1. WAVE420L was also call **VPU Enc**.

### OMX-IL

OMX-IL is a library implement OpenMAX IL(Integration Layer) API from [khronos](https://www.khronos.org/openmaxil). The OMX-IL support hard Video Encoding/Decoding, JPEG/M-JPEG Decoding through the codaj12/wave511/wave420l library.

### IMG_GPU

IMG_GPU is a GPU library packages from Imagination and provide GPU firmware, libOpenCL, vulkan, gles2, gles3. This library is not open source, only provide with binary library. 

### ISPSDK

ISPSDK is the user space SDK for isp (Image Signal Processing)  IP from starfive. The isp 3A library not open source.

### SPL_TOOL

SPL_TOOL is a binary tool to transform the u-boot-spl.bin to u-boot-spl.bin.normal.out which is compatible with the JH7110 platform. 

### E24

This E24 directory provide the firmware binary, and test example. E24 is a 32-bit RISC-V CPU (E24) core for low power and control/configure tasks as a coprocessor in JH7110 SoC. 

### Mailbox

The mailbox directory provide the mainbox test app. The mailbox of JH7110 has the following features. 

- Send messages or signals between RISC-V cores 
- Support 4 mailbox elements, and each mailbox element includes 1 data word, 1 command register, and 1 flag bit for interrupt 
- Provide 32 registers for software to use to indicate whether the mailbox is occupied





