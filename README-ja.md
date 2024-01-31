[English](./README.md) | [日本語](./README-ja.md)
# Milk-V Mars/Mars-CM SDK

これは`StarFiveTech JH7110`向けの完全なRISC-Vクロスコンパイルツールチェーンをビルドします。
`JH7110`チップの`Milk-V Mars`と`Mars CM`向けのU-Boot SPL、U-Boot、OpenSBI、平坦化イメージツリー(FIT)イメージ、Linuxカーネル、デバイスツリー、RAMディスクとrootfsイメージも一緒にビルドします。

## 前提条件

推奨OS: Ubuntu 16.04/18.04/20.04/22.04 x86_64

インストールが必要な追加のパッケージ:

```
$ sudo apt update
$ sudo apt-get install build-essential automake libtool texinfo bison flex gawk
g++ git xxd curl wget gdisk gperf cpio bc screen texinfo unzip libgmp-dev
libmpfr-dev libmpc-dev libssl-dev libncurses-dev libglib2.0-dev libpixman-1-dev
libyaml-dev patchutils python3-pip zlib1g-dev device-tree-compiler dosfstools
mtools kpartx rsync
```


## SDKの取得 ##

このリポジトリを確認

```
git clone https://github.com/milkv-mars/mars-buildroot-sdk.git --depth=1
```

これにはしばらく掛かるほか、5GBのディスクスペースが必要です。

それぞれのボードにはそれぞれのブランチを使う必要があります。

- Mars
  ```
  git checkout dev
  ```

- Mars CM eMMC
  ```
  git checkout dev-mars-cm
  ```

- Mars CM SD Card
  ```
  git checkout dev-mars-cm-sdcard
  ```

## クイックビルド

下に示すのはinitramfsのイメージである`image.fit`のクイックビルドです。`image.fit`はボード用に変換された上でtftpで転送しボード上で実行されます。
完成したツールチェーンの`u-boot-spl.bin.normal.out`と`visionfive2_fw_payload.img`と`image.fit`は`/work`の下に出てきます。完成したビルドツリーは16GBのディスクスペースを消費します。
```
$ make -j$(nproc)
```

ターゲットファイルが生成されたらファイルをtftpサーバーのワークスペースにコピーします。

```
work/
├── visionfive2_fw_payload.img
├── image.fit
├── initramfs.cpio.gz
├── u-boot-spl.bin.normal.out
├── linux
    ├── arch/riscv/boot
    │   ├── dts
    │   │   └── starfive
    │   │       ├── jh7110-milkv-mars-cm-emmc.dtb
    │   │       ├── jh7110-milkv-mars-cm-sdcard.dtb
    │   │       ├── jh7110-milkv-mars.dtb
    │   │       ├── jh7110-visionfive-v2-ac108.dtb
    │   │       ├── jh7110-visionfive-v2.dtb
    │   │       ├── jh7110-visionfive-v2-wm8960.dtb
    │   │       ├── vf2-overlay
    │   │       │   └── vf2-overlay-uart3-i2c.dtbo
    │   └── Image.gz
    └── vmlinuz-5.15.0
```

buildrootとubootとlinuxとbusyboxを設定するため追加のコマンド:

```
$ make buildroot_initramfs-menuconfig   # buildroot initramfs menuconfig
$ make buildroot_rootfs-menuconfig      # buildroot rootfs menuconfig
$ make uboot-menuconfig                 # uboot menuconfig
$ make linux-menuconfig                 # Kernel menuconfig
$ make -C ./work/buildroot_initramfs/ O=./work/buildroot_initramfs busybox-menuconfig  # for initramfs busybox menuconfig
$ make -C ./work/buildroot_rootfs/ O=./work/buildroot_rootfs busybox-menuconfig        # for rootfs busybox menuconfig
```

パッケージとモジュールをビルドするための追加のコマンド:

