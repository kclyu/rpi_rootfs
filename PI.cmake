##
## Raspberry PI cmake toolchain 
##
## Usage : cmake -DCMAKE_TOOLCHAIN_FILE=~/Workspace/rpi_rootfs/PI.cmake  -DCMAKE_BUILD_TYPE=Debug ..
## 
## 
## 
## Poco Library Build example:
##         cmake -DCMAKE_TOOLCHAIN_FILE=~/Workspace/rpi_rootfs/PI.cmake  -DCMAKE_BUILD_TYPE=Debug .. -DENABLE_MONGODB=OFF -DENABLE_DATA=OFF -DPOCO_STATIC=ON
##
## websocketpp Build example:
##          cmake -DCMAKE_TOOLCHAIN_FILE=~/Workspace/rpi_rootfs/PI.cmake  -DCMAKE_BUILD_TYPE=Debug .. -DBUILD_EXAMPLES=ON -DENABLE_CPP11=ON
##
## cpprestsdk Build example:
##          cmake -DCMAKE_TOOLCHAIN_FILE=~/Workspace/rpi_rootfs/PI.cmake  -DCMAKE_BUILD_TYPE=Debug ..
##
## libwebsockets Build example:
##          cmake -DCMAKE_TOOLCHAIN_FILE=~/Workspace/rpi_rootfs/PI.cmake  -DCMAKE_BUILD_TYPE=Debug ..  -DLWS_WITH_SHARED=OFF
##          cmake -DCMAKE_TOOLCHAIN_FILE=~/Workspace/rpi_rootfs/PI.cmake  -DCMAKE_BUILD_TYPE=Debug .. -DLWS_WITH_SHARED=OFF -DLWS_WITH_LIBUV=OFF -DLWS_SSL_CLIENT_USE_OS_CA_CERTS=OFF -DLWS_WITHOUT_DAEMONIZE=OFF -DLWS_WITH_HTTP2=ON  -DLWS_SSL_SERVER_WITH_ECDH_CERT=ON
##
##

cmake_minimum_required(VERSION 3.0.0 FATAL_ERROR)

SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_PROCESSOR arm)

## Target Sysroot environment
SET(CMAKE_SYSROOT $ENV{HOME}/Workspace/rpi_rootfs )
SET(CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT})


## Adding manual flags
#SET( CMAKE_CXX_FLAGS           "-std=c++11"                        CACHE STRING "c++ flags" )
#SET( CMAKE_C_FLAGS             ""                        CACHE STRING "c flags" )
#SET( CMAKE_CXX_FLAGS_RELEASE   "-O3 -DNDEBUG"            CACHE STRING "c++ Release flags" )
#SET( CMAKE_C_FLAGS_RELEASE     "-O3 -DNDEBUG"            CACHE STRING "c Release flags" )
#SET( CMAKE_CXX_FLAGS_DEBUG     "-O0 -g -DDEBUG -D_DEBUG" CACHE STRING "c++ Debug flags" )
#SET( CMAKE_C_FLAGS_DEBUG       "-O0 -g -DDEBUG -D_DEBUG" CACHE STRING "c Debug flags" )
#SET( CMAKE_SHARED_LINKER_FLAGS ""                        CACHE STRING "shared linker flags" )
#SET( CMAKE_MODULE_LINKER_FLAGS ""                        CACHE STRING "module linker flags" )
#SET( CMAKE_EXE_LINKER_FLAGS    "-Wl,-z,nocopyreloc"      CACHE STRING "executable linker flags" )

##
#SET(WARNINGS "-Wall -Wextra -Wcast-qual -Wconversion -Wformat=2 -Winit-self -Winvalid-pch -Wmissing-form    at-attribute -Wmissing-include-dirs -Wpacked -Wredundant-decls" )

## Additional Flags
#SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}" CACHE INTERNAL "" FORCE)
#SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}"  CACHE INTERNAL "" FORCE)
#SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_DL_LIBS}"  CACHE INTERNAL "" FORCE)
SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -ldl"  CACHE INTERNAL "" FORCE)


