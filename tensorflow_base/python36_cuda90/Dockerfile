# ------------------------------------------------------------------------------
# Simple TensorFlow Docker image for use as research base image.
#
# Author: Ryan Eloff
# Contact: ryan.peter.eloff@gmail.com
# Date: September 2018
# ------------------------------------------------------------------------------
# Based on the deep learning Docker images from https://github.com/ufoym/deepo.
# Usage with nvidia-docker:
#   $ nvidia-docker run -it --name my_container <image-build-tag> bash
# ------------------------------------------------------------------------------
# NOTE: Specify the TensorFlow GPU release version with TF_VERSION:
#   $ docker build --build-arg TF_VERSION=1.12.0 -t reloff/tensorflow-base:latest .
# ------------------------------------------------------------------------------
FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04
LABEL author="Ryan Eloff" date="11-04-2018"
# ------------------------------------------------------------------------------
# Install Python 3.6 from the deadsnakes PPA and link as default python
# ------------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    curl \
    software-properties-common \
&& add-apt-repository ppa:deadsnakes/ppa \
&& apt-get update && apt-get install -y --no-install-recommends \
    python3.6 \
    python3.6-dev \
&& curl https://bootstrap.pypa.io/get-pip.py | python3.6 \
&& ln -s /usr/bin/python3.6 /usr/local/bin/python3 \
&& ln -s /usr/bin/python3.6 /usr/local/bin/python \
&& python -m pip --no-cache-dir install --upgrade \
    setuptools \
&& apt-get clean \
&& apt-get autoremove \
&& rm -rf /var/lib/apt/lists/* \
          /etc/apt/sources.list.d/*
# ------------------------------------------------------------------------------
# Define TensorFlow GPU release version to install (defaults to latest release)
# ------------------------------------------------------------------------------
ARG TF_VERSION
# ------------------------------------------------------------------------------
# Install TensorFlow for GPU (==${TF_VERSION} if specified)
# ------------------------------------------------------------------------------
RUN python -m pip --no-cache-dir install --upgrade \
    tensorflow-gpu${TF_VERSION:+\=\=${TF_VERSION}}
# ------------------------------------------------------------------------------
# Set default command to '/bin/sh -c bash'
# ------------------------------------------------------------------------------
CMD ["bash"]
