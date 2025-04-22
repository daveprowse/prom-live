# MicroK8s Notes

MicroK8s can be a very simple, efficient, and powerful way to run a Kubernetes cluster. It installs as a snap.

If you want to install MicroK8s, see the following link:
https://microk8s.io/#install-microk8s

If you want to add nodes to the cluster see this link:
https://microk8s.io/docs/clustering

I recommend making aliases to Kubernetes commands, for example making an alias from `microk8s` to `kubectl`:

`sudo snap alias microk8s.kubectl kubectl`

Also, you will want to give your user account permissions to MicroK8s so you don't have to constantly type sudo:

`sudo usermod -aG microk8s <user_account>`

> Note: If Kubernetes (or Helm) doesn't recognize your command (or gives TCP 127.0.0.1 errors) then make sure you preface the command with `microk8s`.
