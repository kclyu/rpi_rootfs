# ffmpeg building with rpi_rootfs


## ffmpeg for armv6
shell scripts for compile ffmpeg
```
#!/bin/bash
#

#
# x264 clone and compile
#
mkdir -p ~/Workspace/ffmpeg
git clone git://git.videolan.org/x264
cd x264
./configure --host=arm-linux-gnueabihf --disable-asm --enable-static --cross-prefix=arm-linux-gnueabihf- --prefix=/opt/rpi_rootfs --sysroot=/opt/rpi_rootfs 
# library and executable will be placed in /opt/rpi_rootfs
make install
#
# ffmpeg clone and compile
#
cd ~/Workspace/ffmpeg
git clone git://source.ffmpeg.org/ffmpeg.git
cd ffmpeg
# --enable-nonfree options is not used for distribute the binary
./configure --cross-prefix=arm-linux-gnueabihf- --prefix=/opt/rpi_rootfs --sysroot=/opt/rpi_rootfs --arch=armv6 --target-os=linux --enable-gpl --enable-libx264  --extra-cflags="-I/opt/rpi_rootfs/include" --extra-ldflags="-L/opt/rpi_rootfs/lib" --extra-libs="-lx264 -lpthread -lm -ldl"
# running 4 parallel compile process
make -j 4
```

## ffmpeg for armv7 (fpu neon)
```
#!/bin/bash
#

#
# x264 clone and compile
#
mkdir -p ~/Workspace/ffmpeg
git clone git://git.videolan.org/x264
cd x264
./configure --host=arm-linux-gnueabihf --disable-asm --enable-static --cross-prefix=arm-linux-gnueabihf- --prefix=/opt/rpi_rootfs --sysroot=/opt/rpi_rootfs 
# library and executable will be placed in /opt/rpi_rootfs
make install
#
# ffmpeg clone and compile
#
cd ~/Workspace/ffmpeg
git clone git://source.ffmpeg.org/ffmpeg.git
cd ffmpeg
# --enable-nonfree options is not used for distribute the binary
./configure --cross-prefix=arm-linux-gnueabihf- --prefix=/opt/rpi_rootfs --sysroot=/opt/rpi_rootfs --arch=armv6 --target-os=linux --enable-gpl --enable-libx264  --extra-cflags="-I/opt/rpi_rootfs/include" --extra-ldflags="-L/opt/rpi_rootfs/lib" --extra-libs="-lx264 -lpthread -lm -ldl"
# running 4 parallel compile process
make -j 4
```

## Performance Comparing between cross compile and native building
*Note* Performance difference maybe came from 'extra-cflags' definition. 
Do not use this comparison result to determine which one is more faster or not

