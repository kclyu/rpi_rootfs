# RootFS for Raspberry PI
This repo provides tools to create rootfs so that you can create a cross compile environment for Raspberry PI on Ubuntu Linux using bash script and python.

There are two ways to create rootfs. The first is to create a rootfs directly using a Raspbian OS image file. The other way is to create a rootfs using rsync from the Raspberry PI hardware you're already running.

And, this repo provide google Drive Link to download Custom Compiled GCC. If you are not familiar with cross compiler and do not have your own cross compiler, please download and use GCC from `Custom Compiled GCC for Raspberry PI` below.

For an example of compiling OpenCV and ffmpeg, see the `Cross Compiling Examples` section below.


## Making RootFS with Raspbian OS image file
```
cd ~/Workspace/rpi_rootfs
./build_rootfs.sh
Usage: .//build_rootfs.sh command [options]
  command:
    download : download latest RaspiOS image
    create [image file]:
      [image file]: raspi OS image zip/img file
    update : run apt update & full-upgrade & autoremove in rootfs
    run [command]: run raspberry pi command in rootfs
      [command]: should be escaped with double-quote and
      command need to be full path of command
      e.g. ./build_rootfs.sh run "/usr/bin/apt -y libpulse-dev"
        - install libpulse-dev package in rootfs
      e.g. ./build_rootfs.sh run "/usr/bin/apt autoremove"
        - run apt autoremove in rootfs
    clean : removing rootfs
    docker : build rpi_rootfs docker image
./build_rootfs.sh create ./2020-MM-DD-raspios-buster-armhf.img  # note1
```
*note1 : Download the image file from [Raspberry PI download page](https://www.raspberrypi.org/downloads/raspberry-pi-os/) and if possible, use the img file after unzip the img.zip file after download completed.*
## Making RootFS with rsync 
```
cd ~/Workspace/rpi_rootfs
mkdir -p rootfs
./rpi_rootfs.py 
Usage: ./rpi_rootfs.py @hostname> <rootfs path>
./rpi_rootfs.py pi@your-raspberry-pi-ipaddress rootfs
```
*When rpi_rootfs.py is executed, many messages are output to console during the sync list of files and library link fixing. Please ignore the messages.*

If you installed a new library or software on Raspberry PI, please execute it again to apply the changed part.

## Custom Compiled GCC for Raspberry PI

```
cd ~/Workspace/rpi_rootfs
mkdir tools
cd tools
../scripts/gdrive_download.sh 1q7Zk-7NhVROrBBWVgm56PbndZauSZL27 gcc-linaro-8.3.0-2019.03-x86_64_arm-linux-gnueabihf.tar.xz
#...
#Saving to: ‘gcc-linaro-8.3.0-2019.03-x86_64_arm-linux-gnueabihf.tar.xz’
#...
xz -dc gcc-linaro-8.3.0-2019.03-x86_64_arm-linux-gnueabihf.tar.xz  | tar xvf -
ln -sf gcc-linaro-8.3.0-2019.03-x86_64_arm-linux-gnueabihf  arm-linux-gnueabihf
cd /opt
sudo ln -sf ~/Workspace/rpi_rootfs
export PATH=/opt/rpi_rootfs/tools/arm-linux-gnueabihf/bin:$PATH
```

| URL| md5sum | Remarks|
| -------------------------------------------------------------------------------------------------------------------------------- | -------------------------------- | --------------- |
| [gcc-linaro-8.3.0-2019.03-x86_64_arm-linux-gnueabihf.tar.xz](https://drive.google.com/open?id=1q7Zk-7NhVROrBBWVgm56PbndZauSZL27) | 633025d696d55ca0a3a099be8e34db23 | Raspbian Buster |


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

Please refer to [README_building.md document](https://github.com/kclyu/rpi-webrtc-streamer/blob/master/README_building.md) document of Rpi-WebRTC-Streamer for WebRTC native code package Cross Compile.
 
