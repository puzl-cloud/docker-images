FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

ARG INTERPRETER

ARG INTERPRETER_VERSION

LABEL maintainer=sergey.monakhov@gmail.com \
      vendor=https://puzl.cloud

ENV USER=ubuntu \
    UID=1000 \
    GID=1000 \
    PATH="${PATH}:/opt/conda/bin"

ENV DEBIAN_FRONTEND="noninteractive"

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

ARG TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/local/bin/tini

RUN add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
         ${INTERPRETER} \
         ${INTERPRETER}-distutils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -o ~/nodejs.sh --silent --location https://deb.nodesource.com/setup_18.x \
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

RUN curl -o ~/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && chmod +x ~/miniconda.sh \
    && ~/miniconda.sh -b -p /opt/conda \
    && rm ~/miniconda.sh

RUN curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py \
    && ${INTERPRETER} /tmp/get-pip.py \
    && rm -rf /tmp/get-pip.py

RUN rm -rf /usr/local/bin/pip3 \
      /usr/local/bin/pip \
      /usr/bin/python3 \
      /usr/bin/python \
    && ln -s /usr/local/bin/pip${INTERPRETER_VERSION} /usr/local/bin/pip \
    && ln -s /usr/local/bin/pip${INTERPRETER_VERSION} /usr/local/bin/pip3 \
    && ln -s /usr/bin/${INTERPRETER} /usr/bin/python3 \
    && ln -s /usr/bin/python3 /usr/bin/python

RUN ${INTERPRETER} -m pip install -r /tmp/requirements.txt

RUN case ${INTERPRETER} in \
    python3.9) \
      export CP_FORMAT=cp39 \
      ;; \
    python3.10) \
      export CP_FORMAT=cp310 \
      ;; \
    python3.11) \
      export CP_FORMAT=cp311 \
      ;; \
  esac \
  && ${INTERPRETER} -m pip install \
        torch==2.1.0 \
        torchvision==0.16.0 \
        torchaudio==2.1.0 \
        jupyterlab==4.0.7 \
      --index-url https://download.pytorch.org/whl/cu118 \
      --extra-index-url https://pypi.org/simple \
  && ${INTERPRETER} -m pip cache purge

RUN curl https://rclone.org/install.sh -o ~/install.sh \
    && chmod +x ~/install.sh \
    && ~/install.sh \
    && rm ~/install.sh

RUN rm -rf \
      /var/cache/debconf \
      /tmp/*

EXPOSE 2222

EXPOSE 8888

WORKDIR /tmp

USER $UID

CMD ["/bin/sh", "-c", "exit 0"]
