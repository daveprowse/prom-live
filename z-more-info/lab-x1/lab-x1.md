# ⚙️ Lab x1 - Installing Prometheus and Grafana to K8s Manually

In this lab we will install Prometheus and Grafana to a K8s cluster manually. This lab is designed for those of you that want to play around with some manual configurations. An "easier" option is to install using Helm, which is what we do in Lab 07.

> Note: The lab is designed for minikube and vanilla K8s cluster. If a command needs to be run as one or the other, I will refer to them as "minikube" or "vanilla K8s".

## minikube pre-work

**For minikube users only!**

Start up your minikube:

`minikube start`

Check the status:

`minikube status`

`minikube kubectl -- get po -A`

Verify that everthing is running properly.

> Note: If you haven't already, add an alias for the `minikube kubectl` command. You can do this temporarily in the terminal or permanently in your .bashrc file.
>
> `alias kubectl="minikube kubectl --"`

## Install Prometheus to Kubernetes

First, check your cluster to make sure that the controller and workers are up:

`kubectl get nodes`

Now, create a namespace for Prometheus:

`kubectl create namespace prometheus`

Next, create and apply a Prometheus configuration.

- Copy the supplied `k8-prom-config.yml` file to your Kubernetes controller.
- Apply the config: `kubectl apply -f k8-prom-config.yml -n prometheus`

> Note: This configuration also has a section for the Grafana dashboard that we will be installing later.

Then, build a Prometheus deployment:

- Copy the supplied `k8-prom-deploy.yml` file to your Kubernetes controller.
- Apply the config: `kubectl apply -f k8-prom-deploy.yml -n prometheus`

> Note: This may take a little time to deploy depending on your virtual machine specs and Internet connection.

Expose the Prometheus service:

- Copy the supplied `k8-prom-service.yml` file to your Kubernetes controller.
- Apply the config: `kubectl apply -f k8-prom-service.yml -n prometheus`

> Note: I used port 9090 in the `k8-prom-service.yml` file. You can change that to whatever you like where it says `port: 9090`.

## Access Prometheus

At this point, Prometheus is exposed via the Kubernetes API on the CLUSTER-IP address. You can find out the that address by issuing the following command:

`kubectl get service prometheus-service -n prometheus`

For example:

```console
user@kvm-k8s-controller:~$ kubectl get service prometheus-service -n prometheus
NAME                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
prometheus-service   LoadBalancer   10.96.163.136   <pending>     80:30814/TCP   10m
```

Attempt a basic connection:

`curl http://<CLUSTER-IP>`

You should see that the "graph" directory in Prometheus is found. So this will now work locally.

---
**minikube users** You will need to expose the service if you want to access Prometheus through the browser:

`minikube service prometheus-service --namespace=prometheus`

That should display the URL that you can connect with and open a browser window automatically (if you are working with a Linux desktop).

---

However, if you want to access Prometheus from an external system you will have to configure some type of routing, port forwarding, or patch the service. The patch is a quick way of gaining access. For example:

`kubectl patch svc prometheus-service -n prometheus -p '{"spec": {"type": "LoadBalancer", "externalIPs":["10.42.88.100"]}}'`

> Note: Replace the IP address in square brackets with the IP address of your target host (Kubernetes controller).

> Note: This may or may not work in a minikube environment!

To verify if worked, run the previous command again:

`kubectl get service prometheus-service -n prometheus`

It should show the EXTERNAL-IP as the IP address you selected.

> Note: Obviously, we are now moving into territory where there are lots of options. Feel free to configure networking as you see fit!

Now, access the Prometheus web ui for your Kubernetes cluster. In the web browser it is:

`http://<ip_address>:9090`

That's because we are forwarding port 9090 of the host IP address to port 9090 of the Kubernetes CLUSTER-IP for the service.

There you go, a working Prometheus installation within your K8s cluster.

## Install Grafana

Create a namespace:

`kubectl create namespace my-grafana`

Copy `grafana.yml` to your Kubernetes controller.

Send the manifest to the Kubernetes API server:

`kubectl apply -f grafana.yaml --namespace=my-grafana`

> Note: This may take a minute or so to complete.

View the Grafana namespace:

`kubectl get all --namespace=my-grafana`

You should see the CLUSTER-IP information. You can connect locally to this IP address.

If you have installed this on a cloud-based service (AWS, GKE, Azure, Grafana Cloud) then the EXTERNAL-IP address should already be visible.

If you installed to a local K8s cluster than you may have to bind the actual IP address of the K8s controller. For example:

`kubectl patch svc grafana -n my-grafana -p '{"spec": {"type": "LoadBalancer", "externalIPs":["10.42.88.100"]}}'`

> Note: This is a quick patch, but may not be the best option in the field! Explore other networking and port forwarding options.

---
**minikube users** You will need to expose the service if you want to access Prometheus through the browser:

`minikube service grafana --namespace=my-grafana`

That should display the URL that you can connect with and open a browser window automatically (if you are working with a Linux desktop). It will use port 80 by default.

---

😁 This is how we do Prometheus. 😁

---

## Extra Credit

Learn more about installing Grafana:

https://grafana.com/docs/grafana/latest/setup-grafana/installation/kubernetes/

---
