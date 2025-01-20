FROM osrf/ros:humble-desktop
SHELL ["/bin/bash", "-c"]

# Timezone, Launguage設定
RUN apt update \
  && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
     locales \
     software-properties-common tzdata \
  && locale-gen ja_JP ja_JP.UTF-8  \
  && update-locale LC_ALL=ja_JP.UTF-8 LANG=ja_JP.UTF-8 \
  && add-apt-repository universe

# Locale
ENV LANG=ja_JP.UTF-8
ENV TZ=Asia/Tokyo

#package install
RUN apt update && apt upgrade -y\
    && DEBIAN_FRONTEND=noninteractive apt install -y curl vim git wget htop \
    python3.10-dev python-is-python3 python3-pip \
    gnupg gnupg2 lsb-release nano python3-colcon-common-extensions python3-rosdep2 &&\
    rm -rf /etc/ros/rosdep/sources.list.d/20-default.list && rosdep init

#userをグループに追加
ARG UID
ARG GID
ARG USER_NAME
ARG GROUP_NAME

#sudo パスワードを無効化
RUN groupadd -g ${GID} ${GROUP_NAME} && \
        useradd -m -s /bin/bash -u ${UID} -g ${GID} -G sudo ${USER_NAME} && \
        echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /home/${USER_NAME}

#ユーザーをrootからユーザーに変更
USER $USER_NAME

#PS1, rustのインストール
RUN echo "PS1='\[\033[44;37m\]Docker\[\033[0m\]@\[\033[32m\]\u\[\033[0m\]:\[\033[1;33m\]\w\[\033[0m\]\$ '" >> /home/${USER_NAME}/.bashrc &&\
    echo "source /opt/ros/humble/setup.bash" >> /home/${USER_NAME}/.bashrc &&\
    pip install setuptools==58.2.0 &&\
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &&\
    echo 'source $HOME/.cargo/env ' >> /home/${USER_NAME}/.bashrc

#ROS2 workspace作成
RUN sudo apt update && sudo apt install -y libclang-dev python3-vcstool &&\
    pip install git+https://github.com/colcon/colcon-cargo.git &&\
    pip install git+https://github.com/colcon/colcon-ros-cargo.git &&\
    . $HOME/.cargo/env &&\
    cargo install --debug cargo-ament-build &&\
    mkdir -p catkin_ws/src &&\
    cd catkin_ws &&\
    git clone https://github.com/ros2-rust/ros2_rust.git src/ros2_rust &&\
    vcs import src < src/ros2_rust/ros2_rust_humble.repos &&\
    . /opt/ros/humble/setup.sh &&\
    colcon build

#tempに実行ファイル追加
COPY assets/setup.sh /tmp/setup.sh
COPY assets/nanorc /home/${USER_NAME}/.nanorc
RUN sudo chmod +x /tmp/setup.sh ;\
    sudo chmod -R 777 /home/${USER_NAME}/catkin_ws ;\
    echo 'export ROS_DOMAIN_ID=10' >> /home/${USER_NAME}/.bashrc  ;\
    echo 'source ~/catkin_ws/install/setup.bash' >> /home/${USER_NAME}/.bashrc
WORKDIR /home/${USER_NAME}/catkin_ws
ENTRYPOINT ["/tmp/setup.sh"]
