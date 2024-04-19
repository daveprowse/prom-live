# ⚙️ Lab 07 - Installing Prometheus and Grafana to K8s using Helm

In this lab we will:

- Install Prometheus and Grafana to a Kubernetes cluster using Helm.
- Connect to Prometheus and Start Monitoring.
- Connect to Grafana Dashboards and monitor with alerts.

> Note: This is the most complex lab so far. Take it slow!

## Install Prometheus and Grafana to a Kubernetes cluster using Helm

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

Give this a minute to complete.

When done, issue the following command:

`kubectl get pods -n prometheus`

or

`kubectl --namespace prometheus get pods -l "release=stable"`

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

You should be able to connect to Prometheus locally via it's ClusterIP address. For example:

`curl http://10.105.51.243:9090`

> Note: Want to see *all* information about the namespace and associated datasets? Try `kubectl get all -n prometheus`

### Remote Access

If you have installed this stack to a cloud-based cluster (AWS, Azure, GKE, Grafana-Cloud) then there is probably an EXTERNAL-IP address assigned to Prometheus and to Grafana. You can access Prometheus (port 9090) and Grafana (port 80) using the displayed IP addresses.

If you installed to a vanilla K8s cluster or minikube then you will probably have to assign an IP to access the services (or expose the services).

**Vanilla K8s**

To assign IP addresses for a vanilla K8s clusters stored in the cloud, edit the appropriate services (shown below). If you have a locally running vanilla K8s cluster, then skip the service editing portion and move right to the IP address patching portion.

Service editing:
- `kubectl edit svc stable-kube-prometheus-sta-prometheus -n prometheus`
- Find `type: ClusterIP` and change it to: `type: LoadBalancer`
- `kubectl edit svc stable-grafana -n prometheus`
- Again, find `type: ClusterIP` and change it to: `type: LoadBalancer`

IP address patching:

- Now, if you still don't have associated IP addresses, or if you skipped the service editing step, then associate the IP address of the Kubernetes controller with both services:
  - `kubectl patch svc stable-kube-prometheus-sta-prometheus -n prometheus -p '{"spec": {"type": "LoadBalancer", "externalIPs":["<ip_address"]}}'`
  - `kubectl patch svc stable-grafana -n prometheus -p '{"spec": {"type": "LoadBalancer", "externalIPs":["<ip_address>"]}}'`
   > Note: Remember to replace `<ip_address>` with the IP address of your Kubernetes controller!

> **Note:** You could also set the IP address within the service configuration files with a new line directly under spec >  clusterIPs:
> ```console
> externalIPs:
> - <ip address>
> ```

Check your work with `kubectl get svc -n prometheus`. You should see the EXTERNAL-IP addresses and they should now be accessible from remote systems.

**minikube**

Expose the Prometheus and Grafana services. Run each of the following commands in separate terminals.

`minikube service stable-kube-prometheus-sta-prometheus --namespace=prometheus`

`minikube service stable-grafana --namespace=prometheus`

> Note: Each one will attempt to open a web browser automatically. If not, attempt to connect manually.

## Connnect to Prometheus and Start Monitoring

Now, connect to the Prometheus web UI

`http:<ip_address>:9090`

> Note: For minikube, use the address and port that was exposed and connect locally.

In the expression field type the following query:

`kube_configmap_info`

View the content in Table mode.

You should see a whole boatload of metrics that come from the *kube-state-metrics* container. These metrics (and others) are all built into the Prometheus stack that we installed. (Yet another reason to use this Helm chart.)

Now issue the following query:

`kube_pod_ips`

Review the Ip addresses used by the controller and workers, and the containers.

View the "Alerts" section. Bask in the glory of pre-built alerts!
  
## Connnect to Grafana Dashboards, and monitor with alerts

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
  - View the results in the dashboard (be ready for delays in data)

*♥️  Shout out to the Prometheus Community! ♥️*



## More to come!

---
## Extra Credit

Solo Grafana install with Helm: https://grafana.com/docs/grafana/latest/setup-grafana/installation/helm/
