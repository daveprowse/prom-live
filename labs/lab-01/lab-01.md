# ⚙️ Lab 01 - Prometheus Installation

There are a variety of ways to install Prometheus. For example, you can do a basic installation from source, from package manager, install to Docker, or use my provided script.

**For this webinar I recommend using the Bash script.** However, if you are uncomfortable executing other people's scripts, or have any issues with it, install via package manager.

## Scripted Installation

The included `prometheus-install` script is designed for Ubuntu 22.04/24.04 Server and Debian 12 Server (amd64 and arm64 platforms) and has been tested on both.

> IMPORTANT! This script is designed to install newer versions of Prometheus. However, the version installed may not be an LTS version, and it may have compatibility issues with some Linux distros and with some Prometheus add-ons and graphing utilities.

Simply run the script as `root` or with `sudo`.

> Note: Make sure that it is set to executable. `chmod +x prometheus-install.sh`

Here's what the script will do:

- Install Prometheus
- Configure and run Prometheus as a service

Once finished, Prometheus will run automatically and should be accessible from `http://127.0.0.1:9090` (via curl or with a web browser).

> Note: It should also be accessible from remote systems. If you have a firewall installed on the Prometheus system, you will need to make sure that port 9090 is open.

**Verify the installation:** Check the version of Prometheus, verify that the service is running, run a test `curl`, and make sure that you can access the man page.

- Version: `prometheus --version`
- Service: `systemctl status prometheus`
- Transfer a URL: `curl http://127.0.0.1:9090`. It should show "Found".
- Man page: `man prometheus`

If you can see the version and man page and the service is active and enabled then you are golden!

👍 **GREAT WORK!** 👍

> **IMPORTANT!**: At this point, our Prometheus server is scraping data (against itself for now) and will continue to do so until you stop the service or shut down the server.

> Note: If you need to install to a hardware platform other than AMD64 or ARM64, you will need to install the binary manually from https://prometheus.io/download/.

> Note: If you wish to install a newer version of Prometheus, find out the version number and simply change the PROM and PROMVERSION variables to the new version.

---

At any time, if you want to work with Prometheus manually, do the following:

1. Disable the Prometheus service: `sudo systemctl stop prometheus`
2. Run the prometheus command, for example: `prometheus --config.file=/etc/prometheus/prometheus.yml`  
3. Have fun!

---

> Note for CentOS 9 users: This script should work with CentOS Stream 9 but you may need to satisfy SELinux requirements. After you execute the script, if the service fails, run the following command:
>
> `chcon -t bin_t '/usr/bin/prometheus'`
>
> and then restart the service: `sudo systemctl restart prometheus`.
>
> Test it with `curl http://127.0.0.1:9090`
>
> Note: Make sure that cockpit.socket is disabled! (It uses the same port.) `sudo systemctl --now disable cockpit.service`

## Package Manager Installation

Installing via package manager is easy and has been well tested. Ubuntu Server or Debian (as a server) are recommended.

- Ubuntu Server: `apt install prometheus`
- Debian Server: `apt install prometheus openipmi-`

> Note: `openipmi` causes system degradation in Debian, so we are omitting it here.

Keep in mind that you are not getting the latest version of Prometheus with the package manager installation - far from it. However, it will be a stable version that you can rely on.

Once it is installed check the version of Prometheus, verify that the service is running, test against a URL, and make sure that you can access the man page.

- Version: `prometheus --version`
- Service: `systemctl status prometheus`
- URL test: `curl http://127.0.0.1:9090`
- Man page: `man prometheus`

If you can see the version and man page and the service is active and enabled then you are golden!

> Note: CentOS is not recommended. It requires repo setup: https://github.com/lest/prometheus-rpm or my script, or install from source.

## Docker Installation

Here is a ready-to-go Prometheus installation in a docker container:

`docker run --name prometheus -d -p 127.0.0.1:9090:9090 prom/prometheus`

> More info about Prometheus in Docker: https://prometheus.io/docs/prometheus/latest/installation/

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

> Note: There may be dependency issues if you install this way on an Ubuntu or Debian server. The previous script is recommended as it sets up your system in a way where you can get right to work with Prometheus.

> Note: To build from source, see the Prometheus repository: https://github.com/prometheus/prometheus

## Windows and macOS

I do not have a script for Windows or macOS but you can download Prometheus for those OSes from https://prometheus.io/download/.

- Unzip (or untar) the file.
- Access the newly created directory.
- Issue the following command to run Prometheus:

  `./prometheus`

  That should run the server and you can access it from `http://127.0.0.1:9090` or `http://localhost:9090`.

- To stop the server press `Ctrl + C`.

The configuration file (prometheus.yml) is located within the same directory as the Prometheus executable.

> Note: This is an easy way to run and learn about Prometheus but will not be feasible in a real-world situation. In the field you will want to run it in a Linux server or in a Docker container.

### Homebrew and Chocolatey

You could also install Prometheus to macOS and run it as a service using Homebrew:

- `brew install prometheus`
- `brew services start prometheus`

The configuration file would be stored in: 

`/opt/homebrew/etc/prometheus.yml`

I don't recommend the Chocolatey install of Prometheus for Windows. As of the writing of this document Chocolatey carries a much older version.

---
