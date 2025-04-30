#!/bin/bash

#########################################

## March, 2024. Written by Dave Prowse: https://prowse.tech

## This script will install Grafana to CentOS, RHEL, or Fedora and run it as a service. 

## Check that your firewalls have port 3000 open.

## !!! THIS IS FOR EDUCATIONAL PURPOSES ONLY. ONLY RUN THIS SCRIPT ON A TEST SYSTEM !!!

#########################################

# sudo check and confirmation
clear -x
if [ "$(id -u)" -ne 0 ]; then echo;echo "Please run as root or with 'sudo'." >&2; echo; exit 1; fi

printf "\n\033[7;31mTHIS SCRIPT WILL INSTALL GRAFANA AND RUN IT AS A SERVICE ON CENTOS, FEDORA, OR RHEL. \033[0m"
printf '%.0s\n' {1..2}
read -p "Are you sure you want to proceed? (y,n): " -r response
printf '%.0s\n' {1..2}
if [[ $response =~ ^[Yy]$ ]]; then
start=$SECONDS  
printf '%.0s\n' {1..2}

# Set up the repository
echo
sleep 1
echo
wget -q -O gpg.key https://rpm.grafana.com/gpg.key
rpm --import gpg.key
cat > /etc/yum.repos.d/grafana.repo <<\EOF
[grafana]
name=grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
exclude=*beta*
EOF

# Install Grafana
dnf install grafana -y

# Start and enable the service
systemctl daemon-reload
systemctl --now enable grafana-server.service

# Completion messages
printf '%.0s\n' {1..2}
printf "\nTime to complete = %s seconds" "$SECONDS"
echo
/usr/share/grafana/bin/./grafana --version
echo
printf "\n\033[7;32mPROCESS COMPLETE! GRAFANA SHOULD NOW BE RUNNING AS A SERVICE AND LISTENING ON PORT 3000.\033[0m"
printf '%.0s\n' {1..2}
printf "\n\033[7;36m ENJOY! \033[0m"
printf '%.0s\n' {1..2}
fi