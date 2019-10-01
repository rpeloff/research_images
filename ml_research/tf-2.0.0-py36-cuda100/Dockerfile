# ------------------------------------------------------------------------------
# Docker image for deep learning research in TensorFlow with common tools.
#
# Author: Ryan Eloff
# Contact: ryan.peter.eloff@gmail.com
# Date: September 2019
# ------------------------------------------------------------------------------
# Based on the TensorFlow image from https://github.com/rpeloff/research-images.
# Usage with nvidia-docker:
#   $ nvidia-docker run -it --name my_container <image-build-tag> bash
# ------------------------------------------------------------------------------
# Build:
#   $ docker build -t reloff/ml-research:tf-2.0.0-py36-cuda100 .
# ------------------------------------------------------------------------------
FROM reloff/tensorflow-base:2.0.0-py36-cuda100
LABEL author="Ryan Eloff" date="30-09-2019"
# ------------------------------------------------------------------------------
# Install requirements from requirements.txt
# ------------------------------------------------------------------------------
COPY requirements.txt /tmp
RUN python -m pip --no-cache-dir install --upgrade -r /tmp/requirements.txt \
&& rm -rf /tmp/*
# ------------------------------------------------------------------------------
# Install graphviz (plotting Keras models) and sudo
# ------------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    graphviz \
    sudo \
&& apt-get clean \
&& apt-get autoremove \
&& rm -rf /var/lib/apt/lists/* \
          /etc/apt/sources.list.d/*
# ------------------------------------------------------------------------------
# Create user and group docker:docker with uid 1000:1000 and passwordless SUDO
# ------------------------------------------------------------------------------
RUN groupadd -r -g 1000 docker \
&& useradd --no-log-init --create-home -r -g 1000 -u 1000 docker \
&& adduser docker sudo \
&& echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
# ------------------------------------------------------------------------------
# Set default command to '/bin/sh -c bash'
# ------------------------------------------------------------------------------
CMD ["bash"]