```
$ make vmlinux   # build linux kernel
$ make -C ./work/buildroot_rootfs/ O=./work/buildroot_rootfs busybox-rebuild   # build busybox package
$ make -C ./work/buildroot_rootfs/ O=./work/buildroot_rootfs ffmpeg-rebuild    # build ffmpeg package
```

## ネットワーク経由でJH7110のMars/Mars-CMボードで実行する
JH7110のMars/Mars-CMボードがシリアルケーブル、ネットワークケーブルに接続した状態で、電源を投入すると下のような起動情報が出力されるはずです。

```
U-Boot SPL 2021.10 (Oct 31 2022 - 12:11:37 +0800)
DDR version: dc2e84f0.
Trying to boot from SPI

OpenSBI v1.0
   ____                    _____ ____ _____
  / __ \                  / ____|  _ \_   _|
 | |  | |_ __   ___ _ __ | (___ | |_) || |
 | |  | | '_ \ / _ \ '_ \ \___ \|  _ < | |
 | |__| | |_) |  __/ | | |____) | |_) || |_
  \____/| .__/ \___|_| |_|_____/|____/_____|
        | |
        |_|

Platform Name             : StarFive VisionFive V2
Platform Features         : medeleg
Platform HART Count       : 5
Platform IPI Device       : aclint-mswi
Platform Timer Device     : aclint-mtimer @ 4000000Hz
Platform Console Device   : uart8250
Platform HSM Device       : ---
Platform Reboot Device    : ---
Platform Shutdown Device  : ---
Firmware Base             : 0x40000000
Firmware Size             : 360 KB
Runtime SBI Version       : 0.3

Domain0 Name              : root
Domain0 Boot HART         : 3
Domain0 HARTs             : 0*,1*,2*,3*,4*
Domain0 Region00          : 0x0000000002000000-0x000000000200ffff (I)
Domain0 Region01          : 0x0000000040000000-0x000000004007ffff ()
Domain0 Region02          : 0x0000000000000000-0xffffffffffffffff (R,W,X)
Domain0 Next Address      : 0x0000000040200000
Domain0 Next Arg1         : 0x0000000042200000
Domain0 Next Mode         : S-mode
Domain0 SysReset          : yes

Boot HART ID              : 3
Boot HART Domain          : root
Boot HART Priv Version    : v1.11
Boot HART Base ISA        : rv64imafdcbx
Boot HART ISA Extensions  : none
Boot HART PMP Count       : 8
Boot HART PMP Granularity : 4096
Boot HART PMP Address Bits: 34
Boot HART MHPM Count      : 2
Boot HART MIDELEG         : 0x0000000000000222
Boot HART MEDELEG         : 0x000000000000b109


U-Boot 2021.10 (Oct 31 2022 - 12:11:37 +0800), Build: jenkins-VF2_515_Branch_SDK_Release-10

CPU:   rv64imacu
Model: StarFive VisionFive V2
DRAM:  8 GiB
MMC:   sdio0@16010000: 0, sdio1@16020000: 1
Loading Environment from SPIFlash... SF: Detected gd25lq128 with page size 256 Bytes, erase size 4 KiB, total 16 MiB
*** Warning - bad CRC, using default environment

StarFive EEPROM format v2

--------EEPROM INFO--------
Vendor : StarFive Technology Co., Ltd.
Product full SN: VF7110A1-2243-D008E000-00000001
data version: 0x2
PCB revision: 0xa1
BOM revision: A
Ethernet MAC0 address: 6c:cf:39:00:14:5b
Ethernet MAC1 address: 6c:cf:39:00:14:5c
--------EEPROM INFO--------

In:    serial@10000000
Out:   serial@10000000
Err:   serial@10000000
Model: StarFive VisionFive V2
Net:   eth0: ethernet@16030000, eth1: ethernet@16040000
switch to partitions #0, OK
mmc1 is current device
found device 1
bootmode flash device 1
Failed to load 'uEnv.txt'
Can't set block device
Hit any key to stop autoboot:  0 
StarFive # 
```

