# GPU Sharing with Time Slicing, MPS, MIG and others

Repository to demo GPU Sharing with Time Slicing, MPS, MIG and others with [Red Hat OpenShift AI](https://www.redhat.com/en/technologies/cloud-computing/openshift/openshift-ai) and [NVIDIA GPU Operator](https://docs.nvidia.com/datacenter/cloud-native/openshift/latest/index.html).

## GPU Sharing Overview

### 1. Time-Slicing
[Time-slicing](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-sharing.html) is a GPU resource management technique where GPU resources are divided into time intervals or "slices" and allocated sequentially to different users or processes. Key features include:

- **Sequential Allocation**: Each user or process gains access to the GPU for a specific duration known as a "time slice."
- **Resource Sharing**: After its time slice, the GPU is relinquished and allocated to the next user or process in the queue.
- **Fair Utilization**: This method ensures fair and efficient sharing of the GPU among multiple competing workloads.
- **Multiple Users**: Particularly useful in environments where many users compete for limited GPU resources.

If you want to know more check the [Time-Slicing in OpenShift](https://docs.nvidia.com/datacenter/cloud-native/openshift/latest/time-slicing-gpus-in-openshift.html)

### 2. Multi-Instance GPU (MIG)
[Multi-Instance GPU (MIG)](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/index.html) enables a single physical GPU to be partitioned into several isolated instances, each with its own compute resources, memory, and performance profiles. Key benefits include:

- **Predictable Performance**: Each instance has dedicated resources, offering predictable performance guarantees.
- **Workload Isolation**: Isolated instances provide secure workload isolation.
- **Dynamic Partitioning**: Administrators can dynamically adjust the number and size of MIG instances to adapt to changing workloads.
- **Optimized Resource Utilization**: Efficiently shares GPU resources among multiple users and workloads, maximizing utilization.
- **Scalability and Flexibility**: Adapts to the varying demands of applications and users.

If you want to know more check the [MIG GPU Operator in OpenShift](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-operator-mig.html)

### 3. Multi-Process Service (MPS)
[Multi-Process Service (MPS)](https://docs.nvidia.com/deploy/mps/index.html) facilitates concurrent sharing of a single GPU among multiple CUDA applications. This feature allows for:

- **Concurrent Execution**: Multiple CUDA contexts can share GPU resources simultaneously.
- **Optimized Utilization**: Efficiently manages GPU resources across different applications.
- **Seamless Context Switching**: Swiftly transitions between CUDA contexts to minimize overhead and maximize responsiveness.
- **Maximized Throughput**: Ensures efficient allocation of GPU resources even when multiple workloads run concurrently.

These advanced resource management techniques ensure that GPUs are fully utilized in multi-application environments, providing organizations with optimal performance, flexibility, and efficiency.
