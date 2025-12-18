#!/bin/bash

set -e

sudo docker build \
--build-arg USER=drone \
--build-arg host_uid=$(id -u) \
--build-arg host_gid=$(id -g) \
-t ubuntu22 .

