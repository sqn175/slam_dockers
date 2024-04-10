#!/usr/bin/env bash

set -e

# ========= Modify the following paths ============
HOST_SOURCE_DIR="/modify/to/your/src/dir"
HOST_DATASET_DIR="/modify/to/your/dataset/dir"

# ========= Modify the Docker image ============
IMAGE_NAME="slam-dev-ubuntu18-opengl"

if [ $1 ]; then
    IMAGE_NAME="$1"
fi

XSOCK=/tmp/.X11-unix
XAUTH=$HOME/.Xauthority

VOLUMES="--volume=$XSOCK:$XSOCK:rw
         --volume=$HOST_SOURCE_DIR:/home/slam/ws:rw
         --volume=$HOST_DATASET_DIR:/home/slam/dataset:rw
         --volume=$HOME/.Xauthority:/root/.Xauthority"

xhost +local:root 1>/dev/null 2>&1

docker run \
    --privileged \
    -it --rm \
    --gpus all \
    -e NVIDIA_DRIVER_CAPABILITIES=all \
    --name slam \
    --user slam \
    $VOLUMES \
    --env DISPLAY=${DISPLAY} \
    --env XAUTHORITY=${XAUTH} \
    --env="QT_X11_NO_MITSHM=1" \
    --net host \
    --workdir /home/slam \
    --add-host raw.githubusercontent.com:151.101.84.133 \
    "${IMAGE_NAME}:latest"

xhost -local:root 1>/dev/null 2>&1
