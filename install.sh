#!/bin/bash
# Install script for BioBatch batch processing system
# 9 June 2010

if [ $EUID -ne 0 ]; then
    echo "BioBatch must be installed by the root user" 1>&2
    exit 1
fi

BIOBATCH_ROOT_INSTALL=/opt/BioBatch
echo "Where would you like to install the BioBatch root directory? [/opt/BioBatch]"
read ans

if [[ $ans == "" ]]; then
    :
else
    BIOBATCH_ROOT_INSTALL=$ans
fi

mkdir -m 755 -p $BIOBATCH_ROOT_INSTALL
mkdir -m 755 $BIOBATCH_ROOT_INSTALL/logs
mkdir -m 777 $BIOBATCH_ROOT_INSTALL/Jobs
mkdir -m 755 $BIOBATCH_ROOT_INSTALL/bin

cp BioCron $BIOBATCH_ROOT_INSTALL/bin/
cp BioClean $BIOBATCH_ROOT_INSTALL/bin/

BINARIES=/usr/bin
echo "Where would you like BioBatch to install the binary files? (Make sure this location is in your PATH) [/usr/bin]"
read ans

if [[ $ans == "" ]]; then
    :
else
    BINARIES=$ans
fi

cp BioBatch $BINARIES
cp BioKill $BINARIES
cp BioCheck $BINARIES

if [[ -e /etc/profile ]]; then
    echo "BIOBATCH_ROOT=$BIOBATCH_ROOT_INSTALL" >> /etc/profile
    echo "export BIOBATCH_ROOT" >> /etc/profile
else
    echo "Can't find /etc/profile. Please add the lines\n   BIOBATCH_ROOT=$BIOBATCH_ROOT_INSTALL\n   export BIOBATCH_ROOT\nto your global environment variables"
fi

crontab -l > crontab.tmp

echo "* 19-8 * * mon-fri $BIOBATCH_ROOT_INSTALL/bin/BioCron" >> crontab.tmp
echo "* * * * sat-sun $BIOBATCH_ROOT_INSTALL/bin/BioCron" >> crontab.tmp

crontab crontab.tmp
rm crontab.tmp

echo "Please re-start cron to complete the installation"
