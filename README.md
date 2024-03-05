# Monitoring Linux and Kubernetes with Prometheus in 3 hours

################

### !!! WORK IN PROGRESS !!!

################

---

Dave Prowse
https://prowse.tech

Discord Server: https://discord.gg/mggw8VGzUp

Copyright (c) 2024 Dave Prowse

---

This is the repository for the live webinar:

***Monitoring Linux and Kubernetes with Prometheus in 3 hours***

All of the labs can be found within.

Link: https://github.com/daveprowse/prom-live

## Prometheus & Linux

Although you can get away with a single Linux system for this course, I highly recommend that you ready at least two, local, Linux virtual machines. One to run Prometheus, and the other to be monitored.

The scripts and labs are designed for **Ubuntu** 22.04 Server or **Debian** 12 server (x64 platform). Work as root or as a user with sudo powers.

If you don't have either Debian or Ubuntu you can download them from the following links.

- Debian 12 [Download](https://www.debian.org/download)
- Ubuntu 22.04 Server [Download](https://releases.ubuntu.com/jammy/ubuntu-22.04.4-live-server-amd64.iso)

> Note: If you choose to run Debian, make sure that you install it as a server. To do so, deselect any desktops (GNOME, KDE, etc...) during the Task Selection phase of the installation.

Most importantly, to install Prometheus see [this link](./prometheus-install/README.md).

## Kubernetes

You might also be interested in running, and monitoring, Kubernetes. During the course I'll be monitoring the following:





- Vanilla Kubernetes cluster (three Ubuntu systems running locally in KVM). For scripts and details for installing an actual Kubernetes cluster, click [here](./z-more-info/k8s-scripts/README.md).
- A MiniKube: For details on how to setup a Minkube, click [here](./z-more-info/minikube/minikube-install.md).
- Amazon EKS
- Google K8s



For instructions on how to install a vanilla K8s cluster see this link  ........

---

> Note: You could even get away with using Docker for everything: Prometheus, a Kubernetes MiniKube, and a separate Debian Docker image, and the whole thing could run on a single system and be fairly lightweight. the downside is that you will lose some functionality and won't be able to follow along with everything we cover in the course. But it's a good substitute if you can't run several virtual machines and/or full K8s clusters.


## Dave's Lab

*insert image here... from phone !!!!!*













---



