# MiniKube Installation Steps ⚙️

This document briefly covers how to install a MiniKube. MiniKube is a simple installation of a Kubernetes cluster that can run on Docker, Podman, KVM, and other container/virtualization platforms.

This procedure shows how to create a minikube on a Debian 12 Client system with Docker. That's what I will be running during the course. (Ubuntu and other Debian derivatives will have similar installation steps.)

## Have a System Ready

The steps in this document are based on Debian 12 or Ubuntu 22.04. It is recommended that you have one of those running as a virtual machine.

> Note: You could also install the MiniKube to your main system but that is not recommended.

## Update the System

`sudo apt update && apt upgrade -y`

## Configure a User

You will need a user with sudo rights that can install Docker and the minikube. For this example, we'll create the user *sysadmin*.

`adduser sysadmin`

Set a password, and answer the questions.

Give the user sudo permissions:

`usermod -aG sudo sysadmin`

## Install Docker

Docker installations will vary depending on your operating system. To install to Ubuntu Server follow the steps at this link:

https://docs.docker.com/engine/install/debian/

> Note: Many other Linux distros are listed as well.

Verify that Docker is running:

`systemctl status docker`

If it is not running (and/or not enabled) then make it so:

`sudo systemctl --now enable docker`

Add the user to the docker group:

`sudo usermod -aG docker sysadmin && newgrp docker`

Reboot the system if necessary.

## Install minikube

Follow the steps at the following link:

https://minikube.sigs.k8s.io/docs/start/

There are installation scripts for different operating systems. In this scenario we are using Linux / x86-64 / Stable / Binary download.

## Start the Cluster

Run the following command

`minikube start`

This should select Docker as the "driver" automatically and begin downloading and building the minikube. You should see a "Done!" message after a few minutes.

By default, the cluster will be called "minikube" and the namespace will be called "default".

Make sure that it works by issuing a command. For example:

`minikube kubectl get nodes`

That should show the minikube control plane. Also:

`minikube kubectl -- get pods -A`

That should show the installed pods in the minikube.

**💫 Excellent!**

> **Troubleshooting:** If you cannot build and start the minikube make sure that the Docker service is running, that your user has sudo permissions and is a member of the docker group, and reboot if necessary.

---

This is only the beginning. You can do so much with minikube! In addition, if you already have vanilla Kubernetes installed you can use a minikube but with the standard K8s commands (`kubectl`, etc...). If not, consider making an alias to the `minikube` command.

---
