#!/bin/bash
#
# 定义变量
ScriptDir=$(dirname "$0")

# 快速编写secrets资源对象的manifests
kubectl -n lanlan   create secret  generic  lanlan-project-ceph-rbd-in-lanlanrbd-user-key \
   --type="kubernetes.io/rbd" \
   --from-file=key=$ScriptDir/ceph.client.lanlanrbd.secret \
   --dry-run=client \
   -o yaml >$ScriptDir/secrets_lanlan-project-ceph-rbd-in-lanlanrbd-user-key.yaml 

