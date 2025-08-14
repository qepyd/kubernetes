#!/bin/bash
#
# 定义变量
ScriptDir=$(dirname "$0")

# 快速编写secrets/jmsco-project-ceph-fs-in-jmscofs-user-key 对象的manifests
kubectl -n jmsco  create secret  generic jmsco-project-ceph-fs-in-jmscofs-user-key \
   --type=Opaque \
   --from-literal=userID=jmscofs \
   --from-file=userKey=$ScriptDir/ceph.client.jmscofs.secret  \
   --dry-run=client \
   -o yaml >$ScriptDir/secrets_jmsco-project-ceph-fs-in-jmscofs-user-key.yaml
