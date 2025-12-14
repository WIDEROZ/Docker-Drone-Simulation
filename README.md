
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
> xhost +SI:localuser:$USER
> ```

> [!WARNING]
> If the DISPLAY env variable does not exist, check your /tmp/.X11-unix folder and change the value of DISPLAY for :number (number corresponds to the value you will find in this folder, preceded by an X.) for example if there is a file named X0 : 
> ```bash
> export DISPLAY=:0
> ```

Therefore to run the container (for the first time) : 
```bash
sudo docker run -it \
--name ubuntu22-container \
--device /dev/dri \
--group-add video \
-e DISPLAY=$DISPLAY \
-v ${PWD}/container/:/home/drone \
-v /tmp/.X11-unix:/tmp/.X11-unix \
ubuntu22 \
bash
```


Start the container : 
```bash
sudo docker start -ai ubuntu22-container
```

Stop the container : 
```bash
sudo docker stop ubuntu22-container
```


Open another bash session : 
```bash
docker exec -it ubuntu22-container bash
```


> [!WARNING]
> Pour supprimer le conteneur (mais pas son build) : 
> ```bash
> sudo docker rm ubuntu22-container
> ```
> (Files created after the build will not be saved)

