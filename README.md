# rpi_rootfs
This python script will create Raspberry PI rootfs(sysroot) to cross-compile WebRTC native-package in Ubuntu Linux.

## Required package in Raspberry PI

#### Package for Rsync 
```
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install rsync
```

#### Required Package for WebRTC native code package to build
```
sudo apt-get install libasound2-dev libcairo2-dev  libffi-dev libglib2.0-dev  \
libgtk2.0-dev libpam0g-dev libpulse-dev  libudev-dev  libxtst-dev  \
ttf-dejavu-core libatk1.0-0 libc6 libasound2  libcairo2 libcap2 libcups2  \
libexpat1 libffi6 libfontconfig1 libfreetype6  libglib2.0-0 libgnome-keyring0  \
libgtk2.0-0 libpam0g libpango1.0-0  libpcre3 libpixman-1-0 libpng12-0 libstdc++6  \
libx11-6 libx11-xcb1 libxau6 libxcb1 libxcomposite1 libxcursor1 libxdamage1   \
libxdmcp6 libxext6 libxfixes3 libxi6 libxinerama1 libxrandr2 libxrender1  \
libxtst6 zlib1g 
```

## Setup in Ubuntu Linux
#### Install Prerequisite Software tool
To build the WebRTC native-code package, [Prerequisite Software tool](https://webrtc.org/native-code/development/prerequisite-sw/)  must be installed at first.


#### Package for Rsync 
```
sudo apt-get install rsync
```
#### RPi_RootFS files
filename|Descrption
|----------------|---------------|
|rpi_rootfs.py |main python script, you need two argument for this script,  "Usage: ./rpi_rootfs.py <<user@hostname>> \<rootfs path>" |
|rpi_rootfs_exclude.txt| exclude pattern file during sync|

#### Making Raspberry PI sysroot
```
# sudo apt-get install rsync
# cd ~/Workspace
# git clone https://github.com/kclyu/rpi_rootfs.git
# cd rpi_rootfs
# ./rpi_rootfs.py 
Usage: ./rpi_rootfs.py <user@hostname> <rootfs path>
#./rpi_rootfs.py pi@your_pi_address ./
```


#### Rpi_rootfs log example 
For my case, the log message was over 9000 lines.

```
./rpi_rootfs.py pi@10.0.0.11 ./
################################################################################
###
### rootfs syncing from pi@10.0.0.11
###
################################################################################
pi@10.0.0.11's password: 
receiving file list ... done 
lib/
lib/cpp -> /etc/alternatives/cpp
lib/klibc-YL2Pal4e_FwRI58JJ6S97Xf241g.so
lib/ld-linux-armhf.so.3 -> arm-linux-gnueabihf/ld-2.19.so
lib/ld-linux.so.3 -> /lib/ld-linux-armhf.so.3
lib/libip4tc.so.0 -> libip4tc.so.0.1.0
lib/libip4tc.so.0.1.0
lib/libip6tc.so.0 -> libip6tc.so.0.1.0
lib/libip6tc.so.0.1.0
lib/libipq.so.0 -> libipq.so.0.0.0
lib/libipq.so.0.0.0
lib/libiptc.so.0 -> libiptc.so.0.0.0
lib/libiptc.so.0.0.0
lib/libnih-dbus.so.1 -> libnih-dbus.so.1.0.0
lib/libnih-dbus.so.1.0.0
.
.
.
usr/share/pkgconfig/xkeyboard-config.pc
usr/share/pkgconfig/xorg-sgml-doctools.pc
usr/share/pkgconfig/xproto.pc
usr/share/pkgconfig/xtrans.pc

Number of files: 8,819 (reg: 6,995, dir: 748, link: 1,076)
Number of created files: 8,819 (reg: 6,995, dir: 748, link: 1,076)
Number of deleted files: 0
Number of regular files transferred: 6,995
Total file size: 744,892,302 bytes
Total transferred file size: 744,869,970 bytes
Literal data: 744,869,970 bytes
Matched data: 0 bytes
File list size: 214,902
File list generation time: 0.343 seconds
File list transfer time: 0.000 seconds
Total bytes sent: 139,106
Total bytes received: 745,560,296

sent 139,106 bytes  received 745,560,296 bytes  3,444,339.04 bytes/sec
total size is 744,892,302  speedup is 1.00
################################################################################
###
### rootfs syncing from pi@10.0.0.11
###
################################################################################
################################################################################
###
### fixing absolute links
###
################################################################################
File Starting /home/kclyu/Workspace/rpi_rootfs/usr/lib/liblapack.so.3gf link /etc/alternatives/liblapack.so.3gf
File Starting /home/kclyu/Workspace/rpi_rootfs/usr/lib/libblas.so.3 link /etc/alternatives/libblas.so.3
File Starting /home/kclyu/Workspace/rpi_rootfs/usr/lib/liblapack.so.3 link /etc/alternatives/liblapack.so.3
.
.
.
File Starting /home/kclyu/Workspace/rpi_rootfs/lib/ld-linux.so.3 link /lib/ld-linux-armhf.so.3
File Starting /home/kclyu/Workspace/rpi_rootfs/lib/cpp link /etc/alternatives/cpp
################################################################################
###
### linking pkgconfig on /usr/share/pkginfo
###
################################################################################
pkg config: /home/kclyu/Workspace/rpi_rootfs/usr/lib/arm-linux-gnueabihf/pkgconfig
source ../../lib/arm-linux-gnueabihf/pkgconfig/cairo-ft.pc target /home/kclyu/Workspace/rpi_rootfs/usr/share/pkgconfig/cairo-ft.pc
source ../../lib/arm-linux-gnueabihf/pkgconfig/cairo-ps.pc target /home/kclyu/Workspace/rpi_rootfs/usr/share/pkgconfig/cairo-ps.pc
.
.
.
source ../../lib/arm-linux-gnueabihf/pkgconfig/gdk-pixbuf-xlib-2.0.pc target /home/kclyu/Workspace/rpi_rootfs/usr/share/pkgconfig/gdk-pixbuf-xlib-2.0.pc
################################################################################
###
### fixing ld scripts absolute path to relative path
###
################################################################################
Changing "/lib/arm-linux-gnueabihf/libc.so.6" to "../../../lib/arm-linux-gnueabihf/libc.so.6" in usr/lib/arm-linux-gnueabihf/libc.so
Changing "/usr/lib/arm-linux-gnueabihf/libc_nonshared.a" to "libc_nonshared.a" in usr/lib/arm-linux-gnueabihf/libc.so
Changing "/lib/arm-linux-gnueabihf/ld-linux-armhf.so.3" to "../../../lib/arm-linux-gnueabihf/ld-linux-armhf.so.3" in usr/lib/arm-linux-gnueabihf/libc.so
Changing "/lib/arm-linux-gnueabihf/libpthread.so.0" to "../../../lib/arm-linux-gnueabihf/libpthread.so.0" in usr/lib/arm-linux-gnueabihf/libpthread.so
Changing "/usr/lib/arm-linux-gnueabihf/libpthread_nonshared.a" to "libpthread_nonshared.a" in usr/lib/arm-linux-gnueabihf/libpthread.so


```
