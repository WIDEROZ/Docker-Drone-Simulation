#!/bin/bash

set -e

sudo docker stop drone-container
sudo docker rm drone-container
sudo rm -rf /tmp/.docker.xauth
