FROM nvidia/cuda:10.0-base-ubuntu18.04

ARG CUDA=10.0

ARG CUDNN=7.6.4.38-1

LABEL maintainer=sergey.monakhov@gmail.com \
      vendor=puzl.ee

ENV USER=ubuntu \
    UID=1000 \
    GID=1000 \
    PATH="${PATH}:/opt/conda/bin"

SHELL ["/bin/bash", "-c"]

RUN apt-get update \
    && apt-get install -y software-properties-common \
    && add-apt-repository ppa:git-core/ppa -y \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
         build-essential \
         openssh-server \
         git \
         locales \
         rsync \
         curl \
         wget \
         iputils-ping \
         telnet \
         screen \
         nano \
         vim \
         sudo \
         unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         cuda-command-line-tools-${CUDA/./-} \
         # There appears to be a regression in libcublas10=10.2.2.89-1 which
         # prevents cublas from initializing in TF. See
         # https://github.com/tensorflow/tensorflow/issues/9489#issuecomment-562394257
         libcublas10=10.2.1.243-1 \ 
         cuda-nvrtc-${CUDA/./-} \
         cuda-cufft-${CUDA/./-} \
         cuda-curand-${CUDA/./-} \
         cuda-cusolver-${CUDA/./-} \
         cuda-cusparse-${CUDA/./-} \
         libcudnn7=${CUDNN}+cuda${CUDA} \
         libnvinfer6=6.0.1-1+cuda${CUDA} \
         libnvinfer-dev=6.0.1-1+cuda${CUDA} \
         libnvinfer-plugin6=6.0.1-1+cuda${CUDA} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -o ~/nodejs.sh --silent --location https://deb.nodesource.com/setup_12.x \
    && bash ~/nodejs.sh \
    && apt-get install --yes nodejs \
    && npm install -g yarn \
    && rm -f ~/nodejs.sh

RUN addgroup --gid "$GID" "$USER" \
    && adduser \
         --disabled-password \
         --gecos "" \
         --ingroup "$USER" \
         --uid "$UID" \
         --shell /bin/bash \
         "$USER"

COPY template/configs/sshd_config /home/"$USER"/.ssh/sshd_config
COPY template/configs/config /home/"$USER"/.ssh/config
COPY template/configs/bash.bashrc /etc/bash.bashrc
COPY template/configs/requirements.txt /tmp/requirements.txt
COPY globals/run_test.sh /usr/local/bin/run_test.sh

RUN rm -f /etc/ssh/ssh_host_*key* \
    && mkdir -p \
         /run/sshd \
         /home/"$USER"/.ssh \
    && chmod 700 /home/"$USER"/.ssh \
    && chown $USER:$USER -R /home/"$USER" /tmp \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-ubuntu \
    && chmod 600 /home/"$USER"/.ssh/config \
    && chown -R $USER:$USER /home/"$USER"/.ssh \
    && chmod +x /usr/local/bin/* \
    && echo "PATH=\"${PATH}\"" > /etc/environment

RUN yarn add \
        @tensorflow/tfjs@2.0.1 \
        @tensorflow/tfjs-node-gpu@2.0.1 \
    && yarn cache clean

RUN curl https://rclone.org/install.sh -o ~/install.sh \
    && chmod +x ~/install.sh \
    && ~/install.sh \
    && rm ~/install.sh

RUN rm -rf \
        /var/cache/debconf \
        /tmp/*

EXPOSE 2222

WORKDIR /tmp

USER $UID

CMD ["/bin/sh", "-c", "exit 0"]
