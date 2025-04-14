# ⚙️ Lab 07 - Installing Prometheus and Grafana to K8s using Helm

In this lab we will:

- Install Prometheus and Grafana to a Kubernetes cluster using Helm.
- Connect to Prometheus and Start Monitoring.
- Connect to Grafana Dashboards and monitor with alerts.

> Note: This is the most complex and massive lab so far. Take it step-by-step!

> Note: If you do not have a Kubernetes cluster or minikube running, see the following in the *z-more-info* directory:
> - [MicroK8s Setup](../../z-more-info/microk8s/microk8s-notes.md)
> - [Vanilla Kubernetes Setup](../../z-more-info/k8s-scripts/README.md)
> - [Minikube](../../z-more-info/minikube/minikube-install.md)

---

## Install Prometheus and Grafana to a Kubernetes Cluster using Helm

The Prometheus Community maintains a group of Helm charts that can install Prometheus, node_exporter, alertmanager, kube metrics, and Grafana all at once. Instead of re-inventing the wheel, let's make use of what already exists!

> Note: If you are interested in installing Prometheus and Grafana manually to a K8s cluster than see [Lab x1](../../z-more-info/lab-x1/lab-x1.md). That is, if you like "re-inventing the wheel!" :)

Before beginning the lab, be sure that your controller and workers are up and running properly:

`kubectl get nodes`

> Note: If you are using minikube then run `minikube start`.

### Install Helm and Repositories

First let's install Helm on the Kubernetes controller. Here's the one-liner to install Helm v3.

`curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash`

> Note: That should work on most Linux distributions. See [this link](https://helm.sh/docs/intro/install/) for more Helm installation options.

Check if it installed properly and is executable as a binary:

`helm version`

Now, add the stable Helm charts:

`helm repo add stable https://charts.helm.sh/stable`

Next, add the Prometheus Community Helm repo:

`helm repo add prometheus-community https://prometheus-community.github.io/helm-charts`

Finally, view the available repos within the prometheus-community:

`helm search repo prometheus-community`

There will be a bunch! From here, you can see many awesome (and commonly used) exporters and their versions.

Done!

### Set up and Install Prometheus and Tools

Now we'll setup and install Prometheus, node_exporter, alertmanager, and grafana - which are all part of the "kube-prometheus-stack".

Create a Prometheus namespace:

`kubectl create namespace prometheus`

Install the Prometheus stack using Helm:

`helm install stable prometheus-community/kube-prometheus-stack -n prometheus`

Give this a minute to complete. (It will be silent.)

> Note: If using MicroK8s, precede the last command with `microk8s` (even if you have an alias). Perform this process with other K8s distributions such as minikube if necessary.

When done, issue the following command:

`kubectl get pods -n prometheus`

or

`kubectl --namespace prometheus get pods -l "release=stable"`

> Note: For minikube, use the following command to see the pods:
> `minikube kubectl -- get pods --namespace prometheus`

Take a look at the pods that have been created by the Helm chart. You should see pods for:

- Prometheus itself
- Node exporters (for the controller and each worker in the cluster)
- Grafana
- Alertmanager
- Metrics

Verify that they are all running. There should be about a dozen in total. Run the command again until you see that all pods' status are "Running".

> Note: It may take a couple minutes for all pods to run. This is especially true for minikube and micro instances on the cloud. The more resources you can spare the better!

As you can see, a *lot* of the K8s work has been taken care of for you. Enjoy!

Now check out the services associated with the stack and the IP addresses they are using:

`kubectl get svc -n prometheus`

You should see something similar to:

```console
user@kvm-k8s-controller:$ kubectl get svc -n prometheus
NAME                                      TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                         AGE
alertmanager-operated                     ClusterIP      None             <none>        9093/TCP,9094/TCP,9094/UDP      43m
prometheus-operated                       ClusterIP      None             <none>        9090/TCP                        43m
stable-grafana                            ClusterIP      10.107.83.115    <none>        80:31129/TCP                    43m
stable-kube-prometheus-sta-alertmanager   ClusterIP      10.106.188.78    <none>        9093/TCP,8080/TCP               43m
stable-kube-prometheus-sta-operator       ClusterIP      10.99.158.76     <none>        443/TCP                         43m
stable-kube-prometheus-sta-prometheus     ClusterIP      10.105.51.243    <none>        9090:32696/TCP,8080:32616/TCP   43m
stable-kube-state-metrics                 ClusterIP      10.102.136.212   <none>        8080/TCP                        43m
stable-prometheus-node-exporter           ClusterIP      10.107.8.244     <none>        9100/TCP                        43m
```

> Note: Your IP addresses will differ.

> Note: to see the IPs in minikube use the following command:
> 
> `minikube kubectl -- get svc -n prometheus`

You should be able to connect to Prometheus locally via it's ClusterIP address. (Use the "stable-kube-prometheus-sta-prometheus" pod's IP.)

For example:

`curl http://10.105.51.243:9090`