##
## Compiler Binary 
# rpi_tools gcc 4.7.1
#SET(RPI_TOOLS_BASE /opt/rpi_tools/arm-bcm2708/arm-bcm2708-linux-gnueabi)
#SET(BIN_PREFIX arm-bcm2708-linux-gnueabi)

# Custom build GCC  (gcc 4.9.4)
SET(RPI_TOOLS_BASE $ENV{HOME}/tools/rpi_tools/arm-linux-gnueabihf)
SET(BIN_PREFIX arm-linux-gnueabihf)

SET (CMAKE_C_COMPILER ${RPI_TOOLS_BASE}/bin/${BIN_PREFIX}-gcc)
SET (CMAKE_CXX_COMPILER ${RPI_TOOLS_BASE}/bin/${BIN_PREFIX}-g++ )
SET (CMAKE_LINKER ${RPI_TOOLS_BASE}/bin/${BIN_PREFIX}-ld 
            CACHE STRING "Set the cross-compiler tool LD" FORCE)
SET (CMAKE_AR ${RPI_TOOLS_BASE}/bin/${BIN_PREFIX}-ar 
            CACHE STRING "Set the cross-compiler tool AR" FORCE)
SET (CMAKE_NM ${RPI_TOOLS_BASE}/bin/${BIN_PREFIX}-nm 
            CACHE STRING "Set the cross-compiler tool NM" FORCE)
SET (CMAKE_OBJCOPY ${RPI_TOOLS_BASE}/bin/${BIN_PREFIX}-objcopy 
            CACHE STRING "Set the cross-compiler tool OBJCOPY" FORCE)
SET (CMAKE_OBJDUMP ${RPI_TOOLS_BASE}/bin/${BIN_PREFIX}-objdump 
            CACHE STRING "Set the cross-compiler tool OBJDUMP" FORCE)
SET (CMAKE_RANLIB ${RPI_TOOLS_BASE}/bin/${BIN_PREFIX}-ranlib 
            CACHE STRING "Set the cross-compiler tool RANLIB" FORCE)
SET (CMAKE_STRIP ${RPI_TOOLS_BASE}/bin/${BIN_PREFIX}-strip 
            CACHE STRING "Set the cross-compiler tool RANLIB" FORCE)

##
##
SET (BOOST_ROOT  ${CMAKE_SYSROOT}/usr/local/boost)
SET (BOOST_LIBRARYDIR  ${CMAKE_SYSROOT}/usr/local/boost/lib)

add_definitions("-DBOOST_COROUTINES_NO_DEPRECATION_WARNING")
add_compile_options(-mfpu=neon-vfpv4 -mfloat-abi=hard -funsafe-math-optimizations)

SET(OPENSSL_FOUND TRUE)
SET(OPENSSL_ROOT_DIR ${CMAKE_SYSROOT}/usr/include/openssl)
SET(OPENSSL_INCLUDE_DIRS
    "${CMAKE_SYSROOT}/usr/include/openssl" 
    "${CMAKE_SYSROOT}/usr/include/arm-linux-gnueabihf" )
SET(OPENSSL_LIBRARIES
    "${CMAKE_SYSROOT}/usr/lib/arm-linux-gnueabihf/libssl.a"
    "${CMAKE_SYSROOT}/usr/lib/arm-linux-gnueabihf/libcrypto.a" )


OPTION(BUILD_SHARED_LIBS "Build shared Libraries." OFF)

## dump some variables 
#MESSAGE( STATUS "CMAKE_C_FLAGS : " ${CMAKE_C_FLAGS} )
#MESSAGE( STATUS "CMAKE_CXX_FLAGS : " ${CMAKE_CXX_FLAGS} )
#MESSAGE( STATUS "CMAKE_EXE_LINKER_FLAGS : " ${CMAKE_EXE_LINKER_FLAGS} )

##
##
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)


