
ClearBlade operator for deploying the ClearBlade platform to Kubernetes clusters.

### Overview

This operator is based on the Operator SDK (Ansible plugin):

https://sdk.operatorframework.io/docs/building-operators/ansible/

### Applying the ClearBlade CRD

#### Pre-requisites

Before deploying the ClearBlade CRD, you'll need to create a `Secret` in the
same namespace that you intend to run the platform in, the secret will contain
the platform key provided to you by ClearBlade, Inc.

You can easily create the required secret using the following command:

```
kubectl [-n <NAMESPACE>] create secret generic <SECRET-NAME> --from-literal=pkey=<PLATFORM-KEY>
```

Additionally, your cluster must be able to pull from `registry.redhat.io` if you
are gonna be using the default images.

#### Applying the CRD

Assuming the secret is already configured, you can deploy the ClearBlade platform using:

```
kubectl [-n <NAMESPACE>] apply -f <PATH-TO-MANIFEST-YAML>
```

Check the `config/samples` folder for sample CRD(s) you can apply in your cluster.

For more information regarding the CRD fields, you can run:

```
kubectl explain clearblade.spec
```

### Supported clusters

[k3s]: https://k3s.io/

[openshift]: https://www.openshift.com/

[olm]: https://github.com/operator-framework/operator-lifecycle-manager

Since the operator is not using any legacy or alpha features from the Kubernetes API,
it is expected to work in any standard Kubernetes distribution. As of the time of
writing, it was tested on:

- [K3s][k3s] v1.20.4-k3s1 with [OLM][olm] 0.17.0

- [OpenShift][openshift] 4.7.2

### FAQ

#### What is a good reference for the Kubernetes manifest files this operator has?

[kubernetes-in-action]: https://www.manning.com/books/kubernetes-in-action

Most if not all of the files in this operator were created with the help of
[Kubernetes in Action][kubernetes-in-action].

#### Building the operator image

Export the operator image URL:

```
export OPERATOR_IMG="[YOUR OPERATOR IMAGE URL HERE]"
```

The use the `make` target `docker-build`:


```
make docker-build IMG="$OPERATOR_IMG"
```

If you want to push the operator image you can run:

```
make docker-push IMG="$OPERATOR_IMG"
```

#### Building the bundle image

Export the bundle image URL:

```
export BUNDLE_IMG="[YOUR BUNDLE IMAGE URL HERE]"
```

Generate a "bundle" for your operator:

```
make bundle IMG="$OPERATOR_IMG"
```

Then build the actual bundle image using:

```
make bundle-build BUNDLE_IMG="$BUNDLE_IMG"
```

If you want to push the bundle image you can run:

```
make docker-push IMG="$BUNDLE_IMG"
```

#### Running locally (OLM)

Note: Make sure the operator as well as the bundle images are built and pushed into
a remote registry.

To run a local cluster, you can use the `local/k3drun.sh` script in this repository
to create a new k3s-based cluster.

First, modify `local/registries.yml` and add your credentials. Then run the cluster:

```
./local/k3drun.sh
```

Install OLM in your cluster:

```
operator-sdk olm install
```

Run your operator bundle:

```
operator-sdk run bundle "$BUNDLE_IMG"
```

Create a ClearBlade resource:

```
kubectl apply -f config/samples/platform_v1alpha1_clearblade.yaml
```

Confirm that the deployment works (make sure status looks OK):

```
kubectl describe clearblade clearblade-sample
```

Also with:

```
kubectl exec deployment/clearblade-sample-backend -- apk add --no-cache curl
kubectl exec deployment/clearblade-sample-backend -- curl -s clearblade-sample-backend/api/about
```

#### Running locally (non-OLM)

Run the cluster, just like we did in the *Running locally (OLM)* section.

Deploy the operator to the cluster using the `make` target `deploy`:

```
make deploy IMG="$OPERATOR_IMG"
```

The operator should be up and running.

#### Managing the version

The version is managed by the operator SDK when generating the bundle. Check
the `VERSION` param in the [Makefile](Makefile) for more info.

#### Running in an air-gap environment

The only external resources this operator depends on are the images. For an air-gap
environment, you just have to make the images available to the nodes either through
your own air-gapped registry or mirror.

Then you can specify the images from the CRD spec as follows:

```
...
spec:
    ...
    images
        database: NAME[:TAG|@DIGEST]
        backend: NAME[:TAG|@DIGEST]
        console: NAME[:TAG|@DIGEST]
    ...
```

#### Adding new parameter to the ClearBlade custom resource

The schema of our custom resource is defined at `config/crd/bases`.

#### Add new service, backend, etc

1. Create a new Ansible role under `roles`

2. Add the role to the playbook at `playbooks/clearblade.yml`
