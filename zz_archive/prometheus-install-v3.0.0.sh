#!/bin/bash

#########################################

## Updated November, 2024. Written by Dave Prowse: https://prowse.tech

## This script will install Prometheus on Debian 12 or Ubuntu 22.04/24.04 x64 systems.
### It can also work with CentOS but you may have to run this command: 'chcon -t bin_t '/usr/bin/prometheus'
## Prometheus will be set up as a service that runs automatically.

## This script requires that you work as `root` or with sudo capabilities. 

## !!! THIS IS FOR EDUCATIONAL PURPOSES ONLY. ONLY RUN THIS SCRIPT ON A TEST SYSTEM !!!

### TODO:  Go env var (bash issue), DB dirs and config (data and metrics2), systend hardening options in service file, EnvironmentFile=/etc/default/prometheus in [Service] ???, , more bash linting...

#########################################

# Variables
PROMVERSION=v3.0.0
PROM=prometheus-3.0.0.linux-amd64
UBUNTU_MAN_VERSION=noble

clear -x

if [ "$(id -u)" -ne 0 ]; then echo;echo "Please run as root or with 'sudo'." >&2; echo; exit 1; fi

printf "\n\033[7;31mTHIS SCRIPT WILL INSTALL PROMETHEUS %s \033[0m" "$PROMVERSION"
printf '%.0s\n' {1..2}
read -p "Are you sure you want to proceed? (y,n): " -r response
printf '%.0s\n' {1..2}
if [[ $response =~ ^[Yy]$ ]]; then
start=$SECONDS  
printf '%.0s\n' {1..2}

# Install Prometheus
echo
printf "\n\033[7;32mSTARTING PROMETHEUS %s INSTALLATION IN 3 SECONDS! \033[0m" "$PROMVERSION"
echo;sleep 3;echo
## Create system user and directories
groupadd --system prometheus
useradd -s /sbin/nologin --system -g prometheus prometheus
mkdir -p /var/lib/prometheus/metrics2
mkdir -p {/etc/prometheus,/usr/share/prometheus/web}
## Download, extract, and copy Prometheus files
wget https://github.com/prometheus/prometheus/releases/download/$PROMVERSION/$PROM.tar.gz
tar -xvf $PROM.tar.gz 
cd $PROM || return
cp {prometheus,promtool} /usr/bin/
cp -r {console_libraries/,consoles/,LICENSE,NOTICE,prometheus.yml} /etc/prometheus
## Set permissions for system account
chown prometheus:prometheus /usr/bin/prometheus
chown -R prometheus:prometheus /var/lib/prometheus
chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries

# Build Prometheus service
cat << "EOF" > "/lib/systemd/system/prometheus.service"
[Unit]
Description=Monitoring system and time series database (Prometheus)
Documentation=https://prometheus.io/docs/introduction/overview/ man:prometheus(1)
After=time-sync.target

[Service]
Restart=on-failure
User=prometheus
Group=prometheus
ExecStart=/usr/bin/prometheus $ARGS \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/metrics2 \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries
ExecReload=/bin/kill -HUP $MAINPID
TimeoutStopSec=20s
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
EOF

# Start Prometheus service and re-issue ownership to database location
systemctl daemon-reload
systemctl --now enable prometheus
chown -R prometheus:prometheus /var/lib/prometheus

# Install Man pages - From Ubuntu
cd ..
wget https://manpages.ubuntu.com/manpages.gz/$UBUNTU_MAN_VERSION/man1/prometheus.1.gz
cp prometheus.1.gz /usr/share/man/man1
wget https://manpages.ubuntu.com/manpages.gz/$UBUNTU_MAN_VERSION/man1/promtool.1.gz
cp promtool.1.gz /usr/share/man/man1

# Clean UP!
cd ..
rm -rf temp/
## exec new bash for users
sleep 2

# Completion messages
clear -x; echo; echo
printf "If the Prometheus version is listed below, then it is installed correctly."
printf '%.0s\n' {1..2}
prometheus --version
printf '%.0s\n' {1..2}
printf "\nTime to complete = %s seconds" "$SECONDS"
echo
printf "\n\033[7;32mPROCESS COMPLETE! PROMETHEUS SHOULD NOW BE RUNNING AS A SERVICE.\033[0m"
printf '%.0s\n' {1..2}
echo -e "The main Prometheus configuration YAML file is at: /etc/prometheus/prometheus.yml"
printf '%.0s\n' {1..2}
echo -e "Note: To run Prometheus manually, do the following: \n
1. Stop the Prometheus service: 'sudo systemctl stop prometheus' \n
2. Run the prometheus command, for example: 'prometheus --config.file=/etc/prometheus/prometheus.yml' \n
3. Have fun! \n"
printf "\n\033[7;36m ENJOY! \033[0m"

printf '%.0s\n' {1..3}

# completion of the if-else statement
else
  echo "Installation cancelled."
fi