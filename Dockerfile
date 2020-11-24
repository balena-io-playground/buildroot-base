# create a multiarch buildroot image based on
# https://hub.docker.com/r/buildroot/base

FROM debian:buster as base

# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bc \
        build-essential \
        ca-certificates \
        cmake \
        cpio \
        file \
        locales \
        rsync \
        unzip \
        wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/# \(en_US.UTF-8\)/\1/' /etc/locale.gen && \
    /usr/sbin/locale-gen

RUN useradd -ms /bin/bash br-user && \
    chown -R br-user:br-user /home/br-user

USER br-user

WORKDIR /home/br-user

ENV LC_ALL=en_US.UTF-8

ARG BR_VERSION=2020.08.2

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN wget -q -O- https://buildroot.org/downloads/buildroot-$BR_VERSION.tar.gz | tar xz --strip 1

FROM base as rootfs

ARG TARGET_ARCH=aarch64

COPY config.common config.$TARGET_ARCH ./

RUN support/kconfig/merge_config.sh -m config.common config.$TARGET_ARCH

RUN make olddefconfig && make
