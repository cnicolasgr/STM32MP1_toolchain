FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive


# Install app dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    wget \
    bc \
    bison \
    flex \
    libssl-dev \
    libelf-dev \
    zstd \
    xz-utils \
    file \
    cpio \
    gawk \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Chain the COPY, extract, install, and clean steps to save image space
COPY en.SDK-x86_64-stm32mp1-openstlinux-6.6-yocto-scarthgap-mpu-v24.11.06.tar.gz /tmp/
RUN tar -xzf /tmp/en.SDK-x86_64-stm32mp1-openstlinux-6.6-yocto-scarthgap-mpu-v24.11.06.tar.gz -C /opt && \
    chmod +x /opt/stm32mp1-openstlinux-6.6-yocto-scarthgap-mpu-v24.11.06/sdk/*.sh && \
    /opt/stm32mp1-openstlinux-6.6-yocto-scarthgap-mpu-v24.11.06/sdk/*.sh -d /opt/Developer-Package/SDK -y && \
    rm -f /tmp/en.SDK-x86_64-stm32mp1-openstlinux-6.6-yocto-scarthgap-mpu-v24.11.06.tar.gz && \
    rm -rf /opt/stm32mp1-openstlinux-6.6-yocto-scarthgap-mpu-v24.11.06

# Extract the Kernel Sources and apply ST Wiki build steps
COPY SOURCES-*.tar.gz /tmp/
RUN tar -xzf /tmp/SOURCES-*.tar.gz -C /opt && \
    rm -f /tmp/SOURCES-*.tar.gz && \
    /bin/bash -c " \
    source /opt/Developer-Package/SDK/environment-setup-* && \
    cd /opt/*openstlinux-*/sources/*/linux-stm32mp-*/ && \
    tar xf linux-*.tar.xz && \
    cd linux-[0-9]*/ && \
    for p in ../*.patch; do [ -e \"\$p\" ] && patch -p1 < \"\$p\"; done; \
    export OUTPUT_BUILD_DIR=\$PWD/../build && \
    mkdir -p \${OUTPUT_BUILD_DIR} && \
    make O=\"\${OUTPUT_BUILD_DIR}\" defconfig && \
    for f in ../fragment*.config; do [ -e \"\$f\" ] && scripts/kconfig/merge_config.sh -m -r -O \${OUTPUT_BUILD_DIR} \${OUTPUT_BUILD_DIR}/.config \"\$f\"; done; \
    scripts/config --file \${OUTPUT_BUILD_DIR}/.config --disable CONFIG_VIDEO_ATMEL_ISI && \
    (yes '' || true) | make oldconfig O=\"\${OUTPUT_BUILD_DIR}\" && \
    make uImage vmlinux dtbs LOADADDR=0xC2000040 O=\"\${OUTPUT_BUILD_DIR}\" && \
    export IMAGE_KERNEL=\"uImage\" && \
    make modules O=\"\${OUTPUT_BUILD_DIR}\" && \
    make INSTALL_MOD_PATH=\"\${OUTPUT_BUILD_DIR}/install_artifact\" modules_install O=\"\${OUTPUT_BUILD_DIR}\" && \
    mkdir -p \${OUTPUT_BUILD_DIR}/install_artifact/boot/ && \
    cp \${OUTPUT_BUILD_DIR}/arch/\${ARCH}/boot/\${IMAGE_KERNEL} \${OUTPUT_BUILD_DIR}/install_artifact/boot/ && \
    find \${OUTPUT_BUILD_DIR}/arch/\${ARCH}/boot/dts/ -name 'st*.dtb' -exec cp '{}' \${OUTPUT_BUILD_DIR}/install_artifact/boot/ \; \
    "

COPY init.sh /opt/
RUN chmod +x /opt/init.sh

# Set working directory for when you mount your driver code
WORKDIR /workspace

ENTRYPOINT ["/opt/init.sh"]