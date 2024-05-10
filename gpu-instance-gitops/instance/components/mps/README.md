# MPS

## Purpose

This component is designed to enable Multi-Process Service (MPS) on GPUs.

To learn more about the MPS GPUs, please refer to the official [docs](
https://docs.nvidia.com/deploy/mps/index.html) and to the [GPU Sharing blog post in Kubernetes](https://developer.nvidia.com/blog/improving-gpu-utilization-in-kubernetes/)

## Usage

This component can be added to a base by adding the `components` section to your overlay `kustomization.yaml` file:

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

components:
  - ../../components/time-sliced
```

This component is intended to be used with additional configurations to set the number of replicas.

Please refer to [mps-2](../mps-2) and [mps-4](../mps-4) for complete implementations of the time slicing configuration.
