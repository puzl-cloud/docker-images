FROM python:3.7-slim

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

ARG TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/local/bin/tini

RUN ${INTERPRETER} -m pip install \
        determined-common==0.14.2 \
    && ${INTERPRETER} -m pip cache purge

RUN addgroup --gid "$GID" "$USER" \
    && adduser \
         --disabled-password \
         --gecos "" \
         --ingroup "$USER" \
         --uid "$UID" \
         --shell /bin/bash \
         "$USER"

WORKDIR /tmp

USER $UID

CMD ["/bin/sh", "-c", "exit 0"]
