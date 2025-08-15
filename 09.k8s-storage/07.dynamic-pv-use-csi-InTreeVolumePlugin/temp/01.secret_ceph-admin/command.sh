#!/bin/bash
#
# 定义变量
ScriptDir=$(dirname "$0")

# 快速编写secrets/ceph-admin对象的manifests
kubectl -n ceph-csi  create secret  generic ceph-admin \
   --type=Opaque \
   --from-literal=userID=admin \
   --from-file=userKey=$ScriptDir/ceph.client.admin.secret  \
   --dry-run=client \
   -o yaml >$ScriptDir/secrets_ceph-admin.yaml

   #
   # 静态和动态pv所需要的
   # userID：不能包含"client."前缀，我这儿用的是ceph集群其超级用户
   # userKey：即ceph中client.admin的secret
   #

