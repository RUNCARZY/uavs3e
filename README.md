# uavs3e realtime 
 uavs3e is an opensource avs3 encoder, supports AVS3-P2 baseline profile. <br>
 features:
 1) AVS3-P2 baseline profile.
 2) supports to compile for Windows/Linux systems.
 3) optimized for SSE4/AVX2/ARMV8 NEON chips.
 4) 10bit encoding on all supported platforms (without SIMD).
 5) The uavs3 codec has supported x86 and arm platforms, and has been tested and verified on the Kunpeng processor. 
 6) The ARM platform recommends the Kunpeng processor.
 
# license
  Copyright reserved by “Peking University Shenzhen Graduate School”, “Peng Cheng Laboratory”, and “Guangdong Bohua UHD Innovation Corporation” <br><br>
  This program is a free software. You can redistribute it and/or modify it under the terms of the BSD 4-clause license. <br>
  For more details, please view the file "COPYING" in the project.
  
# compile
  The default configuration only support 8bit decoding. <br>
  To support 10bit streams decoding: CMAKE -DCOMPILE_10BIT=1

## windows
Prerequisites:
  Visual Studio 2017

build:
  1. ./version.bat (to generate version.h)
  2. solution file: uAVS3.sln 
  
  To support 10bit streams decoding, edit uAVS3lib/uAVS3lib.h : #define COMPILE_10BIT 1

## linux
Prerequisites:
  1. gawk (http://www.gnu.org/software/gawk/)
  2. CMake (https://cmake.org) version 2.8 or higher
  
Build:
  1. mkdir build
  2. cd build && cmake ..
  3. make && make install

  to build shared library, set BUILD_SHARED_LIBS=1 please.
  To support 10bit streams decoding: CMAKE -DCOMPILE_10BIT=1 ..

# Run tests
## window/linux

  uavs3e [-f file] [-p param=ParameterValue]

     --f file    
             All Parameters are initially taken from the 'file', typically: "bin/encode_ra.cfg".

     -p param = ParameterValue
             If parameters are present, then the ParameterValue will override the default settings in the configuration file.


# Contributors
This program is originally developed by the team of Prof.Ronggang Wang (rgwang@pkusz.edu.cn) at Peking University Shenzhen Graduate School. <br>

* Main contributors:  
  * Zhenyu Wang (wangzhenyu@pkusz.edu.cn), Peking University Shenzhen Graduate School. 
  * Bingjie Han (hanbj@pkusz.edu.cn), Peking University Shenzhen Graduate School. 
  * Jiang Du, Peking University Shenzhen Graduate School. 
  * Kui Fan, Peking University Shenzhen Graduate School. 
  * Xi Xie, Peking University Shenzhen Graduate School. 
  * Shengyuan Wu, Peking University Shenzhen Graduate School. 
  * Tong Wu, Peking University Shenzhen Graduate School. 
  * Shiyi Liu, Peking University Shenzhen Graduate School. 
  * Jiayu Yang, Peking University Shenzhen Graduate School. 
  * Chunhui Yang, Peking University Shenzhen Graduate School.
  * Dapeng Chen, Bigo Technology Pte. Ltd 
  * Jin Lin, Harbin Institute of Technology, Shenzhen.
  * Yi Ma, Peking University Shenzhen Graduate School. 
  * Litian Li, Peking University Shenzhen Graduate School. 
  * Guisen Xu, Peking University Shenzhen Graduate School. 
  * Xufeng Li, Peking University Shenzhen Graduate School. 
  * Yangang Cai, Peking University Shenzhen Graduate School. 
  * Hao Lv, Peng Cheng Laboratory. 
  * Ronggang Wang (rgwang@pkusz.edu.cn), Peking University Shenzhen Graduate School

  # XueliCheng
  # luofl

# References
*This program also refers to the following fast algorithm:
  * 陈焕浜, 杨海涛. SMVD编码加速. AVS技术提案, M5218. 2020年3月.
  * 赵寅, 杨海涛. 块划分快速算法. AVS技术提案, M5137. 2020年3月.
  * 张焕宸, 陈雅梅, 喻莉. 基于灰度共生矩阵与编码信息的帧内预测快速算法. AVS技术提案, M5327.
