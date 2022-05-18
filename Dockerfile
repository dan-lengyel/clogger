# GCC support can be specified at major, minor, or micro version
# (e.g. 8, 8.2 or 8.2.0).
# See https://hub.docker.com/r/library/gcc/ for all supported GCC
# tags from Docker Hub.
# See https://docs.docker.com/samples/library/gcc/ for more on how to use this image
FROM gcc:latest

# These commands copy your files into the specified directory in the image
# and set that as the working location
COPY . /home/c-logging/
WORKDIR /home/c-logging/

# Install dependencies
RUN apt-get update && apt-get install -y \
    cmake \
    pkg-config \
    git \
    vim \
    psmisc

# Install zlog
RUN cd src && \
    wget https://github.com/HardySimpson/zlog/archive/refs/tags/1.2.15.tar.gz && \
    tar -zxvf 1.2.15.tar.gz && \
    cd zlog-1.2.15 && \
    make && \
    make install 

# Compile
RUN mkdir build && \
    cd build && \
    cmake .. && \
    make

# Update libraries
RUN ldconfig

# This command runs your application, comment out this line to compile only
CMD ["./build/clogger"]
#CMD tail -f /dev/null

LABEL Name=clogger Version=1.0.0
