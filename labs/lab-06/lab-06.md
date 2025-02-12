# ⚙️ Lab 06 - Monitoring Linux

Now let's get into some more Linux monitoring with Prometheus.

In this lab we will:

- Install the node_exporter Grafana Dashboard
- Test against nodes and analyze the results
- Install the alert_manager
- Configure and view an alert

> Note: This is a large lab. Take it slow, and take breaks as necessary.

## Install the node_exporter Grafana Dashboard

Let's install the node_exporter dashboard for Grafana into our main Prometheus monitoring system.

This is a pre-built, readily available, dashboard available at:

https://grafana.com/grafana/dashboards/1860-node-exporter-full/

You just need to copy the ID (or URL) from the website over to a new Grafana dashboard on your system. Copy the ID to your clipboard now.

On your main Prometheus monitoring system:

- Click on Dashboards
- Click New, then Dashboard.
- Click "import dashboard".
- Paste in the dashboard ID and click "Load".

  > Note: at the time of this writing, the ID is 1860.

- Select a name for the dashboard.
- Select the Prometheus data source. This should be *prometheus-1*.
- Click "Import".

You should now see the new dashboard but it won't show any metrics until we configure it.

### Configure prometheus.yml

Add the following job:

```yml
  - job_name: node
    static_configs:
      - targets: ['<ip_address>:9100']
```

> Note: We could use the previous job where Prometheus was scraping from the node_exporter, but I'd like to keep the jobs separate.

Restart the prometheus service.

### Configure the Dashboard

Go back to Grafana and modify the following:

- Datasource = prometheus
- Job = node
- Host = *whatever host you want to monitor!*

> Note: Refresh the browser if the new job doesn't show up.

At this point you should see real metrics for the host you are monitoring.

You might see high CPU usage. Change the time range to something shorter, for example 5 minutes.

> Note: If you are doing this locally - meaning that you are running everything on one system, you may also see that the CPU is more busy than usual. Consider doing your testing on secondary systems.

Configure the dashboard as you like. Click and drag line graphs; move, edit, or delete individual gauges, etc...

If you make any changes to the configuration of the dashboard, be sure to SAVE them!

## Test against the Nodes and Analyze the Results

Time to do some testing so that we can simulate server usage and view those results in the Grafana dashboard.

### dd Test

First, let's simulate CPU usage. On the host to be monitored, run the following command:

`dd if=/dev/zero of=/dev/null &`

This command will copy "zero" to absolutely nowhere. This process will utilize one of the CPU cores of the system. The ampersand (&) runs the process in the background (forks it).

Now go to the Grafana dashboard and view the *CPU Busy* gauge and the *CPU Basic* graph. You should see something to the effect of 25% CPU usage. (Could be more or less depending on your system.)

To stop the test, type the `fg` command to bring the process back to the foreground, then press `Ctrl + C`. That will terminate the test.

> Note: If that doesn't work, use the kill command or top to terminate the `dd` command process. You will have noted that the PID was listed when you first began the `dd` command.

Now view the dashboard again. After a short delay you should see that the CPU usage has gone back down to normal. Refresh the dashboard if necessary.

### Download Test

Download a large file. For example, this Ubuntu .iso image.

`wget https://releases.ubuntu.com/jammy/ubuntu-22.04.4-desktop-amd64.iso`

As the file is downloading, go back to the dashboard, scroll down, and look at the *Network Traffic Basic* graph. It should show the amount of data that is being transmitted per second. (For example, 200 Mb/s.) Refresh the dashboard if necessary.

### Apache ab Test

Install the Apache web server to the system to be monitored.

`sudo apt install apache2 -y`

Enable and run the Apache service:

`sudo systemctl --now enable apache2`

Check it to make sure it is active and running:

`systemctl status apache2`

If you have more than one system, install the Apache Utilities to the monitoring system.

`sudo apt install apache2-utils -y`

On the monitoring system, run the `ab` command to simulate HTTP queries to the second system (the one to be monitored). For example:Why re-create the wheel? (Or gauge as the case may be :) )

`ab -n 1000000 -c 100 http://10.42.88.2:80/index.html`

> Note: you could use any working web server on the remote system.

Go to the main monitoring system's Grafana dashboard and view the *CPU Busy* and *Sys Load* gauges (as well as the *CPU Basic* graph). These should start spiking very quickly. If it peaks to 100% and won't lessen, consider changing the `-n` parameter to something less.

> Note: If you are not receiving results, change your time frame to a minute or less and/or refresh the dashboard.

To really flood the CPU, try increasing the options:

`ab -n 10000000 -c 1000 http://10.42.88.2:80/index.html`

While that is a good test of the system load, it doesn't really test the Apache web server itself. That is for later!

> **IMPORTANT!** Keep in mind that these were only tests. Real-world data may look different!

## Install the alertmanager

The alertmanager tool is used to notify persons (or systems) of important happenings: downed systems, heavy CPU or disk usage, potential security alerts, and more.

Let's install the alertmanager to the main Prometheus monitoring system.

There is an included script `alertmanager-install.sh` in this directory that will install the alertmanager and run it as a service automatically.

To use the script, set the permissions to executable, and run the script with sudo.

`chmod +x alertmanager-script.sh`

`sudo ./alertmanager-script.sh`

When you are done, check the installation and service:

`alertmanager --version`

`systemctl status alertmanager`

---

**Manual Installation**

If you would like to install it manually, you can do it from the following links:

- https://prometheus.io/download/
- https://github.com/prometheus/alertmanager

Keep in mind that you install it manually, you will have to run it manually with the following command:

`./alertmanager`

## Configure and View an Alert

Let's configure a very basic alert. We want to be notified if one of the systems that we are monitoring goes down.

### Build and Configure Rules/Alerts

With sudo, create a file in `'etc/prometheus` called `rules.yml` and add the following code:

```yaml
groups:
  - name: node_rules
    rules:
      - alert: host-is-down
        expr: up{job="node"} == 0
```

Save the file.

> Note: If you are running Prometheus manually, save the rules file to wherever you extracted Prometheus.

Now, point to that rules file from the prometheus configuration file.

- Open prometheus.yml
- Find the `rule_files` section.
- Change `first_rules.yml` to `/etc/prometheus/rules.yml` and uncomment it.

Restart the prometheus and alertmanager services:

`sudo systemctl restart {alertmanager,prometheus}`

Check them to make sure they are active:

`systemctl status {alertmanager,prometheus}`

### View the new Alert

Wait about 5 to 10 seconds for everything to come up and access your Prometheus web UI.

Click "Alerts". This should now show the "host-is-down" alert. However, it is green, because none of the hosts we are monitoring have gone down yet!

Now, shut down the remote system that you are monitoring.

While it is shutting down, take a look at the node_exporter dashboard in Grafana. The dreaded **N/A** will rear it's ugly head soon.

Now, view the Alert in the Prometheus web UI again. It should show one firing alert in read. Expand the drop down menu to see the particular host that is down.

😁 This is how we do Prometheus. 😁

---

## (Optional Extra Credit) 

### Check the Rules File with promtool

Consider using the promtool to check the syntax of your rules file:

`promtool check rules /etc/prometheus/rules.yml`

### Install the Apache exporter

**Difficulty level: Advanced**

https://github.com/Lusitaniae/apache_exporter

https://grafana.com/grafana/dashboards/3894-apache/

This exporter and the corresponding dashboard will require some work on your part!

---
