#!/bin/bash

#########################################

## Updated February, 2025. Written by Dave Prowse: https://prowse.tech

## This script will install the Prometheus alert_manager and run it as a service. 

## It is tested on AMD64 and ARM64 - Ubuntu 22.04, Debian 12, and Centos 9, but should work on other systemd-based Linux distros as well.

## Check that your firewalls have port 9093 open.

## To install a newer version of the alert_manager simply change the version number in the two alert_manager variables below.

## !!! THIS IS FOR EDUCATIONAL PURPOSES ONLY. ONLY RUN THIS SCRIPT ON A TEST SYSTEM !!!

## Todo: harden the service, work with port config options, add enter key to confirmation

#########################################

# Variables
ALERTMANAGER_VERSION=v0.28.1
ALERTMANAGER_AMD64=alertmanager-0.28.1.linux-amd64
ALERTMANAGER_ARM64=alertmanager-0.28.1.linux-arm64
UBUNTU_MAN_VERSION=noble

# sudo check and confirmation
clear -x
if [ "$(id -u)" -ne 0 ]; then echo;echo "Please run as root or with 'sudo'." >&2; echo; exit 1; fi

printf "\n\033[7;31mTHIS SCRIPT WILL INSTALL THE PROMETHEUS ALERTMANAGER %s AND RUN IT AS A SERVICE. \033[0m" "$ALERTMANAGER_VERSION"
printf '%.0s\n' {1..2}
read -p "Are you sure you want to proceed? (y,n): " -r response
printf '%.0s\n' {1..2}
if [[ $response =~ ^[Yy]$ ]]; then
start=$SECONDS  
printf '%.0s\n' {1..2}
start=$SECONDS  
printf '%.0s\n' {1..3}

sleep 1
mkdir temp 
cd temp || return

# Users and Groups and Permissions
groupadd --system alertmanager
useradd -s /sbin/nologin --system -g alertmanager alertmanager
mkdir -p /var/lib/alertmanager
chown -R alertmanager:alertmanager /var/lib/alertmanager
mkdir /etc/alertmanager
chown alertmanager:alertmanager /etc/alertmanager

# Install alertmanager
## Determine CPU architecture using 'uname -m'
arch=$(uname -m)

# Download, extract, and copy Prometheus Node Exporter files
## if statement to install corresponding package based on architecture determination
if [ "$arch" == "x86_64" ]; then
    echo "Installing package for x86_64 architecture..."
    wget https://github.com/prometheus/alertmanager/releases/download/$ALERTMANAGER_VERSION/$ALERTMANAGER_AMD64.tar.gz
    tar -xvf $ALERTMANAGER_AMD64.tar.gz
    cd $ALERTMANAGER_AMD64 || return
elif [ "$arch" == "aarch64" ]; then
    echo "Installing package for ARM64 architecture..."
    wget https://github.com/prometheus/alertmanager/releases/download/$ALERTMANAGER_VERSION/$ALERTMANAGER_ARM64.tar.gz
    tar -xvf $ALERTMANAGER_ARM64.tar.gz
    cd $ALERTMANAGER_ARM64 || return
else
    echo "Unsupported architecture: $arch"
    printf "Go to https://prometheus.io/download/ to download other binaries."
    printf '%.0s\n' {1..2}
    exit 1
fi

# Copy files
cp {alertmanager,amtool} /usr/local/bin
cp {alertmanager.yml,LICENSE,NOTICE} /etc/alertmanager

# Build alertmanager service
cat << "EOF" > "/lib/systemd/system/alertmanager.service"
[Unit]
Description=Alert Manager
After=network.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
ExecStart=/usr/local/bin/alertmanager $ARGS \
--config.file /etc/alertmanager/alertmanager.yml \
--storage.path /var/lib/alertmanager/data \
--web.listen-address=:9093

[Install]
WantedBy=multi-user.target
EOF

# Start alertmanager service
systemctl daemon-reload
systemctl --now enable alertmanager

# Install man page - From Ubuntu
wget https://manpages.ubuntu.com/manpages.gz/$UBUNTU_MAN_VERSION/man1/prometheus-alertmanager.1.gz
cp prometheus-alertmanager.1.gz /usr/share/man/man1

# Clean UP!
cd ../.. || return
rm -rf temp/
sleep 2

# Completion messages
printf '%.0s\n' {1..2}
printf "\nTime to complete = %s seconds" "$SECONDS"
echo
printf "\n\033[7;32mPROCESS COMPLETE! ALERTMANAGER SHOULD NOW BE RUNNING AS A SERVICE AND LISTENING ON PORT 9093.\033[0m"
printf '%.0s\n' {1..2}
printf "\n\033[7;36m ENJOY! \033[0m"
printf '%.0s\n' {1..2}

fi