# rpi_rootfs
This repo provides a python script that takes the necessary files from the running Raspberry Pi and uses rsync to fetch the files and make the Root FS for the cross compile environment. In addition, it provides a link to download custom compied gcc for use with Ubuntu.

## Required package in Raspberry PI

```
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install rsync
```

## Custom Compiled GCC for Raspberry PI

```
mkdir -p ~/Workspace
git clone https://github.com/kclyu/rpi_rootfs
cd rpi_rootfs
# (Download Custom Compiled GCC) # note1
mv ~/Downloads/tools_gcc_4.9.4.tar.gz  .
tar xvzf tools_gcc_4.9.4.tar.gz  # note 2
cd /opt
sudo ln -sf ~/Workspace/rpi_rootfs
export PATH=/opt/rpi_rootfs/tools/arm-linux-gnueabihf/bin:$PATH
```
*Note 1: Custom Compiled GCC : Please click this tools_gcc-4.9.4.tar.gz link to download it. Because of the large file size, google drive link is available for download. You may get a warning message that "file size is too large to scan for viruses" and "You can not 'Preview'" during downloading from google drive.*

*Note 2: tools_gcc-4.9.4.tar.gz is a cross compile gcc for Raspberry PI and is a custom compiled compiler. Please refer to rpi_rootfs/raspi_gcc_4.9.4.ct-ng.config for more tools_gcc_4.9_4 specs.*


|URL|SHA256sum|
|----------------|---------------|
|[tools_gcc-4.9.4.tar.gz](https://drive.google.com/open?id=0B4FN-EnejHTaLWVILVFkVTZteWM)|99e0aa822ff8bcdd3bbfe978466f2bed281001553f3b9c295eba2d6ed636d6c2|


## Making Raspberry PI sysroot
```
cd ~/Workspace/rpi_rootfs
./rpi_rootfs.py 
Usage: ./rpi_rootfs.py @hostname> <rootfs path>
./rpi_rootfs.py pi@your-raspberry-pi-ipaddress ./
```
*When rpi_rootfs.py is executed, many messages are output to console during the sync list of files and library link fixing. Please ignore the messages.*

If you installed a new library or software on Raspberry PI, please execute it again to apply the changed part.

## Cross Compiling Examples
The example below is based on the installation of rpi_rootfs and custom compiled gcc. Please use as needed.
The following list is an example of source packages cross compiled using rpi_rootfs.
- [WebRTC native-code source package](https://webrtc.org/native-code/development/)
- [libwebsockets](https://github.com/warmcat/libwebsockets)
- [OpenCV 3.x](https://github.com/opencv/opencv)
- [h264bitstream](https://github.com/aizvorski/h264bitstream)
- [x264](git://git.videolan.org/x264) and [ffmpeg]( git://source.ffmpeg.org/ffmpeg.git) 

#### PI.cmake
It is a CMAKE_TOOLCHAIN_FILE definition file for cmake used when cross compile using cmake. You can cross compile using cmake with toolchanin provided by rpi_rootfs as follows.

```
cd  cmake_source_distribution_root_path
mkdir build
cd build
cmake -DCMAKE_TOOLCHAIN_FILE=~/Workspace/rpi_rootfs/PI.cmake  -DCMAKE_BUILD_TYPE=Debug ..
```
#### Building WebRTC native-code package
For more information, please refer to the [README_building.md](https://github.com/kclyu/rpi-webrtc-streamer/blob/master/README_building.md) document of rpi-webrtc-streamer

#### Building x264 and ffmpeg
Please refer to [README_ffmpeg_building.md](../master/README_ffmpeg_building.md). for how to build ffmpeg for Raspberry PI using rpi_toolfs.

#### Building OpenCV 3.x example
```
cd ~/Workspace
git clone https://github.com/opencv/opencv.git
cd opencv
mkdir arm_build
cd arm_build
cmake -DCMAKE_TOOLCHAIN_FILE=~/Workspace/rpi_rootfs/PI.cmake  .. -DENABLE_CXX11=ON \
	-DENABLE_NEON=ON -DDENABLE_VFPV3=ON -DWITH_PNG=ON -DWITH_TBB=ON -DWITH_TIFF=ON \
	-DWITH_OPENGL=ON -DCMAKE_INSTALL_PREFIX=~/Workspace/rpi_rootfs
make
```

