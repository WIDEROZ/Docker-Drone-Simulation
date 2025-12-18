# Automatic operations
#### First step
You need to build the DOCKERFILE : 
Execute docker_build.sh

#### Final step
Run the docker container : 
Execute docker_run.sh

# Manual operations
Build with DOCKERFILE : 
```bash
sudo docker build \
--build-arg USER=drone \
--build-arg host_uid=$(id -u) \
--build-arg host_gid=$(id -g) \
-t ubuntu22 .
```

> [!WARNING]
> Before running, make sure you allow X server and docker to communicate :
> ```bash 
> XAUTH=/tmp/.docker.xauth
> touch $XAUTH
> chmod 600 $XAUTH
> xauth nlist "$DISPLAY" | sed 's/^..../ffff/' | xauth -f $XAUTH nmerge -
> ```

Therefore run the container (for the first time) : 
```bash
sudo docker run -it \
  --name drone-container \
  --device /dev/dri \
  --group-add video \
  -e DISPLAY=$DISPLAY \
  -e XAUTHORITY=$XAUTH \
  -v "$XAUTH:$XAUTH:ro" \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "${PWD}"/share:/home/share \
  ubuntu22 \
  bash
```


Start the container : 
```bash
sudo docker start -ai drone-container
```

Stop the container : 
```bash
sudo docker stop drone-container
```


Open another bash session : 
```bash
sudo docker exec -it drone-container bash
```


> [!WARNING]
> Delete the container (not the build) : 
> ```bash
> sudo docker rm drone-container
> ```
> (Files created after the build will not be saved)

