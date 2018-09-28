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
#   $ docker build --build-arg N_BUILD_CORES=12 -t reloff/kaldi:latest .
# ------------------------------------------------------------------------------
FROM ubuntu:16.04
LABEL author="Ryan Eloff" date="28-09-2018"
# ------------------------------------------------------------------------------
# Define number of cores to use when building Kaldi (default 8)
# ------------------------------------------------------------------------------
ARG N_BUILD_CORES=8
# ------------------------------------------------------------------------------
# Install packages required to fetch and install Kaldi
# ------------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    git \
    ca-certificates \
    python2.7 \
    python3 \
    libtool-bin \
    g++ \
&& ln -s /usr/bin/python2.7 /usr/bin/python \
&& rm -rf /var/lib/apt/lists/*
# ------------------------------------------------------------------------------
# Clone the Kaldi repo, forked at commit #2567
# ------------------------------------------------------------------------------
RUN git clone --depth 1 https://github.com/rpeloff/kaldi.git /kaldi
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
# Set / as the default working directory
# ------------------------------------------------------------------------------
WORKDIR /
# ------------------------------------------------------------------------------
# Set default command to '/bin/sh -c bash'
# ------------------------------------------------------------------------------
CMD ["bash"]
