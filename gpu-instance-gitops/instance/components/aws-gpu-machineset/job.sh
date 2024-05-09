#!/usr/bin/env bash
# shellcheck disable=SC1091

. /scripts/ocp.sh

ocp_aws_cluster || exit 0
ocp_aws_create_gpu_machineset
ocp_create_machineset_autoscale
