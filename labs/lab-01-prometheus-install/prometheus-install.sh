#!/bin/bash

#########################################

## This script will install Prometheus on Debian 12 or Ubuntu 22.04 x64 systems.
## Includes Go and NodeJS.
## Prometheus will be set up as a service that runs automatically.

## This script requires that you work as `root` or with sudo capabilities. 

## !!! THIS IS FOR EDUCATIONAL PURPOSES ONLY. ONLY RUN THIS SCRIPT ON A TEST SYSTEM !!!

## Written by Dave Prowse: https://prowse.tech

#########################################

# Variables
GO=go1.22.0.linux-amd64
GOVERSION=v1.22.0
NODEJS=node-v20.11.1-linux-x64
NODEJSVERSION=v20.11.1
PROM=prometheus-2.50.1.linux-amd64
PROMVERSION=v2.50.1

clear -x

if [ "$(id -u)" -ne 0 ]; then echo;echo "Please run as root or with 'sudo'." >&2; echo; exit 1; fi

printf "\n\033[7;31mTHIS SCRIPT WILL INSTALL GO, NODEJS, and PROMETHEUS \033[0m"
printf '%.0s\n' {1..2}
read -p "Are you sure? [y,n]:  " -n 1 -r
printf '%.0s\n' {1..2}
if [[ $REPLY =~ ^[Yy]$ ]]
then
start=$SECONDS  
printf '%.0s\n' {1..2}

# Install Go 
printf "\n\033[7;32mSTARTING GO $GOVERSION INSTALLATION IN 3 SECONDS! \033[0m"
echo
sleep 3
echo
mkdir temp 
cd temp
wget https://go.dev/dl/$GO.tar.gz
rm -rf /usr/local/go && tar -C /usr/local/lib -xzf $GO.tar.gz
## Export the path variable
export PATH=$PATH:/usr/local/lib/go/bin
## Show Go verison
echo;go version;echo;sleep 2

# Install NodeJS
echo
printf "\n\033[7;32mSTARTING NODE JS $NODEJSVERSION INSTALLATION IN 3 SECONDS! \033[0m"
printf '%.0s\n' {1..2}
sleep 3
wget https://nodejs.org/dist/$NODEJSVERSION/$NODEJS.tar.gz
VERSION=$NODEJSVERSION
DISTRO=linux-x64
mkdir -p /usr/local/lib/nodejs
tar -xvf node-$VERSION-$DISTRO.tar.gz -C /usr/local/lib/nodejs
## Set the environment variables in .profile
cat >> ~/.profile << EOL
VERSION=$NODEJSVERSION
DISTRO=linux-x64
export PATH=/usr/local/lib/nodejs/node-$VERSION-$DISTRO/bin:$PATH
EOL
## Refresh the profile
. ~/.profile
## Show Node JS version
echo;node -v;echo;sleep 2
## npm version 7 or greater is required by Prometheus. The Node JS installation should install verison 10 or higher of npm.

# Install Prometheus version 2.50.1
echo
printf "\n\033[7;32mSTARTING PROMETHEUS $PROMVERSION INSTALLATION IN 3 SECONDS! \033[0m"
echo;sleep 3;echo
## Create system user and directories
groupadd --system prometheus
useradd -s /sbin/nologin --system -g prometheus prometheus
mkdir /var/lib/prometheus
## Install Prometheus
wget https://github.com/prometheus/prometheus/releases/download/$PROMVERSION/$PROM.tar.gz
tar -xvf $PROM.tar.gz 
mv $PROM /usr/local/bin/prometheus
## Set permissions for system account
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /var/lib/prometheus
chown -R prometheus:prometheus /usr/local/bin/prometheus/consoles
chown -R prometheus:prometheus /usr/local/bin/prometheus/console_libraries
export PATH=/usr/local/bin/prometheus:$PATH

# Build Prometheus service
cat > /etc/systemd/system/prometheus.service <<\EOF
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target
[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus/prometheus \
--config.file /usr/local/bin/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--web.console.templates=/usr/local/bin/prometheus/consoles \
--web.console.libraries=/usr/local/bin/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF
## Start Prometheus service
systemctl daemon-reload
systemctl --now enable prometheus

# Clean UP!
cd ..
rm -r temp/
sleep 2

# Completion messages
clear -x; echo; echo
printf "If the versions of Go, NodeJS, and Prometheus are listed below, then they installed correctly."
printf '%.0s\n' {1..2}
go version
echo;echo "nodejs version=$(node -v)";echo
/usr/local/bin/prometheus/prometheus --version
printf '%.0s\n' {1..2}
printf "\nTime to complete = %s seconds" "$SECONDS"
echo
printf "\n\033[7;32mPROCESS COMPLETE! PROMETHEUS SHOULD NOW BE RUNNING AS A SERVICE.\033[0m"
printf '%.0s\n' {1..2}
echo -e "The main Prometheus configuration YAML file is at: /usr/local/bin/prometheus/prometheus.yml"
printf '%.0s\n' {1..2}
echo -e "Note: To run Prometheus manually, do the following: \n
1. Disable the Prometheus service: 'sudo systemctl --now disable prometheus' \n
2. Access the following directory: /usr/local/bin/prometheus \n
3. Run Prometheus with the 'sudo ./prometheus' command. \n"
printf "\n\033[7;36m ENJOY! \033[0m"

printf '%.0s\n' {1..3}

fi