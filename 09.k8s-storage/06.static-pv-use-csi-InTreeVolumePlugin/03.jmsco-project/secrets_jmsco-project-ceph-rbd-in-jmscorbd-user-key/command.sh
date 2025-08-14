#!/bin/bash
#
# 定义变量
ScriptDir=$(dirname "$0")

# 快速编写secrets/jmsco-project-ceph-rbd-in-jmscorbd-user-key 对象的manifests
kubectl -n jmsco  create secret  generic jmsco-project-ceph-rbd-in-jmscorbd-user-key \
   --type=Opaque \
   --from-literal=userID=jmscorbd \
   --from-file=userKey=$ScriptDir/ceph.client.jmscorbd.secret  \
   --dry-run=client \
   -o yaml >$ScriptDir/secrets_jmsco-project-ceph-rbd-in-jmscorbd-user-key.yaml

