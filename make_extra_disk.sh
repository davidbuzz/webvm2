#!/bin/bash -x

IMAGE_NAME=extra
DEPLOY_DIR=/mnt/extra
IMAGE_SIZE=950M

sudo umount $DEPLOY_DIR

# dont put it in the $DEPLOY_DIR, put it where this script is.

rm -rf extra.ext2

# Preallocate space for the ext2 image
fallocate -l $IMAGE_SIZE $IMAGE_NAME.ext2

# about 950mb is hte biggest we can go on github pages, and its barely enough for a clone, let alone compiling stuff..
#mkfs.ext2 -r 0 -b 1024 extra.ext2 950000
mkfs.ext2 -r 0  $IMAGE_NAME.ext2  

# this mounts it so only root can write to it...
sudo mount -o loop,rw,sync -t ext2 $IMAGE_NAME.ext2 $DEPLOY_DIR

# copy files into it... then unmount
cd $DEPLOY_DIR

sudo git clone --depth=1 https://github.com/ArduPilot/ardupilot
# disk is now at approx 42% full
cd $DEPLOY_DIR/ardupilot


sudo git rm $DEPLOY_DIR/ardupilot/modules/CrashDebug
sudo git rm $DEPLOY_DIR/ardupilot/modules/gbenchmark
sudo git rm $DEPLOY_DIR/ardupilot/modules/Micro-XRCE-DDS-Client
sudo git rm $DEPLOY_DIR/ardupilot/modules/Micro-CDR
sudo git rm $DEPLOY_DIR/ardupilot/modules/gtest
sudo git rm $DEPLOY_DIR/ardupilot/modules/gsoap
sudo git rm $DEPLOY_DIR/ardupilot/modules/lwip
sudo git rm $DEPLOY_DIR/ardupilot/modules/ChibiOS 


# sudo rm -rf $DEPLOY_DIR/ardupilot/modules/CrashDebug
# sudo rm -rf $DEPLOY_DIR/ardupilot/modules/gbenchmark
# sudo rm -rf $DEPLOY_DIR/ardupilot/modules/Micro-XRCE-DDS-Client
# sudo rm -rf $DEPLOY_DIR/ardupilot/modules/Micro-CDR
# sudo rm -rf $DEPLOY_DIR/ardupilot/modules/gtest
# sudo rm -rf $DEPLOY_DIR/ardupilot/modules/lwip
# sudo rm -rf $DEPLOY_DIR/ardupilot/modules/ChibiOS 
#huge, believe it or not.

# do the remaining ones -
sudo git submodule update  --recursive --depth=1 --force --init
# disk is at  ??? % full after the above line

sudo rm -rf $DEPLOY_DIR/ardupilot/modules/CrashDebug
sudo rm -rf $DEPLOY_DIR/ardupilot/modules/gbenchmark
sudo rm -rf $DEPLOY_DIR/ardupilot/modules/Micro-XRCE-DDS-Client
sudo rm -rf $DEPLOY_DIR/ardupilot/modules/Micro-CDR
sudo rm -rf $DEPLOY_DIR/ardupilot/modules/gtest
sudo rm -rf $DEPLOY_DIR/ardupilot/modules/gsoap
sudo rm -rf $DEPLOY_DIR/ardupilot/modules/lwip
sudo rm -rf $DEPLOY_DIR/ardupilot/modules/ChibiOS #huge, believe it or not.


sudo git submodule sync --recursive

df -k $DEPLOY_DIR

# move out of hge mount
cd /home/buzz/webvm2

sudo umount $DEPLOY_DIR



# The .txt suffix enabled HTTP compression for free
#Generate image split chunks and .meta file


split $IMAGE_NAME.ext2 deploy/$IMAGE_NAME.ext2.c -a 6 -b 128k -x --additional-suffix=.txt
bash -c "stat -c%s $IMAGE_NAME.ext2 > deploy/$IMAGE_NAME.ext2.meta"
