# Lab - Kubernetes deployments with HELM

Back to [Main page](../README.md)

## Install HELM

Helm has an installer script that will automatically grab the latest version of Helm and install it locally.

```sh
[centos@node-0 ~]$ curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

For more information chech [https://helm.sh/docs/intro/install/](https://helm.sh/docs/intro/install/).

## Add a new HELM repo

```sh
[centos@node-0 ~]$ helm repo add bitnami https://charts.bitnami.com
```

## Install wordpress and expose it via NodePort

```sh
[centos@node-0 ~]$ helm install mywordpress bitnami/wordpress --version 8.0.1 --set service.type=NodePort
```
