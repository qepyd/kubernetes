#!/bin/bash
#
# 定义变量
ScriptDir=$(dirname "$0")

# 快速编写secrets/jmsco-project-ceph-fs-in-jmscofs-user-key 对象的manifests
# 参考: https://github.com/ceph/ceph-csi/blob/v3.14.2/examples/cephfs/secret.yaml
kubectl -n jmsco  create secret  generic jmsco-project-ceph-fs-in-jmscofs-user-key \
   --type=Opaque \
   --from-literal=userID=jmscofs \
   --from-file=userKey=$ScriptDir/ceph.client.jmscofs.secret  \
   --dry-run=client \
   -o yaml >$ScriptDir/secrets_jmsco-project-ceph-fs-in-jmscofs-user-key.yaml

   #--from-literal=adminID=jmscofs \
   #--from-file=adminKey=$ScriptDir/ceph.client.jmscofs.secret  \
   #
   # 静态和动态pv所需要的
   # userID：不能包含"client."前缀
   # userKey：即ceph中client.jmscofs的secret
   #

