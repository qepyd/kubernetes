#!/bin/bash
#
# 定义变量
ScriptDir=$(dirname "$0")

# 快速编写secrets资源对象的manifests
kubectl -n lili  create secret  generic  lili-project-ceph-rbd-in-lilirbd-user-key \
   --type=Opaque \
   --from-file=key=$ScriptDir/ceph.client.lilirbd.secret \
   --dry-run=client \
   -o yaml >./secrets_lili-project-ceph-rbd-in-lilirbd-user-key.yaml 

