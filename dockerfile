FROM ubuntu:25.04

ENV DEBIAN_FRONTEND=noninteractive

# install app dependencies
RUN apt-get update && apt-get install -y \
    gawk wget git git-lfs diffstat unzip texinfo gcc-multilib chrpath socat cpio \
    python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping \
    python3-git python3-jinja2 libegl1 libsdl1.2-dev pylint xterm \
    libssl-dev libgmp-dev libmpc-dev lz4 zstd build-essential libncurses-dev \
    libyaml-dev libelf-dev libxml2-utils xsltproc docbook-utils \
    python3-setuptools python3-wheel python3-pyparsing python3-requests \
    libncurses5-dev libncursesw5-dev libreadline-dev libffi-dev libbz2-dev \
    liblzma-dev zlib1g-dev libsqlite3-dev tk-dev libgdbm-dev libexpat1-dev \
    libmpfr-dev python-is-python3 coreutils sed curl bc dos2unix \
    flex bison libgpiod-dev libgpiod-doc\
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo 'options mmc_block perdev_minors=16' > /tmp/mmc_block.conf \
    && mkdir -p /etc/modprobe.d \
    && mv /tmp/mmc_block.conf /etc/modprobe.d/mmc_block.conf

# install app
COPY en.SDK-x86_64-stm32mp1-openstlinux-6.6-yocto-scarthgap-mpu-v24.11.06.tar.gz /tmp
RUN tar -xzf /tmp/en.SDK-x86_64-stm32mp1-openstlinux-6.6-yocto-scarthgap-mpu-v24.11.06.tar.gz -C /opt
RUN chmod +x /opt/stm32mp1-openstlinux-6.6-yocto-scarthgap-mpu-v24.11.06/sdk/st-image-weston-openstlinux-weston-stm32mp1.rootfs-x86_64-toolchain-5.0.3-openstlinux-6.6-yocto-scarthgap-mpu-v24.11.06.sh
RUN /opt/stm32mp1-openstlinux-6.6-yocto-scarthgap-mpu-v24.11.06/sdk/st-image-weston-openstlinux-weston-stm32mp1.rootfs-x86_64-toolchain-5.0.3-openstlinux-6.6-yocto-scarthgap-mpu-v24.11.06.sh -d /opt/Developer-Package/SDK
RUN chmod +x /opt/Developer-Package/SDK/environment-setup-cortexa7t2hf-neon-vfpv4-ostl-linux-gnueabi

COPY init.sh /opt
RUN chmod +x /opt/init.sh

# clean
RUN rm -f /tmp/en.SDK-x86_64-stm32mp1-openstlinux-6.6-yocto-scarthgap-mpu-v24.11.06.tar.gz
RUN rm -rf /opt/stm32mp1-openstlinux-6.6-yocto-scarthgap-mpu-v24.11.06

# source the environment
ENTRYPOINT ["/bin/bash", "/opt/init.sh"]