# ⚙️ Lab 04 - node_exporter

The node_exporter can export machine metrics from remote systems into the Prometheus dashboard. This allows you to view the basic system status of remote computers within your infrastructure.

In this lab we will:

- Install node_exporter to our virtual machines.
- Modify the prometheus.yml configuration file.
- Run the node_exporter manually.
- Query the remote system from the Prometheus web UI.
- Query the remote system from Grafana.

## Install node_exporter to our Virtual Machines

Access the remote system(s) you wish to monitor.

Install the node_exporter using the script in this lab's directory:

`sudo ./node-exporter-install.sh`

> Note: Be sure to set the script permissions to execute and run it with sudo or as root.

The script installs the node_exporter and runs it as a service. Test it with the following command:

`systemctl status node_exporter`

Install the node_exporter to whatever other systems you wish. You can even install it to the main Prometheus system if you don't have any other virtual machines to work with.

> Note: Systems with the node_exporter listen on port 9100 by default.

> Note: To install from package manager:
>
>   `sudo apt install prometheus-node-exporter`

> Note: To install manually, see the following links:
> - https://prometheus.io/download/
> - https://github.com/prometheus/node_exporter 
> - If you need to install to a macOS system, you will need the "Darwin"-based node-exporter binary.

## Modify the Configuration File

Now, let's modify the prometheus.yml file on the Prometheus server so that we can track the remote system. By default, it can be found at:

`/etc/prometheus/prometheus.yml`

> Note: If you installed manually, the configuration file will be in whatever directory you extracted to.

- Open it (with sudo or as root) and take a minute to read through the configuration.

  We could add the remote host to the current "static_configs:" area but instead we'll create a new job.

- Add the following to the end of the configuration file.

```yaml
  - job_name: "remote-systems"
    static_configs:
      - targets: 
        - "<ip_address_of_remote_host>:9100"
```

> Note: Replace `<ip_address_of_remote_host>` with the actual IP address of the system to be monitored (or hostname). For example:
> `10.42.88.2`

- Save and quit out of the file.
- Restart the prometheus service:

  `sudo systemctl restart prometheus`

  If you encounter an error, then double-check your configuration file for YAML syntax issues. You can also check for issues with: `journalctl -u prometheus`.

- Check to make sure it is working:

  `curl http://<ip_address_of_remote_host>:9100`

> Note: If you installed the node_exporter manually, then you will need to find the directory that you decompressed the file to and run it with `sudo ./node_exporter`.

## Run the node_exporter Manually

From the remote system:

- Stop the service:

  `sudo systemctl stop node_exporter`

  Write down the time that you stopped the service.

- Run the exporter:

  `node_exporter`

  It should show that the node_exporter is listening on port 9100.

- Press `Ctrl + C` when done to stop the process. Write down the current time.
- Start the node_exporter service back up:

  `sudo systemctl start node_exporter`

## Query the Remote System from the Prometheus web UI

- Go to your main Prometheus monitoring system's browser tab.
- Make sure that you have the "Enable Autocomplete" checkbox checked. (It can save you a lot of time!)
- Start typing "prom" and look at the various types of metrics that can be used in the PromUI.
- Start a new query on the remote system. For example:

  `up{instance="10.42.88.2:9100",job="remote-systems"}`

  > Note: Replace the IP address with the IP address of your remote system.

- View the results. You should see two dips in the line graph. These should coincide with the time that you stopped the node_exporter service and the time when you stopped the process later on.
- Run another query:

  `process_cpu_seconds_total{instance="<ip_address_of_remote_system>",job="remote-systems"}`

> Note: You probably noticed the web UI offering autocomplete suggestions for the instance and the job. Just press `enter` to accept these.

## Query the Remote System from Grafana

Go to your main Grafana browser tab and access the dashboard you created in a previous lab. You should have a panel up and running.

- Create a new query:  
  - Click the "Add" button.
  - Select "Visualization".
  - In the query section, click "+ Add query".
  - This time, code the query by clicking the "Code" button. Add the following gauge:
    `process_resident_memory_bytes{instance="<ip_address>:9100",job="remote-systems"}`
    > Note: Use auto-completion as much as possible.
- Run the query.
- Change the visualization by clicking the "Time series" dropdown menu and selecting "Gauge". (When you have an extra minute, take a look at the different measurement types you can select from.)
- Apply (or Save) the Dashboard.
- View your results.

This will create a new panel (graph) where you can view the results.

> Note: If you wanted the results to show up in the same panel then select click the panel's menu icon (three dots on the upper-right) and select "Edit".

In this case, Prometheus is scraping the metric for the amount of memory used by the remote system's node_exporter.

Save the results to the dashboard by clicking the disk icon.

---

**❣️ LOVE IT ❣️**

---

## Extra Credit

Check out the node_exporter man page:

`man prometheus-node-exporter`

Learn more about panels and visualizations:

https://grafana.com/docs/grafana/latest/panels-visualizations/

**Keyboard Shortcuts**

Grafana has a number of keyboard shortcuts available. Press ? on your keyboard to display all keyboard shortcuts available in your version of Grafana.

    Ctrl+S: Saves the current dashboard.
    f: Opens the dashboard finder / search.
    d+k: Toggle kiosk mode (hides the menu).
    d+e: Expand all rows.
    d+s: Dashboard settings.
    Ctrl+K: Opens the command palette.
    Esc: Exits panel when in fullscreen view or edit mode. Also returns you to the dashboard from dashboard settings.

Focused panel

By hovering over a panel with the mouse you can use some shortcuts that will target that panel.

    e: Toggle panel edit view
    v: Toggle panel fullscreen view
    ps: Open Panel Share Modal
    pd: Duplicate Panel
    pr: Remove Panel
    pl: Toggle panel legend