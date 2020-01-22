# This Dockerfile must be used in docker executed by build_rootfs.sh 
# in rpi_rootfs. If run alone, the gdrive_download.sh and rootfs.tar 
# file for Raspberry PI Rootfs must exist in the Docker directory.
#
# build:
#	sudo docker build --rm -t rpi_rootfs:0.74 . 
# container run:
#   sudo docker container run --rm -it rpi_rootfs:0.74
#

FROM ubuntu:18.04
LABEL maintainer="lyu.keun.chang@gmail.com"
LABEL version="0.74"
LABEL description="Rootfs creation tool for Raspberry PI \
	cross-compile environment"

# Making rootfs
ENV HOME /root/
ENV RPI_ROOTFS /root/Workspace/rpi_rootfs/rootfs
ENV RPI_TOOLS /root/Workspace/rpi_rootfs/tools
RUN apt update &&  apt install -y git \
   wget \ 
   xz-utils \
   pkg-config \
   cmake \ 
   unzip \
   gawk

RUN mkdir -p ${RPI_ROOTFS}
# The rootfs for docker uses tarball that exclude files not used 
# in gcc compilation, such as binaries, python, perl to reduce 
# the amount of disk space used.
ADD /rootfs.tar ${RPI_ROOTFS}

#  Download Custom Compiled GCC from Google Drive
RUN mkdir -p ${RPI_TOOLS}
ADD ./gdrive_download.sh ${RPI_TOOLS}
ENV GCC_VERION gcc-linaro-8.3.0-2019.03-x86_64_arm-linux-gnueabihf
ENV GCC_DOWNLOAD ${GCC_VERSION}.tar.xz
WORKDIR ${RPI_TOOLS}
RUN ./gdrive_download.sh 1q7Zk-7NhVROrBBWVgm56PbndZauSZL27 ${GCC_DOWNLOAD}
RUN xz -dc  ${GCC_DOWNLOAD} | tar xf -
RUN ln -sf ${GCC_VERION} arm-linux-gnueabihf && \ 
		cd /opt &&  ln -sf /root/Workspace/rpi_rootfs
ENV PATH="${PATH}:/opt/rpi_rootfs/tools/arm-linux-gnueabihf/bin"
ENV HOME /root/

