# Docker Research Images

A repository for Docker images used to build research environments.

## TensorFlow Base

https://hub.docker.com/r/reloff/tensorflow-base/

Provides a minimal installation of TensorFlow (https://www.tensorflow.org/), intended to be used as the base image for TensorFlow research environments.

Currently provides only Ubuntu 16.04 (with CUDA+cuDNN) and Python 3.6 Docker images. Requires `nvidia-docker` (https://github.com/NVIDIA/nvidia-docker) to run containers with GPU support.

## Kaldi

https://hub.docker.com/r/reloff/kaldi/

Provides the Kaldi Speech Recognition Toolkit (http://kaldi-asr.org) in a simple Docker image. 

Kaldi is currently built from fork https://github.com/rpeloff/kaldi/tree/5.4 on the official Ubuntu 16.04 Docker image. Source and tools are located at `/kaldi`.
