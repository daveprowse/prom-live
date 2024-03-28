# ⚙️ Lab 01 - Prometheus Installation ⚙️

There are a variety of ways to install Prometheus. For example, you can do a basic installation from source, from package manager, install to Docker, or use my provided script. 

**For this webinar I recommend using the Ubuntu or Debian package manager.** 

> Note: For newer versions and the ability to customize, check out my script.

## Package Manager Installation

For simplicity, this is the recommended option. Ubuntu Server or Debian (as a server) are recommended.

- Ubuntu Server: `apt install prometheus`
- Debian Server: `apt install prometheus openipmi-`

> Note: `openipmi` causes system degradation in Debian, so we are omitting it here.

Keep in mind that you are not getting the latest version of Prometheus with the package manager installation - far from it. However, it will be a stable version that you can rely on.

Once it is installed check the version of Prometheus, verify that the service is running, and make sure that you can access the man page.

- Version: `prometheus --version`
- Service: `systemctl status prometheus`
- Man page: `man prometheus`

If you can see the version and man page and the service is active and enabled then you are golden!

👍 **GREAT WORK!** 👍

> Note: CentOS is not recommended. It requires repo setup: https://github.com/lest/prometheus-rpm or my script, or install from source.

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

> Note: There may be dependency issues if you install this way. The following script is recommended as it sets up your system in a way where you can get right to work with Prometheus.

## Scripted Installation

The included `prometheus-install` script is designed for Ubuntu 22.04 Server and Debian 12 Server (x64 platform) and has been tested on both.

> IMPORTANT! This script is designed to install newer versions of Prometheus. However, the version installed may not be an LTS version, and it may have compatibility issues with some Linux distros and with some Prometheus add-ons and graphing utilities.

Simply run the script as `root` or with `sudo`.

> Note: Make sure that it is set to executable. `chmod +x prometheus-install.sh`

Here's what the script will do:

- Install Go
- Install NodeJS
- Install Prometheus
- Configure and run Prometheus as a service

Once finished, Prometheus will run automatically and should be accessible from `http://127.0.0.1:9090`.

> Note: It should also be accessible from remote systems. If you have a firewall installed on the Prometheus system, you will need to make sure that port 9090 is open.

> Note: If you wish to install a newer version of Prometheus, find out the version number and simply change the PROM variable to the new version. Example:
> `PROM=prometheus-2.50.1.linux-amd64`

---

At any time, if you want to work with Prometheus manually, do the following:

1. Disable the Prometheus service: `sudo systemctl stop prometheus`
2. Access the following directory: `/usr/local/bin/prometheus`
3. Run Prometheus with the `sudo ./prometheus` command.
4. Have fun!

---

> Note: This script works with CentOS Stream 9 but you will need to satisfy SELinux requirements. After you execute the script, run the following command from Prometheus' parent directory `/usr/local/bin`:
>
> `chcon -t bin_t 'prometheus/prometheus'`
>
> and then restart the service: `sudo systemctl restart prometheus`.
>
> Test it with `curl http://127.0.0.1:9090`
>
> Note: Make sure that cockpit.socket is disabled! (It uses the same port.)

---
