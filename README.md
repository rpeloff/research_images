# Docker Research Images

This repository contains a collection of Docker images that I have used to set up my research environments. Inspired by the [_Deepo_](https://github.com/ufoym/deepo) series of Docker images.

## ML Research

<a href="https://hub.docker.com/r/reloff/ml-research/">
    <img src="https://img.shields.io/badge/Docker Hub-reloff/ml--research-ff69b4.svg?longCache=true&style=for-the-badge"
    alt="Image on Docker Hub"></a>

Machine learning research environment including common tools for model development and data analysis. Built upon the TensorFlow Base images (PyTorch Base tags to be added :slightly_smiling_face:). See image tags on Docker Hub for the TensorFlow versions that I am currently building/using. See also the included libraries and their versions in `ml_research/<image_tag>/requirements.txt`.

## Run Docker Environment Script

I have included a script `run_docker_env.sh` that I use to spin up docker containers. This is useful with my `reloff/ml-research` image to quickly setup machine learning research environments without the hassle of messing with Docker parameters to mount folders, set file ownership, etc. This inlcudes optional sudo with `--sudo`, so that your files are owned by you by default, access to the `nvidia-docker` GPU runtime with a simple `--nvidia-gpu` flag, access to Jupyter Lab or Notebook, easy volume mounting, and other convenience options. See `run_docker_env.sh --help` for more info.

To install on a local level, run `./install_docker_env.sh`. You should then have access to the docker environment script `run_docker_env.sh` from anywhere on your machine.

## TensorFlow Base

<a href="https://hub.docker.com/r/reloff/tensorflow-base/">
    <img src="https://img.shields.io/badge/Docker Hub-reloff/tensorflow--base-ff69b4.svg?longCache=true&style=for-the-badge"
    alt="Image on Docker Hub"></a>

Provides a minimal installation of TensorFlow (https://www.tensorflow.org/) (1.x and 2.x) with GPU support on Ubuntu, intended to be used as a base image for TensorFlow research environments.

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
