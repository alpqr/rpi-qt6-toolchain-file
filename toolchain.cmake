cmake_minimum_required(VERSION 3.18)
include_guard(GLOBAL)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(TARGET_SYSROOT /home/agocs/rpi/sysroot)
set(CROSS_COMPILER /home/agocs/rpi/gcc8/bin)
#set(CROSS_COMPILER /home/agocs/rpi_yocto/sdk/sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi)

set(CMAKE_SYSROOT ${TARGET_SYSROOT})

set(ENV{PKG_CONFIG_PATH} "")
set(ENV{PKG_CONFIG_LIBDIR} ${CMAKE_SYSROOT}/usr/lib/arm-linux-gnueabihf/pkgconfig:${CMAKE_SYSROOT}/usr/share/pkgconfig)
set(ENV{PKG_CONFIG_SYSROOT_DIR} ${CMAKE_SYSROOT})

set(CMAKE_C_COMPILER ${CROSS_COMPILER}/arm-linux-gnueabihf-gcc)
set(CMAKE_CXX_COMPILER ${CROSS_COMPILER}/arm-linux-gnueabihf-g++)
#set(CMAKE_C_COMPILER ${CROSS_COMPILER}/arm-poky-linux-gnueabi-gcc)
#set(CMAKE_CXX_COMPILER ${CROSS_COMPILER}/arm-poky-linux-gnueabi-g++)

set(QT_COMPILER_FLAGS "-march=armv7-a -mfpu=neon -mfloat-abi=hard")
set(QT_COMPILER_FLAGS_RELEASE "-O2 -pipe")
set(QT_COMPILER_FLAGS_RELWITHDEBINFO "-O2 -pipe")
set(QT_LINKER_FLAGS "-Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed")

set(QT_LIB_DIRS "${CMAKE_SYSROOT}/lib;${CMAKE_SYSROOT}/lib/arm-linux-gnueabihf;${CMAKE_SYSROOT}/usr/lib/arm-linux-gnueabihf;${CMAKE_SYSROOT}/../qt6/lib")
foreach(QT_LIB_DIR ${QT_LIB_DIRS})
    string(APPEND QT_LINKER_FLAGS " -L${QT_LIB_DIR} -Wl,-rpath-link,${QT_LIB_DIR}")
endforeach()

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

include(CMakeInitializeConfigs)

function(cmake_initialize_per_config_variable _PREFIX _DOCSTRING)
  if (_PREFIX MATCHES "CMAKE_(C|CXX|ASM)_FLAGS")
    set(CMAKE_${CMAKE_MATCH_1}_FLAGS_INIT "${QT_COMPILER_FLAGS}")

    foreach (config DEBUG RELEASE MINSIZEREL RELWITHDEBINFO)
      if (DEFINED QT_COMPILER_FLAGS_${config})
        set(CMAKE_${CMAKE_MATCH_1}_FLAGS_${config}_INIT "${QT_COMPILER_FLAGS_${config}}")
      endif()
    endforeach()
  endif()

  if (_PREFIX MATCHES "CMAKE_(SHARED|MODULE|EXE)_LINKER_FLAGS")
    foreach (config SHARED MODULE EXE)
      set(CMAKE_${config}_LINKER_FLAGS_INIT "${QT_LINKER_FLAGS}")
    endforeach()
  endif()

  _cmake_initialize_per_config_variable(${ARGV})
endfunction()
