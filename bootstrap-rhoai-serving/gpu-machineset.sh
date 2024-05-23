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
#!/bin/bash

### Define Instance Types
declare -A INSTANCE_TYPES
INSTANCE_TYPES=(
  ["Tesla T4 Single GPU"]="g4dn.2xlarge"
  ["Tesla T4 Multi GPU"]="g4dn.12xlarge"
  ["A10G Single GPU"]="g5.2xlarge"
  ["A10G Multi GPU"]="g5.48xlarge"
  ["A100"]="p4d.24xlarge"
  ["H100"]="p5.48xlarge"
  ["DL1"]="dl1.24xlarge"
  ["L4 Single GPU"]="g6.2xlarge"
  ["L4 Multi GPU"]="g6.12xlarge"
)

### Prompt User for GPU Instance Type
echo "### Select the GPU instance type:"
PS3='Please enter your choice: '
options=(
  "Tesla T4 Single GPU"
  "Tesla T4 Multi GPU"
  "A10G Single GPU"
  "A10G Multi GPU"
  "A100"
  "H100"
  "DL1"
  "L4 Single GPU"
  "L4 Multi GPU"
)
select opt in "${options[@]}"
do
  case $opt in
    "Tesla T4 Single GPU"|"Tesla T4 Multi GPU"|"A10G Single GPU"|"A10G Multi GPU"|"A100"|"H100"|"DL1"|"L4 Single GPU"|"L4 Multi GPU")
      INSTANCE_TYPE=${INSTANCE_TYPES["$opt"]}
      break
      ;;
    *) echo "--- Invalid option $REPLY ---";;
  esac
done

### Prompt User for Region
read -p "### Enter the AWS region (default: us-west-2): " REGION
REGION=${REGION:-us-west-2}

### Prompt User for Availability Zone
echo "### Select the availability zone (az1, az2, az3):"
PS3='Please enter your choice: '
az_options=("az1" "az2" "az3")
select az_opt in "${az_options[@]}"
do
  case $az_opt in
    "az1")
      AZ="${REGION}a"
      break
      ;;
    "az2")
      AZ="${REGION}b"
      break
      ;;
    "az3")
      AZ="${REGION}c"
      break
      ;;
    *) echo "--- Invalid option $REPLY ---";;
  esac
done

# Assign new name for the machineset
NEW_NAME="worker-gpu-$INSTANCE_TYPE-$AZ"

# Check if the machineset already exists
EXISTING_MACHINESET=$(oc get -n openshift-machine-api machinesets -o name | grep "$NEW_NAME")

if [ -n "$EXISTING_MACHINESET" ]; then
  echo "### Machineset $NEW_NAME already exists. Scaling to 1."
  oc scale --replicas=1 -n openshift-machine-api "$EXISTING_MACHINESET"
  echo "--- Machineset $NEW_NAME scaled to 1."
else
  echo "### Creating new machineset $NEW_NAME."
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
  echo "--- New machineset $NEW_NAME created."
fi