そうしたら、任意のキーを押してubootターミナルに入ります。ボードを起動するには2つ方法があります。

#### 1. デフォルトのDTBである`jh7110-visionfive-v2.dtb`とともに`image.fit`を実行  

TFTP経由でimage.fitを転送:

Step1: 環境変数を設定:
```
setenv 192.168.xxx.xxx; setenv serverip 192.168.xxx.xxx;
```

Step2: ddrにイメージファイルをアップロード

```
tftpboot ${loadaddr} image.fit;
```

Step3: 読み込んで実行

```
bootm start ${loadaddr};bootm loados ${loadaddr};run chipa_set_linux;run cpu_vol_set; booti ${kernel_addr_r} ${ramdisk_addr_r}:${filesize} ${fdt_addr_r};
```

`buildroot login:`のメッセージが表示されたら成功です。

```
buildroot login:root
Password: starfive
```

#### 2. 他のdtbと一緒にimage.gzとinitramfs.cpio.gzを実行

もし他のdtb(`jh7110-milkv-mars-cm-sdcard.dtb`)みたいなのものを読み込みたいなら下に従ってください。

Step1: 環境変数を設定:

```
setenv ipaddr 192.168.xxx.xxx; setenv serverip 192.168.xxx.xxx;
```

Step2: ddrにイメージファイルをアップロード:
```
tftpboot ${fdt_addr_r} jh7110-milkv-mars-cm-sdcard.dtb;
tftpboot ${kernel_addr_r} Image.gz;
tftpboot ${ramdisk_addr_r} initramfs.cpio.gz;
run chipa_set_linux;run cpu_vol_set;
```

Step3: 読み込んで実行:

```
booti ${kernel_addr_r} ${ramdisk_addr_r}:${filesize} ${fdt_addr_r}
```
`buildroot login:`のメッセージが表示されたら成功です。

```
buildroot login:root
Password: starfive
```

***

## 付録1: 起動できるSDカードの作成

もしあなたがまだローカルのtftpサーバーを使っていない場合、(Micro)SDカードをターゲットにしたいということだと思います。
イメージのデフォルトのサイズは16GBです。
**注意:この操作はターゲットのSDカードのデータをすべて破壊します。**
SDカードには`GPT`パーティションテーブルをおすすめします。

#### Generate SD Card Image File
#### SDカードイメージファイルの生成

以下のコマンドでSDカードイメージを生成できます。SDカードイメージは`dd`コマンドとか`rpi-imager`や`balenaEtcher`みたいなツールで焼くことができます。

```
$ make -j$(nproc)
$ make buildroot_rootfs -j$(nproc)
$ make img
```

出力は`work/sdcard.img`に出てきます。

#### SDカードイメージを焼く

`sdcard.img`はSDカードに焼き込むことができます。たとえば、`dd`コマンドであれば、下のようになります。

```
$ sudo dd if=work/sdcard.img of=/dev/sdX bs=4096
$ sync
```

あとからrootfsパーティションを拡張する場合、2つの方法があります。

1つ目の方法はUbuntuホストでできる方法です。下に必要なパッケージを示します。
```
$ sudo apt install cloud-guest-utils e2fsprogs 
```

SDカードをUbuntuホストに挿入して、以下のコマンドの`/dev/sdX`の部分は挿入したSDカードに置き換えてください。
```
$ sudo growpart /dev/sdX 4  # extend partition 4
$ sudo e2fsck -f /dev/sdX4
$ sudo resize2fs /dev/sdX4  # extend filesystem
$ sudo fsck.ext4 /dev/sdX4
```

2つ目の方法はMars/Mars-CM boardで行えるものです。fdiskとresize2fsコマンドを使います：

```
Mars:    /dev/mmcblk1
Mars CM: /dev/mmcblk0
```

