#!/bin/bash
# Configure the kernel for the Intel Realsense library on a NVIDIA AGX Xavier Developer Kit
# Copyright (c) 2016-19 Jetsonhacks 
# MIT License

# For L4T 31.1.0 the kernel is 4.9.109 hence kernel-4.9
echo "Configuring Kernel for librealsense"

cd /usr/src/kernel/kernel-4.9
echo "Current working directory: "$PWD
KERNEL_VERSION=$(uname -r)
# For L4T 31.1.0 the kernel is 4.9.108-tegra ; everything after that is the local version
# This removes the suffix
LOCAL_VERSION=${KERNEL_VERSION#$"4.9.108"}
# LOCAL_VERSION should be -tegra on a stock kernel

bash scripts/config --file .config \
	--set-str LOCALVERSION $LOCAL_VERSION \

yes "" | make olddefconfig

