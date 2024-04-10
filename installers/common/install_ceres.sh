#!/usr/bin/env bash

# ceres-solver requires pre-installed Eigen

set -e

VERSION="1.14.0"
if [ $1 ]; then
    VERSION="$1"
fi

PKG_NAME="ceres-solver"
echo -e "\033[32mInstalling ${PKG_NAME} ${VERSION} ...\033[0m"

apt-get -y update && \
    apt-get -y install --no-install-recommends \
    libgoogle-glog-dev \
    libgflags-dev \
    libatlas-base-dev \
    libsuitesparse-dev

PKG_FILE="${PKG_NAME}-${VERSION}.tar.gz"
DOWNLOAD_LINK="https://github.com/ceres-solver/ceres-solver/archive/refs/tags/${VERSION}.tar.gz"

pushd ${ARCHIVE_DIR}
if [[ -e "${ARCHIVE_DIR}/${PKG_FILE}" ]]; then
    echo "Using downloaded source files."
else
    wget "${DOWNLOAD_LINK}" -O "${PKG_FILE}"
fi
tar xzf ${PKG_FILE}

pushd "${PKG_NAME}-${VERSION}"
    mkdir build && cd build
    cmake ../
    make -j$(nproc)
    make install
popd

# Clean up files
rm -rf ${PKG_FILE} ${PKG_NAME}-${VERSION}
popd

ldconfig

echo -e "Successfully installed ${PKG_NAME} ${VERSION}."