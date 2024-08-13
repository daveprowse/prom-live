# ⚙️ Lab 05 - Instrumenting Code

Instrumentation is the ability to monitor and measure the level of a product’s performance. Let's show an example of instrumentation for a basic web server written in Python.

> Note: This lab assumes an Ubuntu Server or Debian Server. `tmux` or a similar terminal multiplexer is recommended.

In this lab we will:

- Install the Python client library for Prometheus.
- Examine, (modify), and copy the supplied Python script.
- Add the web server to the Prometheus configuration.
- Run the Python script.
- Scrape metrics!

## Install the Python Client Library

We'll be installing the Python client library for Prometheus to the system that is to be monitored.

Typical installations of the Python client library use pip. To find out if you have pip installed, run the following command:

`pip --version`

If it is not installed, install it with the following command:

`sudo apt install pip -y`

> Note: Make sure that your system is updated before installing pip.

To install the Python client library use the following command:

`pip install prometheus_client`

Once installed, it should work with your Python code.

> Note: On Debian server you will need to either: create a virtual environment for Python; or (for speed) use the `--break-system-packages` option to install it with `pip`.

## Examine and Copy the Python Script

Take a minute to examine the `web-server.py` script. If executed, it will run a basic webserver that can be monitored by Prometheus. The key portion of the script is:

`from prometheus_client import start_http_server`

If you have the Prometheus Python client library installed, this will be interpreted properly and metrics can be scraped by the Prometheus server. Metrics are delivered on port 8000 as shown in this line of the script:

`start_http_server(8000)`

Depending on your environment, you might want to modify the script:

- If you are working with a single system, then leave the script as is.
- If you have multiple systems, and want to view the system to be monitored from another system, then edit `'localhost'` to the IP address of the system - for example: `'10.42.88.2'`.

Copy the script to the remote system that you want to monitor.

## Add the Web Server to the Configuration

On the monitoring system go to the Prometheus configuration file:

`/etc/prometheus/prometheus.yml`

Add the host with a new job:

```yaml
  - job_name: webserver
    static_configs:
    - targets:
      - localhost:8000
```

> Note: If monitoring a remote system, replace `localhost` with the IP address of your system. Going forward, I won't note this anymore but instead will use `<ip_address>` as the placeholder. (You can opt to use double quotes `""` or not.)

> Note: Be careful with the syntax, it must be exact. For example, `static_configs:` has an underscore between the words. If something like this is omitted, the configuration will break, and the prometheus service will fail.

Save the file and restart the Prometheus service.

`sudo systemctl restart prometheus`

> Note: Did we have to create a new job? No, but I'm trying to get you practice working with the prometheus.yml file.

## Run the Python Script

> Note: You might want to use a terminal multiplexer such as tmux or screen at this point so that you can have multiple terminals open.

At the remote system, execute the python script:

`python3 web-server.py`

This runs the web server and it should be accessible.

> Note: The process doesn't fork, so you will need to open another terminal to work with the system further. That is why a terminal multiplexer was recommended previously.

Check the web page that is being served locally:

- `curl http://localhost:8001`

> Note: type the actual IP address instead of `localhost` if you modified it in the Python script.

## Scrape Metrics!

Now we'll check the metrics, first with curl, and then at the Prometheus web UI.

### With curl

Use the curl command on port 8000. For example:

- Locally: `curl http://localhost:8000`
- Remotely: `curl http://<ip_address>:8000`

This should display the metrics that are to be collected for scraping.

### With the Web UI

Access your main Prometheus monitoring system's web UI.

Run the following query and examine the results:

`up{job="webserver",instance="<ip_address>"}`

This may take a moment to get a result but you should see a "1" as the result.

Now try this query:

`python_info{job="webserver",instance="<ip_address>:8000"}`

This should show the version of Python that your system is running. For example:

`python_info{implementation="CPython", instance="10.42.88.2:8000", job="webserver", major="3", minor="10", patchlevel="12", version="3.10.12"}`

There you go! Some very basic scraping of data, but you get the idea. This webinar is not about custom instrumentation, but I wanted to show a basic example.

---

🐲 **GREAT WORK!** 🐲

---

## Extra Credit

Try accessing additional metrics based on the ones that are listed when you run a:

`curl http://<ip_address>:8000`

For example:

- python_gc_collections_total
- process_open_fds
