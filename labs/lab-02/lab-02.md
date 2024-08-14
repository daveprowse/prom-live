# ⚙️ Lab 02 - Web UI

In this lab we will:

- Access the Prometheus expression browser (web UI).
- Examine the Expression Browser components.
- Run some basic queries.

> Note: Remember that I will be working with Linux servers that are running Prometheus.

## Access the Prometheus Expression Browser (Web UI)

You can access the Web UI from the local machine or remotely.

- Locally: `http://localhost:9090` or `http://127.0.0.1:9090`
- Remotely: `http://<ip_address>:9090`

Because I usually run my servers without a GUI, I'll be accessing them from my main system via their IP addresses.

Consider using Chrome, Firefox, or Chromium to make the connection.

> Note: If you connect from a remote system, make sure that port 9090 is not firewalled or otherwise blocked.

## Examine the Expression Browser Components

Take a few minutes to explore the parts that make up the web UI.

- **Graph:** The home page is the "Graph" page. From here we can enter expressions and view the results.
- **Alerts:** This page shows any alerts and tripped thresholds that you have set. It will show these for all hosts that you are monitoring.
- **Status:** The Status menu allows you to see all of your targets (hosts) that you are scraping from as well as database status, your rules, and configuration.
- **Help:** The help option simply brings you to the Prometheus documentation. USE IT!

By default, Prometheus is designed to scrape metrics from itself. So you can use the local system to learn about Prometheus metrics.

## Run Basic Queries

Return back to the Graph page by clicking "Graph" or the Prometheus name and/or logo.

### Our First Expression

Now, in the query field let's run our first expression:

`up`

This is the most basic of queries. It is designed to simply scrape the server. If the server responds to the scrape, it shows as "1", meaning it was successful.

You will note that you have two ways of viewing the data: Table and Graph. Table enables you to view the information as columns and rows of text and numbers. Graph creates a basic line graph for you to view the data in a more visual manner. Depending on the type of query you run, one will work better than the other.

> Note: In older versions of the Web UI, "Table" was previously known as "Console".

> Extra: Try the expression `prometheus_build_info` just for fun and view in Table mode.

### Our Second Expression

Now, make sure that the "Enable autocomplete" checkbox is checked. This will give you autocomplete options based on what you type.

Try another expression:

`prometheus_http_requests_total`

As you type, the web UI should guess at what you need and should list the expression we want at the very top.

Press `enter` to accept its suggestion, or arrow to the suggestion that you want.

Press `enter` again to "Execute" the query. 

You should see a lot of results. In Table mode, scroll down to the handler named "/api/v1/query". That metric should show several results.
https://prometheus.io/docs/prometheus/latest/querying/basics/
Scroll down to the handler named "/graph". That should have several requests. It is the main web page that we are working at.

Now look at "/metrics" this should have many results. Those are all of the metrics that are being scraped right now.

Now view the same information in Graph mode. It will show a single number for the duration of the measurement. This combines all of the HTTP metrics listed in the table. Because this particular expression is considered to be a *counter* it is sometimes better to view the information in Table mode.

Finally, let's show this as a range vector query by adding a time frame:

`prometheus_http_requests_total[5m]`

> NOte: This does not work in Graph mode, but only in Table mode.

You should see less results than you did before because you are viewing data from a smaller range of time.

### Our Third Expression

Let's find out how much memory is being used by our server. Use the following expression:

`process_resident_memory_bytes`

View the result in "Table" mode and you will find the number of bytes that are currently being used by Prometheus.

However, this is not trackable or measurable over time. So click on the "Graph" tab for a better visualization.

You will note that the results are from a range of time including before you issued the query! That's because Prometheus, once running, is continually scraping based on the rules that you create (or in this case, the default Prometheus rules and configuration.) If you installed Prometheus using my script, it will have initiated metric scraping immediately when the installation completed.

> Note: If you are running a Linux system, consider comparing this to the amount of bytes shown for Prometheus in the `top` program. The "RES" memory should be very close to the Prometheus result. Press `M` to sort by the Memory column or filter for Prometheus by pressing `o` and then `COMMAND=PROM`.

---

**😁 FANTASTIC!! 😁**

---

## Extra Credit

To learn more about querying and expressions, see the official documentation:

https://prometheus.io/docs/prometheus/latest/querying/basics/