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
#   $ docker build -t reloff/ml-research:tf-1.13.1-py36-cuda100 .
# ------------------------------------------------------------------------------
FROM reloff/tensorflow-base:1.13.1-py36-cuda100
LABEL author="Ryan Eloff" date="12-04-2019"
# ------------------------------------------------------------------------------
# Install requirements from requirements.txt
# ------------------------------------------------------------------------------
COPY requirements.txt /tmp
RUN python -m pip --no-cache-dir install --upgrade -r /tmp/requirements.txt \
&& rm -rf /tmp/*
# ------------------------------------------------------------------------------
# Install code-server to VSCode on a remote server accessible from a browser
# ------------------------------------------------------------------------------
ARG code_server_version=1.939-vsc1.33.1
RUN apt-get update && apt-get install -y --no-install-recommends wget \
&& apt-get clean \
&& apt-get autoremove \
&& rm -rf /var/lib/apt/lists/* \
          /etc/apt/sources.list.d/* \
&& wget https://github.com/codercom/code-server/releases/download/${code_server_version}/code-server${code_server_version}-linux-x64.tar.gz \
&& tar -xzvf code-server${code_server_version}-linux-x64.tar.gz -C /usr/local/bin \
&& chmod +x /usr/local/bin/code-server${code_server_version}-linux-x64/code-server \
&& rm code-server${code_server_version}-linux-x64.tar.gz
ENV PATH="/usr/local/bin/code-server${code_server_version}-linux-x64:${PATH}"
# ------------------------------------------------------------------------------
# Set default command to '/bin/sh -c bash'
# ------------------------------------------------------------------------------
CMD ["bash"]
