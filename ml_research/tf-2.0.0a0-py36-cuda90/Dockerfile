# ------------------------------------------------------------------------------
# Docker image for deep learning research in TensorFlow with common tools.
#
# Author: Ryan Eloff
# Contact: ryan.peter.eloff@gmail.com
# Date: April 2019
# ------------------------------------------------------------------------------
# Based on the TensorFlow image from https://github.com/rpeloff/research-images.
# Usage with nvidia-docker:
#   $ nvidia-docker run -it --name my_container <image-build-tag> bash
# ------------------------------------------------------------------------------
# Build:
#   $ docker build -t reloff/ml-research:tf-2.0.0a0-py36-cuda90 .
# ------------------------------------------------------------------------------
FROM reloff/tensorflow-base:2.0.0a0-py36-cuda90
LABEL author="Ryan Eloff" date="12-04-2019"
# ------------------------------------------------------------------------------
# Install requirements from requirements.txt
# ------------------------------------------------------------------------------
COPY requirements.txt /tmp
RUN python -m pip --no-cache-dir install --upgrade -r /tmp/requirements.txt \
&& rm -rf /tmp/*
# ------------------------------------------------------------------------------
# Set default command to '/bin/sh -c bash'
# ------------------------------------------------------------------------------
CMD ["bash"]
