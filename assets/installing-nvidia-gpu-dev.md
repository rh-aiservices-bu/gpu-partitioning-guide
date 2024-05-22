## Installing Nvidia GPU Operator from Staging / Development

* Define the namespace

```bash
NAMESPACE=nvidia-gpu-operator
```

* Delete the existing namespace

```bash
kubectl delete namespace ${NAMESPACE}
```

* Define the GPU operator bundle

```bash
BUNDLE=registry.gitlab.com/nvidia/kubernetes/gpu-operator/staging/gpu-operator-bundle:master-latest
```

* Create the namespace

```bash
oc create namespace ${NAMESPACE}
```

* Run the operator bundle with a timeout of 20 minutes

```bash
operator-sdk run bundle --timeout=20m -n ${NAMESPACE} --install-mode OwnNamespace ${BUNDLE}
```