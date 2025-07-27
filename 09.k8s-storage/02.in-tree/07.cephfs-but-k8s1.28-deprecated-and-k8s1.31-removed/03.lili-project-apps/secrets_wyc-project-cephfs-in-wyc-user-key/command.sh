kubectl -n lili create secret  generic  lili-project-cephfs-in-lilifs-user-key \
   --type=Opaque \
   --from-file=key=./ceph.client.lilifs.secret \
   --dry-run=client \
   -o yaml >./secrets_lili-project-cephfs-in-lilifs-user-key.yaml

