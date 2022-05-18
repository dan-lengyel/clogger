#!/bin/bash
set -e

# Install zlog
cd src
wget https://github.com/HardySimpson/zlog/archive/refs/tags/1.2.15.tar.gz
tar -zxvf 1.2.15.tar.gz
rm 1.2.15.tar.gz
cd zlog-1.2.15
make
make install
cd ../..

# Build project
mkdir build
cd build
cmake ..
make
