# Lab - Kubernetes basics & deployment strategies

Back to [Main page](../README.md)

In this lab, we will deploy a small application consists of 2 services(frontend & backend) to Kubernetes and explore the deployment concepts of **blue/green deployments** and **canary releases**.

## Build backend

Navigate to your user home directory or whereever you want to store the source code of the backend serivce.
Now checkout the sample repository on your `node-0` via:

```sh
[centos@node-0 ~]$ cd
[centos@node-0 ~]$ git clone --branch v1.0.0 https://github.com/hulk0301/example-app-backend.git
[centos@node-0 ~]$ cd example-app-backend
[centos@node-0 example-app-backend]$
```

Then build the docker image using the provided Dockerfile.
Use `backend:v1.0.0` as tag for your image and push it to DockerHub(you should have already an account, if not create one).

> Note: If you clone the repo to another folder, you might have to adapt some paths when running the provided commands!

## Deploy the backend to Kubernetes

### Create a new namespace

We want to run our app in an isolated environment, therefore create a new namespace called `demoapp`:

```sh
[centos@node-0 ~]$ kubectl create namespace demoapp
```

### Deployment manifest

Create a deployment manifest(`backend_deployment_v1.yaml`) and apply it on the Kubernetes cluster using `kubectl`. Don't forget to specify some meaningful labels:

- `app=backend`
- `version=v1`

Create the deployment in the newly created namespace `demoapp` by adding the namespace as metadata in your manifest YAML file and apply it on the cluster:

```sh
[centos@node-0 example-app-backend]$ kubectl apply -f backend_deployment_v1.yaml
```

