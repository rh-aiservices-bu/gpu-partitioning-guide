# GPU Sharing with Time Slicing, MPS, MIG and others

Repository to demo GPU Sharing with Time Slicing, MPS, MIG and others with [Red Hat OpenShift AI](https://www.redhat.com/en/technologies/cloud-computing/openshift/openshift-ai) and [NVIDIA GPU Operator](https://docs.nvidia.com/datacenter/cloud-native/openshift/latest/index.html).

Check also the [OpenShift GPU Sharing Methods Docs](https://developer.nvidia.com/blog/improving-gpu-utilization-in-kubernetes/) if you want to know more.

## GPU Sharing Overview

![GPU Sharing Overview](assets/gpu-sharing-overview.png)

### 1. Time-Slicing
[Time-slicing](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-sharing.html) is a GPU resource management technique where GPU resources are divided into time intervals or "slices" and allocated sequentially to different users or processes. Key features include:

- **Sequential Allocation**: Each user or process gains access to the GPU for a specific duration known as a "time slice."
- **Resource Sharing**: After its time slice, the GPU is relinquished and allocated to the next user or process in the queue.
- **Fair Utilization**: This method ensures fair and efficient sharing of the GPU among multiple competing workloads.
- **Multiple Users**: Particularly useful in environments where many users compete for limited GPU resources.

If you want to know more check the [Time-Slicing in OpenShift docs](https://docs.nvidia.com/datacenter/cloud-native/openshift/latest/time-slicing-gpus-in-openshift.html).

### 2. Multi-Instance GPU (MIG)
[Multi-Instance GPU (MIG)](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/index.html) enables a single physical GPU to be partitioned into several isolated instances, each with its own compute resources, memory, and performance profiles. Key benefits include:

- **Predictable Performance**: Each instance has dedicated resources, offering predictable performance guarantees.
- **Workload Isolation**: Isolated instances provide secure workload isolation.
- **Dynamic Partitioning**: Administrators can dynamically adjust the number and size of MIG instances to adapt to changing workloads.
- **Optimized Resource Utilization**: Efficiently shares GPU resources among multiple users and workloads, maximizing utilization.
- **Scalability and Flexibility**: Adapts to the varying demands of applications and users.

> MIG is only supported with the following NVIDIA GPU Types - A30, A100, A100X, A800, AX800, H100, H200, and H800.

If you want to know more check the [MIG GPU Operator in OpenShift Docs](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-operator-mig.html).

### 3. Multi-Process Service (MPS)
[Multi-Process Service (MPS)](https://docs.nvidia.com/deploy/mps/index.html) facilitates concurrent sharing of a single GPU among multiple CUDA applications. This feature allows for:

- **Concurrent Execution**: Multiple CUDA contexts can share GPU resources simultaneously.
- **Optimized Utilization**: Efficiently manages GPU resources across different applications.
- **Seamless Context Switching**: Swiftly transitions between CUDA contexts to minimize overhead and maximize responsiveness.
- **Maximized Throughput**: Ensures efficient allocation of GPU resources even when multiple workloads run concurrently.

These advanced resource management techniques ensure that GPUs are fully utilized in multi-application environments, providing organizations with optimal performance, flexibility, and efficiency.

## Pros and Cons of GPU Sharing Methods

# Benefits vs Cons of NVIDIA GPU Sharing Strategies

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

## Usage

This repository contains a set of components that can be used to enable GPU sharing with Time-Slicing, MPS, MIG and others. The components can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

### [Time-Slicing](gpu-instance-gitops/instance/components/time-sliced/README.md)

* With 2 GPU replicas:

```yaml
kubectl apply -k overlays/time-sliced-2
```

* With 4 GPU replicas:

```yaml
kubectl apply -k overlays/time-sliced-2
```

### [MIG-Single](gpu-instance-gitops/instance/components/mig-single/README.md)

> The single MIG strategy should be utilized when all GPUs on a node have MIG enabled

```yaml
kubectl apply -k overlays/mig-single
```

### [MIG-Mixed](gpu-instance-gitops/instance/components/mig-mixed/README.md)

> The mixed MIG strategy should be utilized when **not** all GPUs on a node have MIG enabled

```yaml
kubectl apply -k overlays/mig-mixed
```

### [MPS](gpu-instance-gitops/instance/components/mps/README.md)

* With 2 replicas:

```yaml
kubectl apply -k overlays/mps-2
```

* With 4 replicas:

```yaml
kubectl apply -k overlays/mps-4
```

## Other Interesting Links

- [Docs - AWS GPU Instances](https://aws.amazon.com/ec2/instance-types/#Accelerated_Computing)
- [Docs - Nvidia GPU Operator on Openshift](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/openshift/contents.html)
- [Blog - Red Hat Nvidia GPUs on OpenShift](https://cloud.redhat.com/blog/autoscaling-nvidia-gpus-on-red-hat-openshift)