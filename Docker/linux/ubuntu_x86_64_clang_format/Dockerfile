FROM ubuntu:23.10

RUN \
    apt-get update && \
    apt-get -y install \
        git \
        python3 \
        python-is-python3 \
        clang-format-17 \
      && \
    apt-get autoclean

RUN ln -s /usr/bin/clang-format-17 /usr/bin/clang-format
