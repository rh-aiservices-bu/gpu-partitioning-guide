#!/bin/bash

### Instance
## NVIDIA Tesla T4 [16GiB vRAM] (label: Tesla-T4-SHARED)
# https://aws.amazon.com/ec2/instance-types/g4
# single gpu: g4dn.{2,4,8,16}xlarge
# multi gpu:  g4dn.12xlarge
# practical:  g4ad.4xlarge

## NVIDIA A10G [24GiB vRAM] (label: NVIDIA-A10G-SHARED)
# https://aws.amazon.com/ec2/instance-types/g5/
# single gpu: g5.{2,4,8,16}xlarge
# multi gpu:  g5.12xlarge (4x A10G)
# multi gpu:  g5.48xlarge	 (8x A10G)

## NVIDIA L4 [24GiB vRAM] (label: NVIDIA-L4G-SHARED)
# https://aws.amazon.com/ec2/instance-types/g5/
# single gpu: g6.{2,4,8,16}xlarge
# multi gpu:  g6.12xlarge (4x A10G)
# multi gpu:  g6.48xlarge	 (8x A10G)

## NVIDIA A100 [40GiB vRAM] (label: NVIDIA-A100-SHARED)
# https://aws.amazon.com/ec2/instance-types/p4/
# A100 (MIG): p4d.24xlarge

## NVIDIA H100 [80GiB vRAM] (label: NVIDIA-H100-SHARED)
# https://aws.amazon.com/ec2/instance-types/p5/
# H100 (MIG): p5.48xlarge

## INTEL DL1 [80GiB vRAM] (Intel Habana Gaudi)
# https://aws.amazon.com/ec2/instance-types/dl1
# 8 x gaudi:  dl1.24xlarge

INSTANCE_TYPE="g5.48xlarge"
AZ="us-west-2a"
NEW_NAME="worker-gpu-$INSTANCE_TYPE-$AZ"

## Create GPU Machineset with the new name and updated instance type
oc get -n openshift-machine-api machinesets -o name | grep -v ocs | while read -r MACHINESET
do
  oc get -n openshift-machine-api "$MACHINESET" -o json | jq '
      del( .metadata.uid, .metadata.managedFields, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .status) |
      (.metadata.name, .spec.selector.matchLabels["machine.openshift.io/cluster-api-machineset"], .spec.template.metadata.labels["machine.openshift.io/cluster-api-machineset"]) |= sub("worker";"workerocs") |
      (.spec.template.spec.providerSpec.value.instanceType) |= "'"$INSTANCE_TYPE"'" |
      (.metadata.name) |= "'"$NEW_NAME"'" |
      (.spec.template.metadata.labels["machine.openshift.io/cluster-api-machineset"]) |= "'"$NEW_NAME"'" |
      (.spec.selector.matchLabels["machine.openshift.io/cluster-api-machineset"]) |= "'"$NEW_NAME"'" |
      (.spec.template.spec.metadata.labels["node-role.kubernetes.io/gpu"]) |= "" |
      (.spec.template.spec.metadata.labels["cluster.ocs.openshift.io/openshift-storage"]) |= "" |
      (.spec.template.spec.taints) |= [{ "effect": "NoSchedule", "key": "nvidia.com/gpu" }]' | oc create -f -
  break
done
