# Kubernetes Installation on Ubuntu 22.04 (Vanilla)

If you want to install a vanilla version of Kubernetes (kubeadm), and setup a basic cluster, follow the directions below.

---
**Credits:**
These scripts are based on the work of the following:

- https://kubernetes.io/docs/setup/production-environment/container-runtime
- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm
- Sander Van Vugt:
  - https://github.com/sandervanvugt/cka
  - Check out his CKA video Course: https://learning.oreilly.com/videos/certified-kubernetes-administrator/9780138103804

---

## Install Ubuntu Servers

> Note: You will want Ubuntu 22.04 Server or newer for this installation. [ISO Image link](https://releases.ubuntu.com/jammy/ubuntu-22.04.4-live-server-amd64.iso)

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

> Note: If it asks to overwrite a keyring, answer yes (y).

## Initialize Kubernetes on the Controller

(On the Controller VM only) Initialize Kubernetes with the following command:

`sudo kubeadm init`

If you have configured everything, and the scripts ran properly, the Kube should initialize on the controller VM. It may take a few minutes.

## Set up the Client on the Controller

Issue the three commands that were shown to set up the Kubernetes client on the controller:

```console
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

> **IMPORTANT!** If you do not set up the client on the controller, you will not be able to continue properly!

> Note: 
> Alternatively, if you are the root user, you can run:
>
> `export KUBECONFIG=/etc/kubernetes/admin.conf`

## Install Calico Networking on the Controller

For simplicity we are using a Calico networking manifest to set up some networking for our Kubernetes cluster.

On the controller, configure Calico networking with the following command:

`kubectl apply -f calico.yaml`

That should set up networking for your Kubernetes cluster. 👍👍👍

Run the following commands:

- `kubectl get ns`
- `kubectl get all`
- `kubectl get nodes`

This should result in something similar to the following:

```console
NAME              STATUS   AGE
default           Active   9m7s
kube-node-lease   Active   9m7s
kube-public       Active   9m7s
kube-system       Active   9m7s
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   9m4s
NAME         STATUS   ROLES           AGE    VERSION
controller   Ready    control-plane   9m8s   v1.29.2
```

As you can see, we only have one node (the controller). We will add the workers now.

> Note: If for some reason, the command `kubectl apply -f calico.yml` does not work, try checking the following:
> - kubetools were installed
> - client was installed
> - restarting the server (if necessary)

## Connect the Worker Nodes to the Kubernetes Cluster

To connect a worker system to the K8s cluster you need the `sudo kubeadm join` command. 

When your `kubeadm init` command completed on the controller you should have seen the join command (and key) that can be used on the workers. If for some reason you can't see it, you can display it again with the following command on the controller:

`kubeadm token create --print-join-command`

Here's an example of the result:

`kubeadm join 10.42.88.100:6443 --token rl378B.szitojybs62853wn --discovery-token-ca-cert-hash sha256:cfecb24835f0...`

Use that command to join your workers to the Kubernetes cluster. Remember to use `sudo`!

Wait 1 minute for the nodes to be completely joined to the cluster.

Then, on the controller type the following command:

`kubectl get nodes`

You should see results similar to the following:

```console
NAME         STATUS   ROLES           AGE    VERSION
controller   Ready    control-plane   35m    v1.29.2
worker1      Ready    <none>          109s   v1.29.2
worker2      Ready    <none>          95s    v1.29.2
```

If any of your nodes are showing as "Not Ready" give it another minute for them to initialize. 

---

## 👍👍👍👍 That's it! 

The Kubernetes cluster should now be up and running! And yes, quad-thumbs up!

If you have any questions, feel free to contact me:

Website: https://prowse.tech

Discord Server: https://discord.gg/mggw8VGzUp