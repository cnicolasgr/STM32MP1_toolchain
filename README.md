# STM32MP1 Toolchain

This repository contains the necessary files and scripts to set up and use the STM32MP1 toolchain.

A prebuild image can be pulled using `docker pull cnicolasgr/stm32mp1_toolchain`

## Files

- **dockerfile**: Docker configuration file for setting up the development environment.
- **en.SDK-x86_64-stm32mp1-openstlinux-6.6-yocto-scarthgap-mpu-v24.11.06.tar.gz**: Prebuilt development SDK tarball for STM32MP1.
- **init.sh**: Initialization script for setting up the environment.

## Usage

1. Build the image:
   ```bash
   docker build -t stm32mp1_toolchain:latest .
   ```

2. Run a container
   ```bash
   docker run stm32mp1_toolchain:latest <your command>
   ```

## Notes

- The development SDK is automatically sourced on container start
- Refer to the official STM32MP1 documentation for additional details.