```
pi@raspberrypi:~/Videos $ time ../ffmpeg -i motion_2018-01-13.23:12:03.h264 test1.mp4
ffmpeg version N-89788-g1eb7c1d49d Copyright (c) 2000-2018 the FFmpeg developers
  built with gcc 4.9.4 (crosstool-NG crosstool-ng-1.22.0-248-gdf5a341 - Linaro GCC 2015.06) 20150629 (prerelease)
  configuration: --cross-prefix=arm-linux-gnueabihf- --prefix=/opt/rpi_rootfs --sysroot=/opt/rpi_rootfs --arch=arm --target-os=linux --enable-gpl --enable-libx264 --extra-cflags='-march=armv7-a -mfloat-abi=hard -mtune=cortex-a7 -mfpu=neon -I/opt/rpi_rootfs/include' --extra-ldflags=-L/opt/rpi_rootfs/lib --extra-libs='-lx264 -lpthread -lm -ldl'
  libavutil      56.  7.100 / 56.  7.100
  libavcodec     58.  9.100 / 58.  9.100
  libavformat    58.  3.100 / 58.  3.100
  libavdevice    58.  0.100 / 58.  0.100
  libavfilter     7. 11.101 /  7. 11.101
  libswscale      5.  0.101 /  5.  0.101
  libswresample   3.  0.101 /  3.  0.101
  libpostproc    55.  0.100 / 55.  0.100
Input #0, h264, from 'motion_2018-01-13.23:12:03.h264':
  Duration: N/A, bitrate: N/A
    Stream #0:0: Video: h264 (Main), yuv420p(progressive), 1024x768, 30 fps, 30 tbr, 1200k tbn, 60 tbc
Stream mapping:
  Stream #0:0 -> #0:0 (h264 (native) -> h264 (libx264))
Press [q] to stop, [?] for help
[libx264 @ 0x1b51e30] using cpu capabilities: ARMv6 NEON
[libx264 @ 0x1b51e30] profile High, level 3.1
[libx264 @ 0x1b51e30] 264 - core 155 - H.264/MPEG-4 AVC codec - Copyleft 2003-2017 - http://www.videolan.org/x264.html - options: cabac=1 ref=3 deblock=1:0:0 analyse=0x3:0x113 me=hex subme=7 psy=1 psy_rd=1.00:0.00 mixed_ref=1 me_range=16 chroma_me=1 trellis=1 8x8dct=1 cqm=0 deadzone=21,11 fast_pskip=1 chroma_qp_offset=-2 threads=6 lookahead_threads=1 sliced_threads=0 nr=0 decimate=1 interlaced=0 bluray_compat=0 constrained_intra=0 bframes=3 b_pyramid=2 b_adapt=1 b_bias=0 direct=1 weightb=1 open_gop=0 weightp=2 keyint=250 keyint_min=25 scenecut=40 intra_refresh=0 rc_lookahead=40 rc=crf mbtree=1 crf=23.0 qcomp=0.60 qpmin=0 qpmax=69 qpstep=4 ip_ratio=1.40 aq=1:1.00
Output #0, mp4, to 'test1.mp4':
  Metadata:
    encoder         : Lavf58.3.100
    Stream #0:0: Video: h264 (libx264) (avc1 / 0x31637661), yuv420p, 1024x768, q=-1--1, 30 fps, 15360 tbn, 30 tbc
    Metadata:
      encoder         : Lavc58.9.100 libx264
    Side data:
      cpb: bitrate max/min/avg: 0/0/0 buffer size: 0 vbv_delay: -1
frame=  478 fps=5.1 q=-1.0 Lsize=    1930kB time=00:00:15.83 bitrate= 998.5kbits/s speed=0.169x    
video:1924kB audio:0kB subtitle:0kB other streams:0kB global headers:0kB muxing overhead: 0.334210%
[libx264 @ 0x1b51e30] frame I:2     Avg QP:21.17  size: 64006
[libx264 @ 0x1b51e30] frame P:123   Avg QP:22.42  size: 10953
[libx264 @ 0x1b51e30] frame B:353   Avg QP:25.49  size:  1399
[libx264 @ 0x1b51e30] consecutive B-frames:  1.0%  1.3%  0.6% 97.1%
[libx264 @ 0x1b51e30] mb I  I16..4: 14.7% 39.1% 46.2%
[libx264 @ 0x1b51e30] mb P  I16..4:  1.1%  1.9%  0.8%  P16..4: 48.2%  8.1%  7.5%  0.0%  0.0%    skip:32.5%
[libx264 @ 0x1b51e30] mb B  I16..4:  0.0%  0.1%  0.0%  B16..8: 23.8%  1.0%  0.3%  direct: 0.7%  skip:74.1%  L0:37.7% L1:58.0% BI: 4.2%
[libx264 @ 0x1b51e30] 8x8 transform intra:47.4% inter:65.8%
[libx264 @ 0x1b51e30] coded y,uvDC,uvAC intra: 53.1% 64.3% 13.5% inter: 5.8% 13.8% 0.0%
[libx264 @ 0x1b51e30] i16 v,h,dc,p: 17% 28% 10% 46%
[libx264 @ 0x1b51e30] i8 v,h,dc,ddl,ddr,vr,hd,vl,hu: 25% 16% 27%  3%  6%  6%  6%  6%  5%
[libx264 @ 0x1b51e30] i4 v,h,dc,ddl,ddr,vr,hd,vl,hu: 26% 24% 14%  4%  8%  7%  6%  5%  4%
[libx264 @ 0x1b51e30] i8c dc,h,v,p: 46% 23% 24%  7%
[libx264 @ 0x1b51e30] Weighted P-Frames: Y:2.4% UV:1.6%
[libx264 @ 0x1b51e30] ref P L0: 64.4%  9.6% 19.2%  6.6%  0.2%
[libx264 @ 0x1b51e30] ref B L0: 93.3%  5.6%  1.0%
[libx264 @ 0x1b51e30] ref B L1: 97.2%  2.8%
[libx264 @ 0x1b51e30] kb/s:988.64

real	1m34.376s
user	5m53.450s
sys	0m1.890s


pi@raspberrypi:~/Videos $ time  /opt/rws/tools/ffmpeg_neon -i motion_2018-01-13.23:12:03.h264 test2.mp4
ffmpeg version N-89774-gaf964ba Copyright (c) 2000-2018 the FFmpeg developers
  built with gcc 4.9.2 (Raspbian 4.9.2-10)
  configuration: --target-os=linux --enable-gpl --enable-libx264 --arch=armv7-a
  libavutil      56.  7.100 / 56.  7.100
  libavcodec     58.  9.100 / 58.  9.100
  libavformat    58.  3.100 / 58.  3.100
  libavdevice    58.  0.100 / 58.  0.100
  libavfilter     7. 11.101 /  7. 11.101
  libswscale      5.  0.101 /  5.  0.101
  libswresample   3.  0.101 /  3.  0.101
  libpostproc    55.  0.100 / 55.  0.100
Input #0, h264, from 'motion_2018-01-13.23:12:03.h264':
  Duration: N/A, bitrate: N/A
    Stream #0:0: Video: h264 (Main), yuv420p(progressive), 1024x768, 30 fps, 30 tbr, 1200k tbn, 60 tbc
Stream mapping:
  Stream #0:0 -> #0:0 (h264 (native) -> h264 (libx264))
Press [q] to stop, [?] for help
[libx264 @ 0x1fc6710] using cpu capabilities: ARMv6 NEON
[libx264 @ 0x1fc6710] profile High, level 3.1
[libx264 @ 0x1fc6710] 264 - core 155 r2893 b00bcaf - H.264/MPEG-4 AVC codec - Copyleft 2003-2017 - http://www.videolan.org/x264.html - options: cabac=1 ref=3 deblock=1:0:0 analyse=0x3:0x113 me=hex subme=7 psy=1 psy_rd=1.00:0.00 mixed_ref=1 me_range=16 chroma_me=1 trellis=1 8x8dct=1 cqm=0 deadzone=21,11 fast_pskip=1 chroma_qp_offset=-2 threads=6 lookahead_threads=1 sliced_threads=0 nr=0 decimate=1 interlaced=0 bluray_compat=0 constrained_intra=0 bframes=3 b_pyramid=2 b_adapt=1 b_bias=0 direct=1 weightb=1 open_gop=0 weightp=2 keyint=250 keyint_min=25 scenecut=40 intra_refresh=0 rc_lookahead=40 rc=crf mbtree=1 crf=23.0 qcomp=0.60 qpmin=0 qpmax=69 qpstep=4 ip_ratio=1.40 aq=1:1.00
Output #0, mp4, to 'test2.mp4':
  Metadata:
    encoder         : Lavf58.3.100
    Stream #0:0: Video: h264 (libx264) (avc1 / 0x31637661), yuv420p, 1024x768, q=-1--1, 30 fps, 15360 tbn, 30 tbc
    Metadata:
      encoder         : Lavc58.9.100 libx264
    Side data:
      cpb: bitrate max/min/avg: 0/0/0 buffer size: 0 vbv_delay: -1
frame=  478 fps=5.0 q=-1.0 Lsize=    1930kB time=00:00:15.83 bitrate= 998.6kbits/s speed=0.165x     
video:1924kB audio:0kB subtitle:0kB other streams:0kB global headers:0kB muxing overhead: 0.334208%
[libx264 @ 0x1fc6710] frame I:2     Avg QP:21.17  size: 64006
[libx264 @ 0x1fc6710] frame P:123   Avg QP:22.42  size: 10953
[libx264 @ 0x1fc6710] frame B:353   Avg QP:25.49  size:  1399
[libx264 @ 0x1fc6710] consecutive B-frames:  1.0%  1.3%  0.6% 97.1%
[libx264 @ 0x1fc6710] mb I  I16..4: 14.7% 39.1% 46.2%
[libx264 @ 0x1fc6710] mb P  I16..4:  1.1%  1.9%  0.8%  P16..4: 48.2%  8.1%  7.5%  0.0%  0.0%    skip:32.5%
[libx264 @ 0x1fc6710] mb B  I16..4:  0.0%  0.1%  0.0%  B16..8: 23.8%  1.0%  0.3%  direct: 0.7%  skip:74.1%  L0:37.7% L1:58.0% BI: 4.2%
[libx264 @ 0x1fc6710] 8x8 transform intra:47.4% inter:65.8%
[libx264 @ 0x1fc6710] coded y,uvDC,uvAC intra: 53.1% 64.3% 13.5% inter: 5.8% 13.8% 0.0%
[libx264 @ 0x1fc6710] i16 v,h,dc,p: 17% 28% 10% 46%
[libx264 @ 0x1fc6710] i8 v,h,dc,ddl,ddr,vr,hd,vl,hu: 25% 16% 27%  3%  6%  6%  6%  6%  5%
[libx264 @ 0x1fc6710] i4 v,h,dc,ddl,ddr,vr,hd,vl,hu: 26% 24% 14%  4%  8%  7%  6%  5%  4%
[libx264 @ 0x1fc6710] i8c dc,h,v,p: 46% 23% 24%  7%
[libx264 @ 0x1fc6710] Weighted P-Frames: Y:2.4% UV:1.6%
[libx264 @ 0x1fc6710] ref P L0: 64.4%  9.6% 19.2%  6.6%  0.2%
[libx264 @ 0x1fc6710] ref B L0: 93.3%  5.6%  1.0%
[libx264 @ 0x1fc6710] ref B L1: 97.2%  2.8%
[libx264 @ 0x1fc6710] kb/s:988.64

real	1m36.527s
user	6m2.330s
sys	0m1.860s
```
