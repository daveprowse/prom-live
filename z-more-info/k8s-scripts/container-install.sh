#!/bin/bash
# Based on: https://kubernetes.io/docs/setup/production-environment/container-runtime
# And original work by sander Van Vugt: https://github.com/sandervanvugt/cka
# Designed for Ubuntu 22.04 Server
# Run as sudo

# Variables and starup
PLATFORM=amd64
clear -x

# Start installation of containerd
if [ "$(id -u)" -ne 0 ]; then echo;echo "Please run with 'sudo'." >&2; echo; exit 1; fi
printf "\n\033[7;31mTHIS SCRIPT WILL INSTALL CONTAINERD \033[0m"
printf '%.0s\n' {1..2}
read -p "Are you sure? [y,n]:  " -n 1 -r
printf '%.0s\n' {1..2}
if [[ $REPLY =~ ^[Yy]$ ]]
then
start=$SECONDS  
printf '%.0s\n' {1..2}
## containerd preparation and modprobe
cat <<- EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
## Persistent modifications to sysctl including ipv4 forwarding and nftables > iptables call
cat <<- EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# (Install containerd)
sudo apt-get update && sudo apt-get install -y containerd
sudo systemctl stop containerd
## cleanup old files from previous attempt if it exists
[ -d bin ] && rm -rf bin
wget https://github.com/containerd/containerd/releases/download/v1.6.15/containerd-1.6.15-linux-${PLATFORM}.tar.gz 
tar xvf containerd-1.6.15-linux-${PLATFORM}.tar.gz
sudo mv bin/* /usr/bin/

# Configure containerd
sudo mkdir -p /etc/containerd
cat <<- TOML | sudo tee /etc/containerd/config.toml
version = 2
[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    [plugins."io.containerd.grpc.v1.cri".containerd]
      discard_unpacked_layers = true
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true
TOML

# Restart containerd
sudo systemctl restart containerd	

# Completion Messages
clear -x; echo; echo
printf "\nTime to complete = %s seconds" "$SECONDS"
echo
printf "\n\033[7;32mPROCESS COMPLETE! CONTAINERD SHOULD NOW BE INSTALLED AND RUNNING AS A SERVICE.\033[0m"
printf '%.0s\n' {1..2}

fi