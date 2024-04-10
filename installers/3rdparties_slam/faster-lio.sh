#!/usr/bin/env bash

set -e

export ARCHIVE_DIR="/tmp/archive"

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
COMM_DIR="$(cd "${CUR_DIR}/../common" && pwd -P)"

# 1) Install some dependencies via apt
apt-get -y update && \
    apt-get -y install --no-install-recommends \
    libgoogle-glog-dev \
    libeigen3-dev \
    libpcl-dev \
    libyaml-cpp-dev \
    libomp-dev \

# 2) Install dependencies via buiding from source
bash ${COMM_DIR}/install_livox_sdk2.sh 
bash ${COMM_DIR}/install_livox_ros_driver2.sh

# Clean up cache to reduce layer size.
apt-get clean && \
    rm -rf /var/lib/apt/lists/*

