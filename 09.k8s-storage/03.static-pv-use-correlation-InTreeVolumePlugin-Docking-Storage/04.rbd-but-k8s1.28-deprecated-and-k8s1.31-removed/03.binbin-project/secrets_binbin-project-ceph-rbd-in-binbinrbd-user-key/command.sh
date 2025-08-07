#!/bin/bash
#
# 定义变量
ScriptDir=$(dirname "$0")

# 快速编写secrets资源对象的manifests
kubectl -n binbin   create secret  generic  binbin-project-ceph-rbd-in-binbinrbd-user-key \
   --type=Opaque \
   --from-file=key=$ScriptDir/ceph.client.binbinrbd.secret \
   --dry-run=client \
   -o yaml >$ScriptDir/secrets_binbin-project-ceph-rbd-in-binbinrbd-user-key.yaml 

