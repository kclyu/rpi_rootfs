# RootFS for Raspberry PI
This Repo creates a Cross Compile environment for Raspberry PI by generating Root FS for Raspberry PI on Ubuntu Linux using python.
This Repo is used to cross compile the WebRTC native code package for use with Rpi-WebRTC-Streamer. For an example of compiling OpenCV and ffmpeg, see the `Cross Compiling Examples` section below.

This Repo provide google Drive Link to download Custom Compiled GCC. If you are not familiar with cross compile and do not have your own cross compile environment, please download and use GCC from `Custom Compiled GCC for Raspberry PI` below.

## Making Raspberry PI RootFS
```
cd ~/Workspace/rpi_rootfs
./rpi_rootfs.py 
Usage: ./rpi_rootfs.py @hostname> <rootfs path>
./rpi_rootfs.py pi@your-raspberry-pi-ipaddress ./
```
*When rpi_rootfs.py is executed, many messages are output to console during the sync list of files and library link fixing. Please ignore the messages.*

If you installed a new library or software on Raspberry PI, please execute it again to apply the changed part.

## Custom Compiled GCC for Raspberry PI

```
mkdir -p ~/Workspace
git clone https://github.com/kclyu/rpi_rootfs
cd rpi_rootfs
mkdir tools
cd tools
# (Download Custom Compiled GCC) # note1
xz -dc ~/Downloads/gcc-linaro-6.4.1-2018.10-x86_64_arm-linux-gnueabihf.tar.xz | tar xvf -
ln -sf gcc-linaro-6.4.1-2018.10-x86_64_arm-linux-gnueabihf  arm-linux-gnueabihf
cd /opt
sudo ln -sf ~/Workspace/rpi_rootfs
export PATH=/opt/rpi_rootfs/tools/arm-linux-gnueabihf/bin:$PATH
```
*Note 1: Custom Compiled GCC : Please click  gcc-linaro-6.4.1-2017.01-x86_64_arm-linux-gnueabihf.tar.xz link to download it. Because of the large file size, google drive link is available for download. You may get a warning message that "file size is too large to scan for viruses" and "You can not 'Preview'" during downloading from google drive.*


|URL|SHAsum|Remarks|
|----------------|---------------|------------|
|[gcc-linaro-6.4.1-2018.10-x86_64_arm-linux-gnueabihf.tar.xz](https://drive.google.com/open?id=1s67nRSYZtLkIlRDz-BsDPkBXaTA94tsZ)|2b88b6c619e0b28f6493e1b7971c327574ffdb36|RASPBIAN STRETCH|


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

## Cross Compile WebRTC native code package

Please refer to [README_building.md document](https://github.com/kclyu/rpi-webrtc-streamer/blob/master/README_building.md) document of Rpi-WebRTC-Streamer for WebRTC native code package Cross Compile method.
 
