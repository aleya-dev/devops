FROM ubuntu:23.04

ARG CMAKE_VERSION=3.27.5

ENV DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get update && \
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
        libvulkan-dev \
        xorg-dev \
      && \
    apt-get autoclean

run python3 -m pip install conan --break-system-packages
run conan profile detect

add https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz /cmake/
run export PATH=/cmake/:$PATH
