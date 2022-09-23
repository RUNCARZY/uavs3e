cmake_minimum_required(VERSION 2.8)

project(uAVS3)

if(${COMPILE_10BIT})
    add_definitions(-DCOMPILE_10BIT=1)
else()
    add_definitions(-DCOMPILE_10BIT=0)
endif()

add_subdirectory(uAVS3lib)

add_executable(uAVS3 ./utest.c)
add_executable(uAVS3_gop ./utest_gop.c)

target_link_libraries(uAVS3 uavs3e)
target_link_libraries(uAVS3_gop uavs3e)