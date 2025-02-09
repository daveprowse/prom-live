#!/bin/bash

#########################################

## Updated November, 2024. Written by Dave Prowse: https://prowse.tech

## This script will install the Prometheus node_exporter and run it as a service. 

## It is tested on Ubuntu 22.04, Ubuntu 24.04, Debian 12, and Centos 9, but should work on other systemd-based Linux distros as well.

## Check that your firewalls have port 9100 open.

## To install a newer version of the node_explorer simply change the version number in the two node_explorer variables below.

## !!! THIS IS FOR EDUCATIONAL PURPOSES ONLY. ONLY RUN THIS SCRIPT ON A TEST SYSTEM !!!

## Todo: add ARM version and variables, harden the service, work with port config options, add enter key to confirmation

#########################################

# Variables
NODE_EXPORTER_VERSION=v1.8.2
NODE_EXPORTER=node_exporter-1.8.2.linux-amd64
UBUNTU_MAN_VERSION=noble

# sudo check and confirmation
clear -x
if [ "$(id -u)" -ne 0 ]; then echo;echo "Please run as root or with 'sudo'." >&2; echo; exit 1; fi

printf "\n\033[7;31mTHIS SCRIPT WILL INSTALL THE PROMETHEUS %s\n AND RUN IT AS A SERVICE. \033[0m" "$NODE_EXPORTER_VERSION"
printf '%.0s\n' {1..2}
read -p "Are you sure? [y,n]:  " -n 1 -r
printf '%.0s\n' {1..2}
if [[ $REPLY =~ ^[Yy]$ ]]
then
start=$SECONDS  
printf '%.0s\n' {1..2}

# Install node_exporter
echo
sleep 1
echo
mkdir temp 
cd temp || return
wget https://github.com/prometheus/node_exporter/releases/download/$NODE_EXPORTER_VERSION/$NODE_EXPORTER.tar.gz
tar -xvf $NODE_EXPORTER.tar.gz
cp ./$NODE_EXPORTER/node_exporter /usr/local/bin

# Build node_exporter service
useradd -rs /bin/false node_exporter
cat << "EOF" > "/lib/systemd/system/node_exporter.service"
[Unit]
Description=Node Exporter 
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Start node_exporter service
systemctl daemon-reload
systemctl --now enable node_exporter

# Install man page - From Ubuntu
wget https://manpages.ubuntu.com/manpages.gz/$UBUNTU_MAN_VERSION/man1/prometheus-node-exporter.1.gz
cp prometheus-node-exporter.1.gz /usr/share/man/man1

# Clean UP!
cd .. || return
rm -rf temp/
sleep 2

# Completion messages
printf '%.0s\n' {1..2}
printf "\nTime to complete = %s seconds" "$SECONDS"
echo
printf "\n\033[7;32mPROCESS COMPLETE! NODE_EXPORTER SHOULD NOW BE RUNNING AS A SERVICE AND LISTENING ON PORT 9100.\033[0m"
printf '%.0s\n' {1..2}
echo -e "Note: To analyze this system from your main Prometheus server, \nadd this system's IP address and port 9100 in prometheus.yml > scrape_configs > targets. \nFor example: '- targets: ['<ip_address>:9100']'"
printf '%.0s\n' {1..2}
printf "\n\033[7;36m ENJOY! \033[0m"

printf '%.0s\n' {1..2}

fi