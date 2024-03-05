# Kubernetes Installation on Ubuntu 22.04 (Vanilla)

If you want to install a vanilla version of Kubernetes (kubeadm), and setup a basic cluster, follow the directions below.

---
**Credits:**
These scripts are based on the work of the following:

- Sander Van Vugt:
  - https://github.com/sandervanvugt/cka
  - Check out his CKA video Course: https://learning.oreilly.com/videos/certified-kubernetes-administrator/9780138103804
- https://kubernetes.io/docs/setup/production-environment/container-runtime
- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

---

## Install Ubuntu Servers

> Note: You will want Ubuntu 22.04 Server for this installation. [ISO Image link](https://releases.ubuntu.com/jammy/ubuntu-22.04.4-live-server-amd64.iso)

- Install the operating system to a virtual machine. This will be the Kubernetes Controller.
- Make two clones of the virtual machine. These will be Worker1 and Worker2.
- Modify the hostnames and IP addresses of the workers.
- Run `apt update && apt update -y` on all three machines.
- Reboot all three systems
- Verify that you can ping each system from your host.
- Git clone this repository to each Ubuntu Server.
- Within the repository, change to this directory on each host: `z-more-info/k8s-scripts`.

## Install containerd on all three Ubuntu Hosts

- You will find a script named `container-install.sh`.
  - Make sure it is set to execute: `chmod +x container-install.sh`
  - As a best practice, review the script to verify its authenticity.

- Run the script on each host. This will install containerd and configure it as needed for Ubuntu 22.04

  `sudo ./container-install.sh`

When the script is finished you should see a completion message. 👍

Check to make sure the service is active and running:

`systemctl status containerd`

> Note: These scripts address a variety of issues that you can run into when manually installing containerd and kubetools.

## Install the Kubernetes Tools on all three Ubuntu Hosts

- You will find a script named `kubetools-install.sh`.
  - Make sure it is set to execute: `chmod +x kubetools-install.sh`
  - As a best practice, review the script to verify its authenticity.

- Run the script on each host. This will install kubelet, kubeadm, kubectl, and  and configure them as needed for Ubuntu 22.04

  `sudo ./kubetools-install.sh`

When the script is finished you should see a completion message. 👍👍

## Initialize Kubernetes on the Controller

(On the Controller VM only) Initialize Kubernetes with the following command:

`kubeadm init`

If you have configured everything, and the scripts ran properly, the Kube should initialize on the controller VM. It may take a few minutes.

## Set up the Client on the Controller

Issue the three commands that were shown to set up the Kubernetes client on the controller:

```console

```

## Install Calico Networking on the Controller

For simplicity we are using a Calico networking manifest to set up some networking for our Kubernetes cluster.

On the controller, configure Calico networking with the following command:

`kubectl apply -f calico.yaml`






- In the repository you will find a script named `calico-networking.sh`. Make sure that it's permissions are set to execute.

  `chmod container-install.sh`

- Run the script on the controller **ONLY**. 

  `./calic-networking.sh`

