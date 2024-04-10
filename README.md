# SLAM Development Docker
Since there isn't an official package manager for C/C++, its always time-consuming and annoying to benchmark and develop various SLAM algorithm. Since the algorithms have various third parties with different version. This repo aims to provide reusable installer scripts for commonly used SLAM third-party libraries and merge them all together into various base Docker containers. Based on this repo, you may customize your environment to quickly run different SLAM algorithms for comparison, maintain a consitent SLAM development environment, or distribute your own SLAM algorithm with the container for rapid spread. Only the run-time environments are provided, the SLAM source codes and datasets are mounted into the container. In this way, you can modify the codes and datasets at any time while keeping the docker image consistent.

A bunch of popular SLAM algorithms are well tested and listed as follows:

| CI Status       | Dockerfile     | SLAM algorithm (commit link)       |
| ------------------------------------------------------------ | ---------- | ------------------------------------------------------------ | 
| ![Build Status](https://github.com/sqn175/slam_dev_docker/actions/workflows/docker-image-orb-slam.yml/badge.svg) | Dockerfile.orb-slam | [ORB_SLAM2](), [ORB_SLAM3]() | 
| ![Build Status](https://github.com/sqn175/slam_dev_docker/actions/workflows/docker-image-r3live.yml/badge.svg) | Dockerfile.r3live | [r3live](), [FAST-LIO(2.0)](https://github.com/hku-mars/FAST_LIO/commit/5d9dc72523f465633d57bb9c3ac4e3f4fdaffb4c), [LIO-Livox](https://github.com/Livox-SDK/LIO-Livox/commit/2296e4bea59bcfec09624a6f052fd6bfbe2b1e6a)    | 
| ![Build Status](https://github.com/sqn175/slam_dev_docker/actions/workflows/docker-image-faster-lio.yml/badge.svg) | Dockerfile.faster-lio  | [Faster-LIO](https://github.com/gaoxiang12/faster-lio/commit/6f6f1d6ea97071902a82c138f3359d4711873e2b), [DLIO](https://github.com/vectr-ucla/direct_lidar_inertial_odometry/commit/75c875f0088b498a9d6453f3ab003d6ab853ad85)                 |
| ![Build Status](https://github.com/sqn175/slam_dev_docker/actions/workflows/docker-image-bad-slam.yml/badge.svg) | BAD-SLAM   | [BAD SLAM]()                 |


## Requirement

Docker installed. [Install Docker Engine](https://docs.docker.com/engine/install/)

## Basic Usage

1. Build the Docker image:

   ```
   ./build.sh Dockerfile.image-name
   ```

   This will build a Docker image named `image-name:latest`. Change `Dockerfile.image-name` to yours.

2. Run the Docker image:

   ```
   ./run.sh image-name
   ```

   This will run Docker image `image-name` as a container. The container will mount the host source directory. 
   The `HOST_SOURCE_DIR` in `run.sh` specifies the directory.

3. Enjoy!

## How to customize

1. Create a third_party lib installer script, e.g., `installers/3rdparties_slam/slam.sh` , (like `orb_slam.sh`) to customize your third_party libs.

2. Create a Docker file, e.g., `Dockerfile.slam` which will run above script.

3. Build your container:

   ```
   ./build.sh Dockerfile.slam
   ```

   which will create a container named `slam`.

4. Run the container:

   ```
   ./run.sh slam
   ```

## Notes

1. The SLAM source code directory is mounted into the Docker container. Set `HOST_SOURCE_DIR="slam/source/dir"`  in `run.sh` , this will mount your host directory `slam/source/dir` into Docker directory `/home/slam/src` . You can mount your datasets by modifing `HOST_DATASET_DIR`.

2. Some source mirrors such as apt and python mirrors are modified to China mirrors to improve download speed for China mainland users.

3. You can manually pre-download third-party lib source code tarball files into archive dir for offline Docker building.

4. **Recommend** to develop your SLAM algorithm using **VS Code** inside the containers, just modify the the attributes of `./devcontainer/devcontainer.json`  in VSCode:

   ```json
   "build": {
        "dockerfile": "pathto/Dockerfile.ubuntu18-opengl",
   },
   ```

   See more details in [Developing inside a Container](https://code.visualstudio.com/docs/remote/containers).

5. **Welcome to contribute new installers needed for SLAM development and create new branches to host the State-of-the-Art SLAM algorithm development environments.**

## Acknowledgement
Some part of source code are adapted from [Baidu Apollo](https://github.com/ApolloAuto/apollo), which is licensed under the [Apache-2.0 license](https://github.com/ApolloAuto/apollo/blob/master/LICENSE).



