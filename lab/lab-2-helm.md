# Lab - Kubernetes deployments with HELM

Back to [Main page](../README.md)

In this lab, we will install the [HELM](https://github.com/helm/helm) client locally and deploy [Wordpress](https://wordpress.org/) from an existing HELM chart using a custom repository.

## Install HELM

Helm has an installer script that will automatically grab the latest version of Helm and install it locally.

```sh
[centos@node-0 ~]$ curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

For more information on `How to install HELM` check [https://helm.sh/docs/intro/install/](https://helm.sh/docs/intro/install/).

## Explore existing HELM charts on the HELM hub

Navigate in your Browser to [https://hub.helm.sh/](https://hub.helm.sh/).

The Helm Hub provides a search over distributed public Helm repositories. Repositories are hosted by many people and organizations.

Search for `wordpress`. You should see results from different repositories/providers. We will pick `bitnami` for our lab. Click on `bitnami/wordpress` and read through the documentation.

The Helm Hub also provides instruction, how to use the provided charts. So first we have to add the `bitnami` repo to our local Helm installation.

## Add a new HELM repo

In order to use the charts provided by bitnami we have to install the repo:

```sh
[centos@node-0 ~]$ helm repo add bitnami https://charts.bitnami.com
```

Afterwards we can use an existing chart and install Wordpress.

## Install wordpress and expose it via NodePort

Now, install the chart using the helm client. We also want to use another service type: `NodePort`. Therefore we have to overwrite the default value of the property `service.type`. This can be done with the `--set KEY=VALUE` flag:

```sh
[centos@node-0 ~]$ helm install mywordpress bitnami/wordpress --version 8.0.1 --set service.type=NodePort
```

Now you should see some new workloads in your cluster and wordpress should be accessible via the node port.
