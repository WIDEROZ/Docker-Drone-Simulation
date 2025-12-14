sudo docker build \
--build-arg USER=drone \
--build-arg host_uid=$(id -u) \
--build-arg host_gid=$(id -g) \
-t ubuntu22 .

sudo docker run -it \
--name ubuntu22-container \
--device /dev/dri \
--group-add video \
-e DISPLAY=$DISPLAY \
-v ${PWD}/container/:/home/drone \
-v /tmp/.X11-unix:/tmp/.X11-unix \
ubuntu22 \
bash
