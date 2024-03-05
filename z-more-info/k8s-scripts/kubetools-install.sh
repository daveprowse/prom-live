#!/bin/bash
# Based on: https://kubernetes.io/docs/setup/production-environment/container-runtime
# And original work by sander Van Vugt: https://github.com/sandervanvugt/cka
# Designed for Ubuntu 22.04 Server
# Run with sudo permissions.

# Variables and startup
clear -x
if [ "$(id -u)" -ne 0 ]; then echo;echo "Please run with 'sudo'." >&2; echo; exit 1; fi
printf "\n\033[7;31mTHIS SCRIPT WILL INSTALL THE KUBETOOLS \033[0m"
printf '%.0s\n' {1..2}
read -p "Are you sure? [y,n]:  " -n 1 -r
printf '%.0s\n' {1..2}
if [[ $REPLY =~ ^[Yy]$ ]]
then
start=$SECONDS  
printf '%.0s\n' {1..2}

# Kubernetes configuration for netfilter
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
	br_netfilter
EOF

# Kubetools install
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
swapoff -a

sed -i 's/\/swap/#\/swap/' /etc/fstab

# Configure netfilter iptables bridging
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# Configure ctictl
sudo crictl config --set \
    runtime-endpoint=unix:///run/containerd/containerd.sock
echo 'after initializing the control node, follow instructions and use kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml to install the calico plugin (control node only). On the worker nodes, use sudo kubeadm join ... to join'

# Completion Messages
printf '%.0s\n' {1..3}
printf "\nTime to complete = %s seconds" "$SECONDS"
echo
printf "\n\033[7;32mPROCESS COMPLETE! THE KUBETOOLS SHOULD NOW BE INSTALLED. CONTINUE WITH THE README FILE! \033[0m"
printf '%.0s\n' {1..2}

fi