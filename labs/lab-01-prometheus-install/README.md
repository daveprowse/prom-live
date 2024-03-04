# Prometheus Installation

There are a variety of ways to install Prometheus. You can do a basic installation from source, install to Docker, or use my provided script. For this webinar I recommend using the script. It does a lot of the work for you!

## Scripted Installation

The included `prometheus-install.sh` script is designed for Ubuntu 22.04 Server and Debian 12 Server (x64 platform) and has been tested on both.

Simply run the script as `root` or with `sudo`. (Make sure that it is set to executable.)

Here's what the script will do:

- Install Go
- Install NodeJS
- Install Prometheus
- Configure and run Prometheus as a service

Once finished, Prometheus will run automatically and should be accessible from `http://127.0.0.1:9090`.

---

At any time, if you want to work with Prometheus manually, do the following:

1. Disable the Prometheus service: `sudo systemctl --now disable prometheus`
2. Access the following directory: `/usr/local/bin/prometheus`
3. Run Prometheus with the `sudo ./prometheus` command.
4. Have fun!

👍 **GREAT WORK!!** 👍

---

> Note: This script works with CentOS Stream 9 but you will need to satisfy SELinux requirements. After you execute the script, run the following command from Prometheus' parent directory:
>
> `chcon -t bin_t 'prometheus/prometheus'`
>
> and then restart the service: `sudo systemctl restart prometheus`.

---

## Docker Installation

Here is a ready-to-go Prometheus installation in a docker container:

`docker run --name prometheus -d -p 127.0.0.1:9090:9090 prom/prometheus`

> Note: If you don't have Docker installed, here is the procedure for Debian: https://docs.docker.com/engine/install/debian/.

## Manual Installation

For a basic installation of Prometheus, do the following:

- Download Prometheus: https://prometheus.io/download/
- Run the following commands:
  
  ```console
  tar xvfz prometheus-*.tar.gz
  cd prometheus-*
  /prometheus --help
  ```

> Note: There may be dependency issues if you install this way. The previously recommended script is recommended for this webinar as it sets up your system in a way where you can get right to work with Prometheus.

---