> Note: Want to see *all* information about the namespace and associated datasets? Try `kubectl get all -n prometheus`

### Remote Access

If you have installed this stack to a cloud-based cluster (AWS, Azure, GKE, Grafana-Cloud) then there is probably an EXTERNAL-IP address assigned to Prometheus and to Grafana. You can access Prometheus (port 9090) and Grafana (port 80) using the displayed IP addresses.

If you installed to a vanilla K8s cluster or minikube then you will probably have to assign an IP to access the services (or expose the services).

#### Vanilla K8s

You have two options to add an external IP to your Prometheus and Grafana services: the service editing option and the one-line command option.

*Service editing*

- `kubectl edit svc stable-kube-prometheus-sta-prometheus -n prometheus`
  - Find `type: ClusterIP` and change it to: `type: LoadBalancer`
  - Add the syntax shown below.
- `kubectl edit svc stable-grafana -n prometheus`
  - Again, find `type: ClusterIP` and change it to: `type: LoadBalancer`
  - Again, add the syntax shown below.

> **Note:** If you are working on a cloud-based system, simply configuring the "ClusterIP" option is often enough. If not, follow the next step.

- Set the IP address within the service configuration files with a new line directly under spec >  clusterIPs:
    
    ```console
    externalIPs:
    - <ip address>
    ```

*One-line command*

- Issue the following two commands to set the External-IP address as a LoadBalancer configuration:
  - `kubectl patch svc stable-kube-prometheus-sta-prometheus -n prometheus -p '{"spec": {"type": "LoadBalancer", "externalIPs":["<ip_address>"]}}'`
  - `kubectl patch svc stable-grafana -n prometheus -p '{"spec": {"type": "LoadBalancer", "externalIPs":["<ip_address>"]}}'`
   > Note: Remember to replace `<ip_address>` with the IP address of your Kubernetes controller!

Check your work with `kubectl get svc -n prometheus`. You should see the EXTERNAL-IP addresses and they should now be accessible from remote systems.

#### minikube

For minikube, you'll need to patch the IP addresses for the Prometheus and Grafana services and then expose those services so you can connect to them via the web browser.

1. Patch the IPs for Prometheus and Grafana:

    `minikube kubectl -- patch svc stable-kube-prometheus-sta-prometheus -n prometheus -p '{"spec": {"type": "LoadBalancer", "externalIPs":["<IP_address>"]}}'`

    `minikube kubectl -- patch svc stable-grafana -n prometheus -p '{"spec": {"type": "LoadBalancer", "externalIPs":["<IP_address>"]}}'`

    > Note: Use the actual IP address of the system that is hosting the minikube. So remove `<IP_address>` and replace it with the actual IP address.

    > Note: You could also do service editing as shown in the "Vanilla K8s" section previously.

2. Expose the Prometheus and Grafana services. Run each of the following commands in separate terminals.

    `minikube service stable-kube-prometheus-sta-prometheus --namespace=prometheus`

    `minikube service stable-grafana --namespace=prometheus`

    > Note: Each one should attempt to open a web browser automatically. If not, attempt to connect manually to the link named in the URL field that is displayed.

## Connnect to Prometheus and Start Monitoring

Now, connect to the Prometheus web UI

`http:<ip_address>:9090`

> Note: For minikube, use the address and port that was exposed and connect locally.

In the expression field type the following query:

`kube_configmap_info`

View the content in Table mode.

You should see a whole boatload of metrics that come from the *kube-state-metrics* container (note the IP of that container). These metrics (and others) are all built into the Prometheus stack that we installed. (Yet another reason to use this Helm chart.)

Now issue the following query:

`kube_pod_ips`

Review the IP addresses used by the controller and workers, and the containers.

View the "Alerts" section. Bask in the glory of pre-built alerts!
  
## Connnect to Grafana Dashboards, and Monitor

Now, let's connect to the Grafana server from the browser. Remember that we are simply connecting via port 80. In the field you will want to incorporate TLS on the front-end so that you have an extra layer of security for your Grafana server.

`http://<ip_address>`
  
The password should be *prom-operator* but if it is different, you can decipher and decode it with the following command at your Kubernetes controller or minikube system.

`kubectl get secret --namespace prometheus stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo`

### Examine Dashboards

Let's take a look at a few of the built-in dashboards. Take a minute to examine each of these:

- Kubernetes / Compute Resources/ Node (pods)
  - Check the different nodes (or all at once!)
- Kubernetes / Compute Resources/ Workload
  - Select the *prometheus* namespace and examine the different workloads.  
- Node Exporter/ Nodes
  - Stress out your workers!
    - Try `openssl speed -multi $(nproc --all)` to stress the CPUs
    - Or the `stress` program: `stress -c 1 -m 10`
  - View the results in the dashboard! (Be ready for delays in data - as much as 5 minutes depending on the setup and systems.)
  - *Bonus*: Check out the stress that is being imposed on the server housing your Kubernetes cluster. Use `top` or a similar program. At this point it should be working harder!

