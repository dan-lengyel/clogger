cmake_minimum_required(VERSION 3.0)
project(clogger VERSION 1.0.0)

set(SOURCES src/main.c)
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

add_executable(clogger ${SOURCES})

target_include_directories(clogger PRIVATE src/zlog-1.2.15)
#find_package(zlog CONFIG)
target_link_libraries(${PROJECT_NAME} PRIVATE zlog)
target_link_libraries(${PROJECT_NAME} PRIVATE Threads::Threads)