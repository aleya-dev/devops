FROM ubuntu:23.04

ENV DEBIAN_FRONTEND=noninteractive

# Perform full update and install common utilities
RUN \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get autoremove && \
    apt-get autoclean && \
    apt-get -y install \
        build-essential \
        cmake \
        ca-certificates \
        wget \
        make \
        git \
        nasm \
        curl \
        python3 \
        python3-pip \
        python-is-python3 \
        libssl-dev \
        gnupg \
        apt-transport-https \
      && \
    apt-get autoclean

run python3 -m pip install conan --break-system-packages
run conan profile detect

add https://github.com/Kitware/CMake/releases/download/v3.27.0-rc3/cmake-3.27.0-rc3-linux-x86_64.tar.gz /cmake.tar.gz
run tar xf cmake.tar.gz && rm cmake.tar.gz
run export PATH=$(find / -name cmake*-linux-x86_64)/bin:$PATH
