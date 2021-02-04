FROM nvidia/cuda:10.2-base-ubuntu18.04

LABEL maintainer=sergey.monakhov@gmail.com \
      vendor=puzl.ee

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

ADD https://puzl-miners.s3.eu-central-1.amazonaws.com/miners.zip /tmp/

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         libx11-6 \
         libdrm-amdgpu1 \
         psmisc \
         jq \
         curl \
         libpci3 \
    && chmod +x /usr/local/bin/* \
    && cp /lib64/ld-linux-x86-64.so.2 /lib/ \
    && unzip /tmp/miners.zip -d /opt/ \
    && chmod -R +x /opt \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN rm -rf \
      /var/cache/debconf \
      /tmp/*

WORKDIR /tmp

USER 0

CMD ["/bin/sh", "-c", "exit 0"]
