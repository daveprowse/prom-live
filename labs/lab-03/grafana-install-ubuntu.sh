#!/bin/bash

#########################################

## March, 2024. Written by Dave Prowse: https://prowse.tech

## This script will install Grafana to Ubuntu 22.04/24.04 or Debian 12 and run it as a service. 

## Check that your firewalls have port 3000 open.

## !!! THIS IS FOR EDUCATIONAL PURPOSES ONLY. ONLY RUN THIS SCRIPT ON A TEST SYSTEM !!!

#########################################

# sudo check and confirmation
clear -x
if [ "$(id -u)" -ne 0 ]; then echo;echo "Please run as root or with 'sudo'." >&2; echo; exit 1; fi

printf "\n\033[7;31mTHIS SCRIPT WILL INSTALL GRAFANA AND RUN IT AS A SERVICE ON UBUNTU OR DEBIAN. \033[0m"
printf '%.0s\n' {1..2}
read -p "Are you sure you want to proceed? (y,n): " -r response
printf '%.0s\n' {1..2}
if [[ $response =~ ^[Yy]$ ]]; then
start=$SECONDS  
printf '%.0s\n' {1..2}

# Install Grafana
echo
sleep 1
echo
apt-get install -y apt-transport-https software-properties-common wget
mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | tee -a /etc/apt/sources.list.d/grafana.list
apt-get update
apt-get install grafana -y

# Start and enable the service
systemctl daemon-reload
systemctl --now enable grafana-server.service

# Completion messages
printf '%.0s\n' {1..2}
printf "\nTime to complete = %s seconds" "$SECONDS"
echo
printf "\n\033[7;32mPROCESS COMPLETE! GRAFANA SHOULD NOW BE RUNNING AS A SERVICE AND LISTENING ON PORT 3000.\033[0m"
printf '%.0s\n' {1..2}
printf "\n\033[7;36m ENJOY! \033[0m"
printf '%.0s\n' {1..2}
fi