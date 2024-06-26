#!/usr/bin/env bash

set -e

export ARCHIVE_DIR="/tmp/archive"

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
COMM_DIR="$(cd "${CUR_DIR}/../common" && pwd -P)"

# 1) Install some dependencies via apt
apt-get -y update && \
    apt-get -y install --no-install-recommends \
    libcgal-dev \
    pcl-tools \
    ros-${ROS_DISTRO}-cv-bridge \
    ros-${ROS_DISTRO}-tf \
    ros-${ROS_DISTRO}-message-filters \
    ros-${ROS_DISTRO}-image-transport \
    ros-${ROS_DISTRO}-image-transport* 

# 2) Install dependencies via buiding from source
# Eigen3 and OpenCV should be installed first as they may be 
# the dependencies of other libs
bash ${COMM_DIR}/install_eigen3.sh      3.3.4
# Ceres should be installed only after eigen installed
bash ${COMM_DIR}/install_ceres.sh       1.14.0
# Install protobuf 3.5.1 before installing opencv
# https://github.com/opencv/opencv/issues/18110
bash ${COMM_DIR}/install_protobuf3.sh   3.5.1
bash ${COMM_DIR}/install_opencv.sh      3.4.16

bash ${COMM_DIR}/install_livox_sdk2.sh 
bash ${COMM_DIR}/install_livox_ros_driver2.sh

bash ${COMM_DIR}/install_livox_sdk.sh 
bash ${COMM_DIR}/install_livox_ros_driver.sh

# Clean up cache to reduce layer size.
apt-get clean && \
    rm -rf /var/lib/apt/lists/*

