#!/bin/bash
# Build the kernel on board the Jetson AGX Developer Kit
# Copyright (c) 2016-19 Jetsonhacks 
# MIT License


function usage
{
    echo "usage: ./buildKernel.sh [[-n nocleanup ] | [-h]]"
    echo "-h | --help  This message"
}

# Iterate through command line inputs
while [ "$1" != "" ]; do
    case $1 in
        -n | --nocleanup )      CLEANUP=false
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
# e.g. echo "${red}The red tail hawk ${green}loves the green grass${reset}"


INSTALL_DIR=$PWD
# Is this the correct kernel version?
source scripts/jetson_variables.sh
#Print Jetson version
echo "$JETSON_DESCRIPTION"
#Print Jetpack version
echo "Jetpack $JETSON_JETPACK [L4T $JETSON_L4T]"
echo "Jetson $JETSON_BOARD Development Kit"

# Error out if something goes wrong
set -e

# Check to make sure we're installing the correct kernel sources
# Determine the correct kernel version
# The KERNEL_BUILD_VERSION is the release tag for the JetsonHacks buildKernel repository
KERNEL_BUILD_VERSION=master
# Quotes around Jetson Board because the name may have a space, ie "AGX Xavier"
if [ "$JETSON_BOARD" == "AGX Xavier" ] ; then 
  L4TTarget="31.1.0"
  # Test for 31.1.0 first
  if [ $JETSON_L4T = "31.1.0" ] ; then
     KERNEL_BUILD_VERSION=vL4T31.1.0
  else
   echo ""
   tput setaf 1
   echo "==== L4T Kernel Version Mismatch! ============="
   tput sgr0
   echo ""
   echo "This repository is for modifying the kernel for a L4T "$L4TTarget "system." 
   echo "You are attempting to modify a L4T "$JETSON_L4T "system."
   echo "The L4T releases must match!"
   echo ""
   echo "There may be versions in the tag/release sections that meet your needs"
   echo ""
   exit 1
  fi
fi

# If we didn't find a correctly configured Xavier exit, we don't know what to do
if [ $KERNEL_BUILD_VERSION = "master" ] ; then
   tput setaf 1
   echo "==== L4T Kernel Version Mismatch! ============="
   tput sgr0
    echo "Currently this script works for the Jetson AGX Xavier."
   echo "This processor appears to be a Jetson $JETSON_BOARD, which does not have a corresponding script"
   echo ""
   echo "Exiting"
   exit 1
fi


# Switch back to the script directory
cd $INSTALL_DIR
# Get the kernel sources; does not open up editor on .config file
echo "${green}Getting Kernel sources${reset}"
sudo ./scripts/getKernelSourcesNoGUI.sh

echo "${green}Patching and configuring kernel${reset}"
# Set the local version to match the current kernel
sudo ./scripts/configureKernel.sh

# Make the new Image and build the modules
echo "${green}Building Kernel and Modules then installing Modules${reset}"
sudo ./scripts/makeKernel.sh

echo "${green}Please flash the new kernel Image file on to the Jetson.${reset}"
echo "${green}The new kernel Image is in the image folder.${reset}"

# To Do
# Leave a message that the new Image is in /usr/src/kernel/kernel-4.9/arch/arm64/boot/Image
# Maybe copy it somewhere?
# And must be flashed on to the Jetson
cp /usr/src/kernel/kernel-4.9/arch/arm64/boot/Image ./image/Image

echo ""
echo "Kernel sources are in /usr/src"
echo "To remove the kernel sources, execute the removeAllKernelSources.sh script"