---
*♥️  Shout out to the Prometheus Monitoring Community! ♥️*

https://github.com/prometheus-community

---

### Examine Kubelet Metrics

On your Kubernetes controller run the following command:

`kubectl get nodes -o wide`

This should show the controller IP address (or minikube IP address if you are using minikube).

Now, attempt to query the main Prometheus metrics for that IP address:

`curl http://<ip_address>/metrics`

This should show the metrics for Prometheus that are being scraped.

Now, find out the IP address of the container that is providing kubelet metrics:

`kubectl --namespace prometheus get pods -l "release=stable" -o wide`

> Note: This is a formal way of issuing the command. Lots of abbreviations and truncations you can do!

You should see all pods that are running including one called *stable-kube-state-metrics*. Look at the IP address that this is being served on. Then, curl that Ip address on port 8080 (the default for this Prometheus stack). Example:

`curl http://192.168.86.161:8080/metrics | less`

That's a lot of metrics. Effectively, these are what Prometheus is scraping from and displaying when you run PromQL queries in the web UI. They are also what are displayed in the Grafana dashboards.

**Again, it is the legend.**

### Examine Kubelet Metrics in Grafana

Open the following dashboard:

Kubernetes / Kubelet

Spend a minute looking at the gauges and counters in the dashboard.

This is a pretty good representation of the important metrics that Prometheus is scraping from your kubelet. You should see:

- Running Kubelets
- Running Pods
- Running Containers
- Operations per second (known as ops/s) which will count total ops, error rate, and more
- Storage operation information

This is a great first stop to see the health of your kubelet.

### Deploy a Web Server to the Cluster and Monitor

Now, let's deploy a basic http web server to the Kubernetes cluster and monitor it from Grafana.

> Note: This lab may require additional configurations for minikube users.

- First, create a new namespace on your K8s controller (or minikube):
  - `kubectl create ns http`
- View it and verify that it was created:
  - `kubectl get ns`
- Copy the `http.yml` file to your controller and create a pod based on that config:
  - `kubectl apply -f http.yml`
- Verify that all pods are running before continuing:
  - `kubectl get all -n http`

> Note: this may take a minute to complete because it has to fetch and install the web server.

When done, it should look similar to this:

```console
sysadmin@controller:~$ kubectl get all -n http
NAME                                    READY   STATUS    RESTARTS   AGE
pod/httpd-deployment-67fcb6ffc9-lmh6r   1/1     Running   0          48s
pod/httpd-deployment-67fcb6ffc9-p6xgv   1/1     Running   0          48s

NAME                    TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
service/httpd-service   NodePort   10.110.132.145   <none>        8080:32321/TCP   48s

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/httpd-deployment   2/2     2            2           48s

NAME                                          DESIRED   CURRENT   READY   AGE
replicaset.apps/httpd-deployment-67fcb6ffc9   2         2         2       48s
```

Make note of the ports being used by *service/httpd-service* - specifically the second port (in this case port 32321). Try connecting to the web server on that port using the controller node's main IP address. For example:

`curl http://10.42.88.100:32321`

If the return message says that "It works!" then you are good.

Now view that namespace in Grafana. Go to the dashboard:

- Kubernetes / Compute Resources / Workload

Then, change the namespace dropdown to *http*.

You should see the CPU usage (and quota) for that namespace.

Add a threshold for alerts:

- On the CPU Usage panel click the edit (3 dots) button and select edit.
- Scroll down to Thresholds
- Add one at 80% (or T1 level 2 absolute).
- Set "Show Thresholds" as "lines".
- Apply it to the panel.

Run a couple tests against the web server service (from within a worker in the cluster or from without). For example:

`ab -n 1000000 -c 1000 http://10.42.88.100:32321/index.html`

View the change in the Grafana dashboard. Keep in mind that there might be a delay. You can also configure any thresholds that you set to set off alerts as well. (Depending on the resources in your cluster you might need to select lower options, for example `ab -n 10000 -c 100`.)

> Note: You can see this activity from a Linux point of view by opening the `top` program on the K8s controller and looking for the *ksoftirqd/3* process.

Also check out the following dashboards:

- Kubernetes / Compute Resources / Namespaces (Workloads)
- Kubernetes / Compute Resources / Cluster
- Alertmanager / Overview

Boom! You are monitoring Kubernetes!

---
You can use several other built-in dashboards to further monitor the service, pods, namespace, and so on. This is going to work in essentially the same manner for other applications. However, if you are creating your own applications, you will often need to configure the scraping of metrics as well.

---

## Extra Credit

- Solo Grafana install with Helm: https://grafana.com/docs/grafana/latest/setup-grafana/installation/helm/
- Learn more about the Prometheus Certification: https://training.linuxfoundation.org/certification/prometheus-certified-associate/
- Consider these other tools for stress testing Kubernetes: 
  - K6, JMeter, Locust, Siege, Gatling, Kube-burner, and PowerfulSeal.