If you need more information about how to create a kubernetes deployment manifest, check the docs [here](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#creating-a-deployment). The deployment should run the **backend** docker image in version `v1.0.0`.

## Expose the backend internally

As we want to access the backend pods from our frontend we have to expose it cluster-internally.
Which Kubernetes resource is used to expose a deployment on the cluster?
And how can we make it only internally available? Is there a special type for the resource we are looking for?
Use both labels(`app`, `version`) for the pod selection.

## Build frontend

Navigate to your user home directory or whereever you want to store the source code of the frontend serivce.
Now checkout the sample repository on your `node-0` via:

```sh
[centos@node-0 ~]$ cd
[centos@node-0 ~]$ git clone --branch v1.0.0 https://github.com/hulk0301/example-app-frontend.git
[centos@node-0 ~]$ cd example-app-frontend
[centos@node-0 example-app-frontend]$
```

Then build the docker image using the provided Dockerfile.
Use `frontend:v1.0.0` as tag for your image and push it to DockerHub(you should have already an account, if not create one).

## Deploy the frontend to Kubernetes

Create a deployment manifest(`frontend_deployment_v1.yaml`) and apply it on the Kubernetes cluster using `kubectl`. Don't forget to specify some meaningful labels:

- `app=frontend`
- `version=v1`

Create the deployment also in the namespace `demoapp` (The namespace was created in the `Deploy the backend to Kubernetes` section):

```sh
[centos@node-0 example-app-frontend]$ kubectl apply -f deployment_v1.yaml
```

If you need more information about how to create a kubernetes deployment manifest, check the docs [here](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#creating-a-deployment). The deployment should run the **frontend** docker image in version `v1.0.0`.

Don't forget to set the environment variable `API_URL` to a valid URL(`http://<MY_BACKEND_HOST>:<MY_BACKEND_PORT>`).
How can you configure the environment for your deployment? Check out the docs about environment variables for containers [here](https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/#define-an-environment-variable-for-a-container).

## Expose the frontend service to the public internet

Now we want to expose our frontend to the world, so that everyone can use our application. Therefore we have to make the frontend publicly available. How can we do this? What options do we have and what is the easiest way to do this?

Checkout the docs/intro about Kubernetes services [here](https://kubernetes.io/docs/tutorials/kubernetes-basics/expose/expose-intro/).
Which type can we use?

Choose an appropriate type, create a new manifest `frontend_service.yaml` and expose so the deployment on the cluster. Don't forget to put the resource into the correct namespace and use both labels(`app`, `version`) for the pod selection.

```sh
[centos@node-0 example-app-frontend]$ kubectl apply -f frontend_service.yaml
```

Afterwards open the frontend in your browser and check if the frontend shows the backend version `v1.0.0`. If not check the `API_URL`. Maybe there is something wrong with the settings.

## Blue/Green deployment - Frontend

### Build frontend v2.0.0

We encountered that our users don't like the background color `blue`. Therefore we want to change it to `green`. The source code is already available:

```sh
[centos@node-0 ~]$ cd
[centos@node-0 ~]$ cd example-app-frontend
[centos@node-0 example-app-frontend]$ git checkout v2.0.0
Previous HEAD position was fc0df8a fix warning
HEAD is now at dc65f9b Change background color to green
[centos@node-0 example-app-frontend]$
```

Now just build a new version of the frontend `v2.0.0` with the provided Dockerfile and push the image to DockerHub.

### Deploy frontend v2.0.0

Now create another YAML file `frontend_deployment_v2.yaml` for the new version and deploy it to the cluster. Don't forget to adapt the labels and the name. We don't want to perform an update on the existing deployment.

```sh
[centos@node-0 example-app-frontend]$ kubectl apply -f frontend_deployment_v2.yaml
```

You should see now 3 deployments(`backend-v1`, `frontend-v1`, `frontend-v2`):

```sh
[centos@node-0 example-app-frontend]$ kubectl get deployments --namespace demoapp
[centos@node-0 example-app-frontend]$
```

TODO insert sample output (!)

### Release new version

Access the frontend again in your browser. Has the background color changed to green?

No, we first have to switch the service to the new version. Therfore update the `frontend_service.yaml` of the frontend and target only the pods with version `v2.0.0`.
Apply the manifest:

```sh
[centos@node-0 example-app-frontend]$ kubectl apply -f frontend_service.yaml
```

Now reload the page in your browser. The background color should have changed from blue to green and our customers are now happy.

## Canary releases

Our development team has built a new feature, but we just want to test the new feature with half of our users. Therefore we want to run both version(the stable v1.0.0 and the new version) in parallel.

### Build new backend - v2.0.0

First we have to build the new version and push it to our docker registry at DockerHub.

```sh
[centos@node-0 ~]$ cd
[centos@node-0 ~]$ cd example-app-backend
[centos@node-0 example-app-backend]$ git checkout v2.0.0
Previous HEAD position was a16d5f4 Update go.yml
HEAD is now at 0ca7ba1 Return version 2.0.0
[centos@node-0 example-app-backend]$
```

Now build a new version of the backend `v2.0.0` with the provided Dockerfile. And push the image to DockerHub.

### Deploy new backend to the cluster

So now create another YAML file `backend_deployment_v2.yaml` for the new version and deploy it to the cluster. Don't forget to adapt the labels and the name. We don't want to perform an update on the existing deployment.

```sh
[centos@node-0 example-app-backend]$ kubectl apply -f backend_deployment_v2.yaml
```

You should see now 4 deployments(`backend-v1`, `backend-v1`, `frontend-v1`, `frontend-v2`):

```sh
[centos@node-0 example-app-backend]$ kubectl get deployments --namespace demoapp
[centos@node-0 example-app-backend]$
```

TODO insert sample output (!)

### Canary release for the new version

Access the frontend in your browser and reload it a few times. Is it always showing backend version `1.0.0` or sometimes `2.0.0`?

If you already face a toggling version, the service is configured correctly. Check which part of the configuration makes it possible to sometimes get routed to the old version and sometimes to the new.

If you still have version `1.0.0`, you have to update your service manifest `backend_service.yaml` of the backend(Maybe your service manifest file for the backend has a different name as it was not specified expliciltly). Is there a configuration parameter which just points to a specific version? If yes, how can you change it to target both version?

Apply the manifest and check if you are getting now both versions displayed at your frontend:

```sh
[centos@node-0 example-app-backend]$ kubectl apply -f backend_service.yaml
```

We have now partially released a new feature for some customers.

## Optional: Use config maps to separate the deployment environment definition from the deployment manifest

Move the `API_URL` from the deployment manifest of the frontend to a config map and reference to the config map within your deployment manifest.

## Cleanup

To easily cleanup the created resources delete the whole namespace:

```sh
[centos@node-0 ~]$ kubectl delete namespace demoapp
```
