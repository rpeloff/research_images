# Docker Research Images

A repository for Docker images used to build research environments.

## TensorFlow Base

<a href="https://hub.docker.com/r/reloff/tensorflow-base/">
    <img src="https://img.shields.io/badge/Docker Hub-reloff/tensorflow--base-ff69b4.svg?longCache=true&style=for-the-badge"
    alt="Image on Docker Hub"></a>

Provides a minimal installation of TensorFlow (https://www.tensorflow.org/), intended to be used as a base image for TensorFlow research environments.

Currently provides only Ubuntu 16.04 (with CUDA+cuDNN) and Python 3.6 Docker images. Requires `nvidia-docker` (https://github.com/NVIDIA/nvidia-docker) to run containers with GPU support.

## PyTorch Base

<a href="https://hub.docker.com/r/reloff/pytorch-base/">
    <img src="https://img.shields.io/badge/Docker Hub-reloff/pytorch--base-ff69b4.svg?longCache=true&style=for-the-badge"
    alt="Image on Docker Hub"></a>

Provides a minimal installation of PyTorch (https://pytorch.org/), intended to be used as a base image for PyTorch research environments.

Currently provides only Ubuntu 16.04 (with CUDA+cuDNN) and Python 3.6 Docker images. Requires `nvidia-docker` (https://github.com/NVIDIA/nvidia-docker) to run containers with GPU support.

## Kaldi

<a href="https://hub.docker.com/r/reloff/kaldi/">
    <img src="https://img.shields.io/badge/Docker Hub-reloff/kaldi-ff69b4.svg?longCache=true&style=for-the-badge"
    alt="Image on Docker Hub"></a>


Provides the Kaldi Speech Recognition Toolkit (http://kaldi-asr.org) in a simple Docker image. 

Kaldi is currently built from fork https://github.com/rpeloff/kaldi/tree/5.4 on the official Ubuntu 16.04 Docker image. Source and tools are located at `/kaldi`.