```
# fdisk /dev/mmcblk1
Welcome to fdisk (util-linux 2.37.2).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.
This disk is currently in use - repartitioning is probably a bad idea.
It's recommended to umount all file systems, and swapoff all swap
partitions on this disk.
Command (m for help): d
Partition number (1-4, default 4): 4
Partition 4 has been deleted.
Command (m for help): n
Partition number (4-128, default 4): 4
First sector (614400-62333918, default 614400):
): t sector, +/-sectors or +/-size{K,M,G,T,P} (614400-62333918, default 62333918)
Created a new partition 4 of type 'Linux filesystem' and of size 29.4 GiB.
Partition #4 contains a ext4 signature.
Do you want to remove the signature? [Y]es/[N]o: N
Command (m for help): w
The partition table has been altered.
Syncing disks.

# resize2fs /dev/mmcblk1p4
resize2fs 1.46.4 (18-Aug-2021)
Filesystem at /d[
111.756178] EXT4-fs (mmcblk1p4): resizing filesystem from 512000
to 30859756 blocks
ev/mmcblk1p4 is [
111.765203] EXT4-fs (mmcblk1p4): resizing filesystem from 512000
to 30859265 blocks
mounted on /; on-line resizing required
old_desc_blocks = 2, new_desc_blocks = 118
[ 112.141953] random: crng init done
[ 112.145369] random: 7 urandom warning(s) missed due to ratelimiting
[ 115.474184] EXT4-fs (mmcblk1p4): resized filesystem to 30859265
The filesystem on /dev/mmcblk1p4 is now 30859756 (1k) blocks long.
```

もしswap用とかの新しいパーティションが必要な場合は、以下のシェルスクリプトを実行することで可能です。
ここでは、残りのディスクスペースのすべてをswapに割り当てていますが、通常の場合はメインメモリのサイズと同じかその2倍にしてください:

```bash
#!bin/sh
sgdisk -e /dev/mmcblk0
disk=/dev/mmcblk0
gdisk $disk << EOF
p
n
5


8200
p
c
5
hibernation
w
y
EOF

mkswap /dev/mmcblk0p5
swapoff -a
swapon /dev/mmcblk0p5
```

## 付録2: 動的にDTBオーバーレイを使う
システムはボード実行中のDTBの動的な読み込みをサポートします。ボードで以下を実行：

```
# mount -t configfs none /sys/kernel/config
# mkdir -p /sys/kernel/config/device-tree/overlays/dtoverlay
# cd <the dtoverlay.dtbo path>
# cat vf2-overlay-uart3-i2c.dtbo > /sys/kernel/config/device-tree/overlays/dtoverlay/dtbo
```

追加で、DTBオーバーレイを削除できます。

```
# rmdir /sys/kernel/config/device-tree/overlays/dtoverlay
```

## 付録3: U-boot環境下でのSPLとU-bootバイナリのアップデート

tftpサーバーを準備します。たとえば、ubuntu向けであれば、`sudo apt install tftpd-hpa`でできます。

1. Mars/Mars-CMの電源を入れてU-bootコマンドラインに入るまで待つ

2. 次のように環境変数を設定：

   ```
   StarFive # setenv ipaddr 192.168.120.222;setenv serverip 192.168.120.99
   ```

3. ボードからホストPCにpingして接続を確認

4. SPIフラッシュを初期化

   ```
   StarFive # sf probe
   ```

5. SPLバイナリをアップデート

   ```
   StarFive # tftpboot ${loadaddr}  u-boot-spl.bin.normal.out
   StarFive # sf update ${loadaddr} 0x0 $filesize
   ```

6. U-Bootバイナリをアップデート

   ```
   StarFive # tftpboot ${loadaddr}  visionfive2_fw_payload.img
   StarFive # sf update ${loadaddr} 0x100000 $filesize
   ```

## 付録4: ブートローダーの回復

SPLとU-Bootはボード上のSPIフラッシュに格納されています。誤って内容を吹き飛ばしてしまったり、あるいはフラッシュのデータの破損に遭遇するかもしれません。その場合はブートローダーを回復します。

詳しくは https://github.com/starfive-tech/Tools を確認してください。
