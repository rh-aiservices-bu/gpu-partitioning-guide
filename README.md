# GPU Sharing with Time Slicing, MPS, MIG and others

Repository to demo GPU Sharing with Time Slicing, MPS, MIG and others with [Red Hat OpenShift AI](https://www.redhat.com/en/technologies/cloud-computing/openshift/openshift-ai) and [NVIDIA GPU Operator](https://docs.nvidia.com/datacenter/cloud-native/openshift/latest/index.html).

Check also the [OpenShift GPU Sharing Methods Docs](https://developer.nvidia.com/blog/improving-gpu-utilization-in-kubernetes/) if you want to know more.

## 1. GPU Sharing Overview

![GPU Sharing Overview](assets/gpu-sharing-overview.png)

### 1.1. Time-Slicing
[Time-slicing](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-sharing.html) is a GPU resource management technique where GPU resources are divided into time intervals or "slices" and allocated sequentially to different users or processes. Key features include:

- **Sequential Allocation**: Each user or process gains access to the GPU for a specific duration known as a "time slice."
- **Resource Sharing**: After its time slice, the GPU is relinquished and allocated to the next user or process in the queue.
- **Fair Utilization**: This method ensures fair and efficient sharing of the GPU among multiple competing workloads.
- **Multiple Users**: Particularly useful in environments where many users compete for limited GPU resources.

If you want to know more check the [Time-Slicing in OpenShift docs](https://docs.nvidia.com/datacenter/cloud-native/openshift/latest/time-slicing-gpus-in-openshift.html).

### 1.2 Multi-Instance GPU (MIG)
[Multi-Instance GPU (MIG)](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/index.html) enables a single physical GPU to be partitioned into several isolated instances, each with its own compute resources, memory, and performance profiles. Key benefits include:

- **Predictable Performance**: Each instance has dedicated resources, offering predictable performance guarantees.
- **Workload Isolation**: Isolated instances provide secure workload isolation.
- **Dynamic Partitioning**: Administrators can dynamically adjust the number and size of MIG instances to adapt to changing workloads.
- **Optimized Resource Utilization**: Efficiently shares GPU resources among multiple users and workloads, maximizing utilization.
- **Scalability and Flexibility**: Adapts to the varying demands of applications and users.

> MIG is only supported with the following NVIDIA GPU Types - A30, A100, A100X, A800, AX800, H100, H200, and H800.

If you want to know more check the [MIG GPU Operator in OpenShift Docs](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-operator-mig.html).

### 1.3 Multi-Process Service (MPS)
[Multi-Process Service (MPS)](https://docs.nvidia.com/deploy/mps/index.html) facilitates concurrent sharing of a single GPU among multiple CUDA applications. This feature allows for:

- **Concurrent Execution**: Multiple CUDA contexts can share GPU resources simultaneously.
- **Optimized Utilization**: Efficiently manages GPU resources across different applications.
- **Seamless Context Switching**: Swiftly transitions between CUDA contexts to minimize overhead and maximize responsiveness.
- **Maximized Throughput**: Ensures efficient allocation of GPU resources even when multiple workloads run concurrently.

These advanced resource management techniques ensure that GPUs are fully utilized in multi-application environments, providing organizations with optimal performance, flexibility, and efficiency.

## 1.4 Pros and Cons of GPU Sharing Methods

| Strategy           | Benefits                                                                                                           | Cons                                                                                                               |
|--------------------|--------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------|
| Time-slicing       | - Allows multiple workloads to share a GPU by interleaving execution.                                              | - No isolation between workloads sharing the same GPU, leading to potential crashes affecting all workloads.       |
|                    | - Useful for small workloads that don’t require full GPU power simultaneously.                                     | - Less control over resource allocation, making it less suitable for production environments.                      |
|                    |                                                                                                                    | - Can lead to contention and suboptimal performance if workloads compete for GPU resources.                        |
|                    |                                                                                                                    | - Not recommended for most GPU sharing scenarios.                                                                 |
| Multi-Instance GPUs (MIG) | - Provides strict isolation between workloads by partitioning the GPU into smaller instances.                    | - Only supported on NVIDIA Ampere GPUs.                                                                            |
|                    | - Each instance behaves like a separate GPU with its own memory and compute resources.                             | - Less flexible than CUDA Multi-Process Service (MPS).                                                             |
|                    | - Ensures memory protection and error isolation.                                                                  | - Requires proper configuration and understanding of the underlying GPU architecture.                              |
|                    | - Suitable for workloads with varying resource requirements and need for isolation.                               | - Limited to specific GPU models (e.g., A100).                                                                     |
| CUDA Multi-Process Service (MPS) | - Enables fine-grained sharing of GPU resources among multiple pods by running CUDA kernels concurrently. | - Does not provide full memory protection and error isolation between processes.                                   |
|                    | - Feels similar to CPU and memory resource allocation in Kubernetes.                                               | - Sharing with MPS is not supported on devices with MIG enabled.                                                   |
|                    | - Supported on almost every CUDA-compatible GPU.                                                                  | - May not be suitable for workloads requiring strict isolation.                                                    |
|                    | - Suitable for efficiently sharing GPU resources without strict isolation requirements.                           | - Requires careful management to avoid resource contention and ensure optimal performance.                         |

## 2. Requirements

- [RHOAI Installed](https://access.redhat.com/documentation/en-us/red_hat_openshift_ai_self-managed)
- [Nvidia GPU Operator Installed](https://docs.nvidia.com/datacenter/cloud-native/openshift/23.9.2/install-gpu-ocp.html)
- [NFD Installed](https://docs.nvidia.com/datacenter/cloud-native/openshift/23.9.2/install-nfd.html#install-nfd)
- [GPU Nodes with GPUs](../bootstrap/gpu-machineset.sh)

## 3. Usage

This repository contains a set of components that can be used to enable GPU sharing with Time-Slicing, MPS, MIG and others. The components can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

### 3.1 [Time-Slicing](gpu-sharing-instance/instance/components/time-sliced/README.md)

* With 2 GPU replicas:

```yaml
kubectl apply -k gpu-sharing-instance/instance/overlays/time-sliced-2
```

* With 4 GPU replicas:

```yaml
kubectl apply -k gpu-sharing-instance/instance/overlays/time-sliced-2
```

### 3.2.1 [MIG-Single](gpu-sharing-instance/instance/components/mig-single/README.md)

> The single MIG strategy should be utilized when all GPUs on a node have MIG enabled

```yaml
kubectl apply -k gpu-sharing-instance/instance/overlays/mig-single
```

### 3.2.2 [MIG-Mixed](gpu-sharing-instance/instance/components/mig-mixed/README.md)

> The mixed MIG strategy should be utilized when **not** all GPUs on a node have MIG enabled

```yaml
kubectl apply -k gpu-sharing-instance/instance/overlays/mig-mixed
```

### 3.3 [MPS](gpu-sharing-instance/instance/components/mps/README.md)

> Combining MPS with MIG is **not currently supported** in the GPU operator.

* With 2 replicas:

```yaml
kubectl apply -k gpu-sharing-instance/instance/overlays/mps-2
```

* With 4 replicas:

```yaml
kubectl apply -k gpu-sharing-instance/instance/overlays/mps-4
```

NOTE: Despite the tests passing, *MPS isn't working correctly on OpenShift currently*, due to only one process per GPU can run at any time. RH and Nvidia engineers are working to fix this issue as soon as possible. 

### 3.4 NO GPU Sharing - Default

To disable the GPU sharing, you can use the default overlay:

```yaml
kubectl apply -k gpu-sharing-instance/instance/overlays/mps-2
```

## 4. Validate and Check GPU Sharing

### 4.1 Preparing the Environment

* Select the GPU product that you're interested in:

```md
* NVIDIA Tesla T4 [16GiB vRAM] (label: Tesla-T4-SHARED)
* NVIDIA A10G [24GiB vRAM] (label: NVIDIA-A10G-SHARED)
* NVIDIA L4 [24GiB vRAM] (label: NVIDIA-L4G-SHARED)
* NVIDIA A100 [40GiB vRAM] (label: NVIDIA-A100-SHARED)
* NVIDIA H100 [80GiB vRAM] (label: NVIDIA-H100-SHARED)
* INTEL DL1 [80GiB vRAM] (label: INTEL-DL1-SHARED)
```

* Check the GPU resources available:

> In this example I'm using the NVIDIA A10G GPU (g5.2xlarge), but you can change it to the GPU that you're interested in.

```md
GPU_LABEL="NVIDIA-A10G-SHARED"
kubectl get node --selector=nvidia.com/gpu.product=$GPU_LABEL -o json | jq '.items[0].status.capacity'
```

* Define the Worker NODE that you're interested in testing GPU Sharing:

```md
NODE=$(kubectl get nodes --selector=nvidia.com/gpu.product=$GPU_LABEL -o jsonpath='{.items[0].metadata.name}')
```

* Check the capacity of your Worker NODE with GPU without GPU Sharing enabled:

```md
kubectl get node $NODE -o json | jq '.status.capacity'
...
{
  "cpu": "8",
  "ephemeral-storage": "125238252Ki",
  "hugepages-1Gi": "0",
  "hugepages-2Mi": "0",
  "memory": "32506764Ki",
  **"nvidia.com/gpu": "1"**,
  "pods": "250"
}
```

> In this example, the Worker NODE has 1 GPU (A10G) available.

* Deploy the test deployment:

```md
kubectl create ns demo
kubectl apply -k gpu-sharing-tests/overlays/default/
```

* Deploy the test pod to check the pods running on the Worker NODE (and the rest pending):

```md
kubectl get pod -n demo
NAME                                  READY   STATUS    RESTARTS   AGE
nvidia-plugin-test-7d75856bc5-94b9n   0/1     Pending   0          59s
nvidia-plugin-test-7d75856bc5-shlwb   1/1     Running   0          59s
```

> The pod `nvidia-plugin-test-7d75856bc5-94b9n` is pending because the GPU Sharing is not enabled.

### 4.2 Apply the GPU Sharing Strategy and Check if it's working correctly

* Apply the GPU Sharing strategy that you're interested in (Time-Slicing, MIG-Single, MIG-Mixed, MPS or Default):

* Check that the GPU Sharing strategy was applied correctly, and all the pods in Nvidia GPU Operator Namespace are running:

```md
kubectl get pod -n nvidia-gpu-operator
```

> The gpu-feature-discovery and the nvidia-device-plugin-daemonset pods should be restarted with the new GPU Sharing configuration.

* Check the capacity of your Worker NODE with GPU Sharing enabled:

```md
kubectl get node $NODE -o json | jq '.status.capacity'
{
  "cpu": "8",
  "ephemeral-storage": "125238252Ki",
  "hugepages-1Gi": "0",
  "hugepages-2Mi": "0",
  "memory": "32506764Ki",
  **"nvidia.com/gpu": "2"**,
  "pods": "250"
}
```

Now you have 2 GPUs available on your Worker NODE with GPU Sharing enabled.

* Check the Metadata Labels to check the GPU Replicas and the GPU Sharing Strategy:

```md
kubectl get node $NODE -o json | jq '.metadata.labels' | grep gpu
  "node-role.kubernetes.io/gpu": "",
  "nvidia.com/gpu-driver-upgrade-state": "upgrade-done",
  "nvidia.com/gpu.compute.major": "8",
  "nvidia.com/gpu.compute.minor": "6",
  **"nvidia.com/gpu.count": "1"**,
  "nvidia.com/gpu.deploy.container-toolkit": "true",
  "nvidia.com/gpu.deploy.dcgm": "true",
  "nvidia.com/gpu.deploy.dcgm-exporter": "true",
  "nvidia.com/gpu.deploy.device-plugin": "true",
  "nvidia.com/gpu.deploy.driver": "true",
  "nvidia.com/gpu.deploy.gpu-feature-discovery": "true",
  "nvidia.com/gpu.deploy.node-status-exporter": "true",
  "nvidia.com/gpu.deploy.nvsm": "",
  "nvidia.com/gpu.deploy.operator-validator": "true",
  "nvidia.com/gpu.family": "ampere",
  "nvidia.com/gpu.machine": "g5.2xlarge",
  "nvidia.com/gpu.memory": "23028",
  "nvidia.com/gpu.present": "true",
  "nvidia.com/gpu.product": "NVIDIA-A10G-SHARED",
  **"nvidia.com/gpu.replicas": "2"**,
  **"nvidia.com/gpu.sharing-strategy": "time-slicing"**,
```

> For MPS and MIG will be different labels like in "gpu.sharing-strategy".



## Other Interesting Links

- [Docs - Nvidia GPU Operator on Openshift](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/openshift/contents.html)
- [Blog - Red Hat Nvidia GPUs on OpenShift](https://cloud.redhat.com/blog/autoscaling-nvidia-gpus-on-red-hat-openshift)
- [Blog - GPU Kubernetes Nvidia Device Plugin](https://superorbital.io/blog/gpu-kubernetes-nvidia-device-plugin/)
- [Docs - AWS Recommended GPU Instances](https://docs.aws.amazon.com/dlami/latest/devguide/gpu.html)
- [Docs - AWS GPU Instances](https://aws.amazon.com/ec2/instance-types/#Accelerated_Computing)
- [Video - Optimizing GPU Utilization: Understanding MIG and MPS](https://www.nvidia.com/en-us/on-demand/session/gtcspring22-s41793/)