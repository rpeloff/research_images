# ------------------------------------------------------------------------------
# Docker image for the Kaldi Speech Recognition Toolkit (http://kaldi-asr.org).
#
# Author: Ryan Eloff
# Contact: ryan.peter.eloff@gmail.com
# Date: July 2018
# ------------------------------------------------------------------------------
# Image based on the Kaldi fork https://github.com/rpeloff/kaldi.
# ------------------------------------------------------------------------------
# NOTE: Specify the number of cores used to build Kaldi with N_BUILD_CORES:
#   $ docker build --build-arg N_BUILD_CORES=8 -t reloff/kaldi:latest .
# ------------------------------------------------------------------------------
FROM ubuntu:16.04
LABEL author="Ryan Eloff" date="01-10-2018"
# ------------------------------------------------------------------------------
# Define number of cores to use when building Kaldi (default 8)
# ------------------------------------------------------------------------------
ARG N_BUILD_CORES=8
# ------------------------------------------------------------------------------
# Install packages required to fetch and install Kaldi, including 
# Python 3.6 from the deadsnakes PPA (Python 2.7 linked as default)
# ------------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    git \
    ca-certificates \
    python2.7 \
    python2.7-dev \
    libtool-bin \
    g++ \
    curl \
    software-properties-common \
    sudo \
&& ln -s /usr/bin/python2.7 /usr/bin/python2 \
&& ln -s /usr/bin/python2.7 /usr/bin/python \
&& add-apt-repository ppa:deadsnakes/ppa \
&& apt-get update && apt-get install -y --no-install-recommends \
    python3.6 \
    python3.6-dev \
&& curl https://bootstrap.pypa.io/get-pip.py | python3.6 \
&& ln -s /usr/bin/python3.6 /usr/local/bin/python3 \
&& python3 -m pip --no-cache-dir install --upgrade setuptools \
&& apt-get clean \
&& apt-get autoremove \
&& rm -rf /var/lib/apt/lists/* \
          /etc/apt/sources.list.d/*
# ------------------------------------------------------------------------------
# Clone branch 5.4 of the Kaldi official repo, forked at commit #2742
# ------------------------------------------------------------------------------
RUN git clone --depth 1 -b 5.4 --single-branch \
    https://github.com/rpeloff/kaldi.git /kaldi
# ------------------------------------------------------------------------------
# Install additional Kaldi dependencies
# ------------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    $(/kaldi/tools/extras/check_dependencies.sh | grep "sudo apt-get" | while read -r cmd_input; do echo ${cmd_input#"sudo apt-get install"}; done) \
&& rm -rf /var/lib/apt/lists/*
# ------------------------------------------------------------------------------
# Install required tools
# ------------------------------------------------------------------------------
WORKDIR /kaldi/tools
RUN make -j ${N_BUILD_CORES}
# ------------------------------------------------------------------------------
# Configure and install Kaldi using shared libraries
# ------------------------------------------------------------------------------
WORKDIR /kaldi/src
RUN ./configure --shared \
    && make depend -j ${N_BUILD_CORES} \
    && make -j ${N_BUILD_CORES}
# ------------------------------------------------------------------------------
# Set / as default working directory and '/bin/sh -c bash' as default command
# ------------------------------------------------------------------------------
WORKDIR /
CMD ["bash"]
