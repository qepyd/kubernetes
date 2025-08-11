#!/bin/bash
#
# 定义变量
ScriptDir=$(dirname "$0")

# 快速编写secrets资源对象的manifests
kubectl -n kube-system   create secret  generic  ceph-cluster-admin \
   --type="kubernetes.io/rbd" \
   --from-file=key=$ScriptDir/ceph.client.admin.secret \
   --dry-run=client \
   -o yaml >$ScriptDir/secrets_ceph-cluster-admin.yaml 

