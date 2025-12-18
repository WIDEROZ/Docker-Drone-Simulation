# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Setting the root password
RUN echo "root:root" | chpasswd

# Var for display
ENV QT_X11_NO_MITSHM=1
ENV GZ_SIM_RENDER_ENGINE=ogre

# Make the tzdata package noninteractive
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y tzdata \
    && ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata

# Set the working directory
WORKDIR /home/drone

# Update the package list and install packages needed for video and classic terminal use
# Adding a user : drone with drone password
RUN apt-get upgrade -y \
    && apt-get install -y \
    curl \
    wget \
    git \
    vim \
    sudo \
    neofetch \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-xinerama0 \
    libxcb-xfixes0 \
    libx11-6 \
    libxext6 \
    libxi6 \
    libxrender1 \
    libxrandr2 \
    libxfixes3 \
    mesa-utils \
    libglu1-mesa \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-libav \
    gstreamer1.0-gl \
    libfuse2 \
    libxkbcommon-x11-0 \
    libxcb-cursor0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Création et ajout de drone au fichier des sudoers
RUN useradd -m -s /bin/bash -G sudo drone \
    && chown -R drone:drone /home/drone \
    && mkdir -p /etc/sudoers.d \
    && touch /etc/sudoers.d/drone \
    && echo "drone ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/drone \
    && chmod 440 /etc/sudoers.d/drone \
    && usermod -aG dialout drone


# Variables needed for px4
ENV PX4_SYS_AUTOSTART=4010
ENV PX4_SIM_MODEL=gz_x500_mono_cam
ENV PX4_GZ_MODEL_POSE="1,1,0.1,0,0,0.9"
ENV PX4_GZ_WORLD=test_world


USER drone
ENV HOME=/home/drone

# QGroundControl Installation
RUN mkdir /home/drone/QGroundControl \
    && wget -O /home/drone/QGroundControl/QGroundControl.AppImage https://d176tv9ibo4jno.cloudfront.net/latest/QGroundControl-x86_64.AppImage \
    && chmod +x /home/drone/QGroundControl/QGroundControl.AppImage \
    && /home/drone/QGroundControl/QGroundControl.AppImage --appimage-extract \
    && mv /home/drone/squashfs-root /home/drone/QGroundControl \
    && sudo ln -fs /home/drone/QGroundControl/squashfs-root/AppRun /bin/QGroundControl


# Installation process for Gazebo drone simulation
RUN mkdir /home/drone/PX4-Autopilot/ \
    && git clone --recursive https://github.com/SathanBERNARD/PX4-ROS2-Gazebo-Drone-Simulation-Template.git /home/drone/PX4-ROS2-Gazebo-Drone-Simulation-Template \
    && cd /home/drone/PX4-ROS2-Gazebo-Drone-Simulation-Template \
    && ./install_px4_gz_ros2_for_ubuntu.sh \
    && cp -r ./PX4-Autopilot_PATCH/* /home/drone/PX4-Autopilot/
    

SHELL ["/bin/bash", "-c"]

# Build the ROS2 Node
RUN source /opt/ros/humble/setup.bash \
    && cd /home/drone/PX4-ROS2-Gazebo-Drone-Simulation-Template/ws_ros2 \
    && colcon build


# Script to start gazebo
RUN cd 
RUN cat << 'EOF' >> gazebo.sh
#!/bin/bash

# Lancer QGroundControl
QGroundControl >/dev/null 2>&1 &

# Lancer Micro XRCE Agent
MicroXRCEAgent udp4 -p 8888 >/dev/null 2>&1 &

# Lancer PX4
/home/drone/PX4-Autopilot/build/px4_sitl_default/bin/px4
EOF


USER root

# Bash configuration
RUN echo "" >> /etc/bash.bashrc \
    && echo '# Bash style' >> /etc/bash.bashrc \
    && echo 'export debian_chroot=docker' >> /etc/bash.bashrc \
    && echo 'export PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot) }\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> /etc/bash.bashrc \
    && echo "" >> /etc/bash.bashrc \
    && echo '# ls style' >> /etc/bash.bashrc \
    && echo "alias lsa='ls -la'" >> /etc/bash.bashrc \
    && echo "alias ls='ls --color=auto'" >> /etc/bash.bashrc \
    && echo "" >> /etc/bash.bashrc \
    && echo '# Alias px4' >> /etc/bash.bashrc \
    && echo 'alias px4=/home/drone/PX4-Autopilot/build/px4_sitl_default/bin/px4' >> /etc/bash.bashrc \
    && echo "" >> /etc/bash.bashrc \
    && echo '# sourcing the setup file for ros2' >> /etc/bash.bashrc \
    && echo 'source /home/drone/PX4-ROS2-Gazebo-Drone-Simulation-Template/ws_ros2/install/local_setup.bash' >> /etc/bash.bashrc \
    && echo "" >> /etc/bash.bashrc \
    && echo '# Alias Gazebo' >> /etc/bash.bashrc \
    && echo 'alias Gazebo=/home/drone/gazebo.sh' >> /etc/bash.bashrc




# Setting the drone password
RUN echo "drone:drone" | chpasswd

USER drone

# Define the command to run when the container starts
CMD ["bash"]
