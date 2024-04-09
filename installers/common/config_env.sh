#!/usr/bin/env bash

###############################################################################
# Copyright 2020 The Apollo Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
###############################################################################

# Part of this code is adapted from Baidu Apollo

# ROS GPG Key Expiration Incident error, see https://github.com/osrf/docker_images/issues/535
apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

DOCKER_USER="slam"
DOCKER_USER_ID=1000
DOCKER_GRP="slam"
DOCKER_GRP_ID=1000

function _create_user_account() {
  local user_name="$1"
  local uid="$2"
  local group_name="$3"
  local gid="$4"

  # Create the user
  addgroup --gid "${gid}" "${group_name}"
  adduser --disabled-password --force-badname --gecos '' \
    "${user_name}" --uid "${uid}" --gid "${gid}" # 2>/dev/null
  usermod -aG sudo "${user_name}"

  # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
  if [ ! -d /etc/sudoers.d/ ]; then
    mkdir /etc/sudoers.d/
  fi
  echo "$DOCKER_USER ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/$DOCKER_USER
  chmod 0440 /etc/sudoers.d/$DOCKER_USER
}

function setup_user_bashrc() {
  local uid="$1"
  local gid="$2"
  local user_home="/home/$3"
  # cp -rf /etc/skel/.{profile,bash*} "${user_home}"
  local RCFILES_DIR="/tmp/rcfiles"
  local rc
  if [[ -d "${RCFILES_DIR}" ]]; then
    for entry in ${RCFILES_DIR}/*; do
      rc=$(basename "${entry}")
      if [[ "${rc}" = user.* ]]; then
        cp -rf "${entry}" "${user_home}/${rc##user}"
      fi
    done
  fi
  # Set user files ownership to current user, such as .bashrc, .profile, etc.
  # chown -R "${uid}:${gid}" "${user_home}"
  chown -R "${uid}:${gid}" ${user_home}/.*
}

function setup_user_account_if_not_exist() {
  local user_name="$1"
  local uid="$2"
  local group_name="$3"
  local gid="$4"
  if grep -q "^${user_name}:" /etc/passwd; then
    echo "User ${user_name} already exist. Skip setting user account."
    return
  fi
  _create_user_account "$@"
  setup_user_bashrc "${uid}" "${gid}" "${user_name}"
}

function change_mirror_and_install_for_cn_user() {
  # Install prerequisite packages for apt
  apt-get -y update >/dev/null &&
    apt-get install -y --no-install-recommends \
      apt-utils \
      ca-certificates \
      apt-transport-https

  echo "Changing apt sources and ROS sources ..."
  # Change apt source mirror
  sed -i "s@http://archive.ubuntu.com/ubuntu/@https://mirrors.tuna.tsinghua.edu.cn/ubuntu/@g" /etc/apt/sources.list

  # Remove apt file for cuda since the connection to "developer.download.nvidia.com" is not always stable
  [ -e /etc/apt/sources.list.d/cuda.list ] && rm /etc/apt/sources.list.d/cuda.list
  [ -e /etc/apt/sources.list.d/nvidia-ml.list ] && rm /etc/apt/sources.list.d/nvidia-ml.list

  echo "Installing apt debs ..."
  apt-get -y update &&
    apt-get install -y --no-install-recommends \
      build-essential \
      cmake \
      ninja-build \
      autoconf \
      automake \
      bc \
      curl \
      file \
      gawk \
      gdb \
      git \
      libtool \
      less \
      lsof \
      patch \
      pkg-config \
      python3 \
      python3-dev \
      python3-pip \
      sed \
      software-properties-common \
      sudo \
      unzip \
      vim \
      wget \
      zip \
      xz-utils \
      tmux \
      htop \
      gnupg2

  # Set ROS1/2 mirror and source ROS env
  if [ ! -z "${ROS_DISTRO}" ]; then
    echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /home/${DOCKER_USER}/.bashrc

    if [ "${ROS_VERSION}" = "1" ]; then
      echo "deb https://mirrors.tuna.tsinghua.edu.cn/ros/ubuntu/ $(lsb_release -c --short) main" >/etc/apt/sources.list.d/ros-latest.list
      apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
      apt-get -y update
    elif [ "${ROS_VERSION}" = "2" ]; then
      curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/ros2/ubuntu jammy main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
      apt-get -y update
    fi
  fi

  # Set python3 as default
  update-alternatives --install /usr/bin/python python /usr/bin/python3 36

  # Depending on ROS version and respectively the one of rospkg we need to stick to python 2.x or 3.x. 
  # ROS Kinetic and ROS Melodic — Python2. ROS Noetic — Python3.
  # For detailed information, see https://www.ros.org/reps/rep-0151.html#context 
  [ -f "/opt/ros/${ROS_DISTRO}/setup.sh" ] && . /opt/ros/${ROS_DISTRO}/setup.sh
  if [ ! -z "${ROS_PYTHON_VERSION}" ] && [ "${ROS_PYTHON_VERSION}" == "2" ]; then
    update-alternatives --install /usr/bin/python python /usr/bin/python2 27
    update-alternatives --set python /usr/bin/python2
  fi

  # Set pypi mirror
  python -m pip install --default-timeout=100 --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple pip -U
  python -m pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

  # Clean up cache to reduce layer size.
  apt-get clean &&
    rm -rf /var/lib/apt/lists/*

}

##===================== Main ==============================##
function main() {
  local user_name="$1"
  local uid="$2"
  local group_name="$3"
  local gid="$4"

  if [ "${uid}" != "${gid}" ]; then
    echo "Warning: uid(${uid}) != gid(${gid}) found."
  fi
  if [ "${user_name}" != "${group_name}" ]; then
    echo "Warning: user_name(${user_name}) != group_name(${group_name}) found."
  fi
  setup_user_account_if_not_exist "$@"
  change_mirror_and_install_for_cn_user
}

main "${DOCKER_USER}" "${DOCKER_USER_ID}" "${DOCKER_GRP}" "${DOCKER_GRP_ID}"
