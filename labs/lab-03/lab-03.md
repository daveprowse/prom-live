# ⚙️ Lab 03 - Dashboarding

In this lab we will:

- Install the Grafana Dashboard to our Prometheus server.
- Show some basic functionality of the dashboard.

## Install the Grafana Dashboard

There are scripts available to automate the install:

- Ubuntu/Debian: grafana-install-ubuntu.sh
- CentOS: grafana-install-centos.sh

These will set up the repository, install Grafana, and run it as a service.

> Note: Set the script to executable and run as sudo

When finished, you should see the version of Grafana listed on the screen.

Check that the service is running:

`systemctl status grafana-server.service`

Access the server:

- Locally: `http://localhost:3000`
- Remotely: `http://<ip_address>:3000`

> Note: Make sure that port 3000 is open!

---

> Other installation options: You can also install manually, and to a variety of platforms by accessing the links below:
> https://grafana.com/grafana/download/
> https://grafana.com/docs/grafana/latest/setup-grafana/installation/ 

> For macOS and Windows: there are [Homebrew](https://formulae.brew.sh/formula/grafana) and [Chocolatey](https://community.chocolatey.org/packages/grafana) options for Grafana.
> With Homebrew you can also run Grafana as a service: `brew services start grafana`.

---

## Grafana Basic Functionality

In this section we will:

- Connect to the Grafana server and login.
- Configure a data source.
- Create a dashboard.
- Add basic queries.
- Save our Dashboard.

### Connect to the Grafana Server and Login

- Connect to the Grafana server in the web browser.

  `http://localhost:3000`

  or

  `http://<ip_address>"3000`

- Login with the username/password: admin/admin
- Change the password to something more secure. (Make a note of your new password.)
  
### Configure a Data Source

Before we can create a dashboard we have to set up a data source. The data source will be Prometheus. During this process, Grafana will query the Prometheus API.

- In the main left-hand menu, go to **Connections > Data sources**.
- Click the button "+ Add new data source".
- Select Prometheus.
- In Settings, under Connection, enter the URL to your Prometheus server. 
  - If it is local use `http://localhost:9090`
  - If it is a remote server, use `http://<ip_address>:9090`
- Scroll down and click "Save & test". This should be successful. If not, check your URL carefully.

> Notice the many security options that you can implement with the Grafana server. In the field - USE THEM!

### Create a Dashboard

Now, let's create a basic dashboard!

1. Click Dashboards in the left hand menu. (Click the three-horizontal-line menu button if it isn't there.)
2. Click "+ Create Dashboard"
3. Click "+ Add visualization"
4. Select your new Prometheus data source./
  
Boom! Done. You should now see the new dashboard. (Possibly with a single metric called "A series".)

### Add Basic Queries

Examine the "Query" section of the dashboard below the graphing area.

Add the following in the Metrics browser field:

- `up`
- `process_resident_memory_bytes`
- `process_cpu_seconds_total`

> Note: To create additional queries and expressions click the "+ Add query" button.

When you are finished, scroll up and click "Run queries".

This should display the results to the three queries in a line graph. It should show all data since the Prometheus server was running.

### Save our Dashboard

On the upper-right, click "Save".

Name your new dashboard: *Linux-Dash1* and click "Save".

That will save the dashboard for future use. It also removes the right-hand side menu and query area so that you can view your dashboard better. Click and drag the dashboard window to resize it.

> Note: You can also hide the left-hand menu by undocking it. Click the dock/undock icon next to "Home".

---

**😁 YEAH BABY! 😁**

---

## Extra Credit

Click on the time range drop down menu and explore the options available to you.

To learn more about Dashboards, see the official documentation:

https://grafana.com/docs/grafana/latest/dashboards/