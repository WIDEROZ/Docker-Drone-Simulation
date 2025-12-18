#!/bin/bash

set -e

# Graphic connection between docker and your screen
XAUTH=/tmp/.docker.xauth
touch $XAUTH
chmod 600 $XAUTH
xauth nlist "$DISPLAY" | sed 's/^..../ffff/' | xauth -f $XAUTH nmerge -

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

mkdir "$SCRIPT_DIR"/container

sudo docker run -it \
  --name drone-container \
  --device /dev/dri \
  --group-add video \
  -e DISPLAY=$DISPLAY \
  -e XAUTHORITY=$XAUTH \
  -v "$XAUTH:$XAUTH:ro" \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$SCRIPT_DIR"/share:/home/share \
  ubuntu22 \
  bash
  
  

