## 其 -n wyc 是指wyc名称空间
kubectl create secret  generic  wyc-project-ceph-rbd-in-wycrbd-user-key \
   --type=Opaque \
   --from-file=key=./ceph.client.wycrbd.secret \
   -n wyc \
   --dry-run=client \
   -o yaml >./secrets_wyc-project-ceph-rbd-in-wycrbd-user-key.yaml 

