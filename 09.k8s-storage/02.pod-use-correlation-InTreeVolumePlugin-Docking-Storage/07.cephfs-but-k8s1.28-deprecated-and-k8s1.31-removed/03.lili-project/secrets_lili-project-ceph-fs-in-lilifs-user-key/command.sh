# 定义变量
ScriptDir=$(dirname "$0")

# 快速编写secrets资源对象的manifests
kubectl -n lili  create secret  generic  lili-project-ceph-fs-in-lilifs-user-key \
   --type=Opaque       \
   --from-file=key=$ScriptDir/ceph.client.lilifs.secret \
   --dry-run=client \
   -o yaml >$ScriptDir/secrets_lili-project-ceph-fs-in-lilifs-user-key.yaml
