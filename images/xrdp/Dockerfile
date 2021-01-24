FROM ubuntu:18.04 as builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND="noninteractive"

RUN sed -i -E 's/^# deb-src /deb-src /g' /etc/apt/sources.list \
    && apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        build-essential \
        dpkg-dev \
        git \
        libpulse-dev \
        pulseaudio \
    && apt-get build-dep -y pulseaudio \
    && apt-get source pulseaudio \
    && rm -rf /var/lib/apt/lists/*

RUN mv /pulseaudio-"$(pulseaudio --version | awk '{print $2}')" /pulseaudio
WORKDIR /pulseaudio
RUN ./configure

RUN git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git /pulseaudio-module-xrdp

WORKDIR /pulseaudio-module-xrdp
RUN ./bootstrap \
    && ./configure PULSE_DIR=/pulseaudio \
    && make \
    && make install

FROM nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04

ARG INTERPRETER

ARG INTERPRETER_VERSION

LABEL maintainer=sergey.monakhov@gmail.com \
      vendor=puzl.ee

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

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        dbus-x11 \
        firefox \
        git \
        pavucontrol \
        pulseaudio \
        pulseaudio-utils \
        x11-xserver-utils \
        xfce4 \
        xfce4-goodies \
        xfce4-pulseaudio-plugin \
        xorgxrdp \
        xrdp \
        xubuntu-icon-theme \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i -E 's/^; autospawn =.*/autospawn = yes/' /etc/pulse/client.conf \
    && if [ -f /etc/pulse/client.conf.d/00-disable-autospawn.conf ];then sed -i -E 's/^(autospawn=.*)/# \1/' /etc/pulse/client.conf.d/00-disable-autospawn.conf; fi

COPY --from=builder /usr/lib/pulse-*/modules/module-xrdp-sink.so /usr/lib/pulse-*/modules/module-xrdp-source.so /var/lib/xrdp-pulseaudio-installer/
COPY template/configs/sesman.ini /etc/xrdp/sesman.ini

ARG TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/local/bin/tini

RUN add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
         ${INTERPRETER} \
         ${INTERPRETER}-distutils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

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

RUN rm -rf \
      /var/cache/debconf \
      /tmp/*

EXPOSE 3389

WORKDIR /tmp

USER $UID

CMD ["/bin/sh", "-c", "exit 0"]
