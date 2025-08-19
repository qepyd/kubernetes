# 1 存储系统ceph中做准备
```
参考 ./01.storage-admin/
```

# 2 k8s管理员做相关准备
```
参考 ./02.k8s-admin/
```

# 3 binbin项目其app31应用
相关文件
```
root@master01:~# tree 03.binbin-project/app31/
03.binbin-project/app31/
├── 01.pv_binbin-prod-app31-data.yaml
├── 02.pvc_app31-data.yaml
└── 03.deploy_app31.yaml

0 directories, 3 files
```

相关注意
```
需要将 ./01.storage-admin/ 阶段其binbinfs用户的secret放置到k8s的worker node上其/etc/ceph/目录下。
```

创建pv/binbin-prod-app31-data对象
```
root@master01:~# kubectl apply -f 03.binbin-project/app31/01.pv_binbin-prod-app31-data.yaml --dry-run=client
persistentvolume/binbin-prod-app31-data created (dry run)
root@master01:~# 
root@master01:~# kubectl apply -f 03.binbin-project/app31/01.pv_binbin-prod-app31-data.yaml
persistentvolume/binbin-prod-app31-data created
root@master01:~# 
root@master01:~# kubectl get pv/binbin-prod-app31-data
NAME                     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS                    REASON   AGE
binbin-prod-app31-data   10Gi       RWX            Delete           Available           binbin-project-prod-static-pv            26s
```

创建pvc/app31-data对象
```
root@master01:~# kubectl apply -f 03.binbin-project/app31/02.pvc_app31-data.yaml --dry-run=client
persistentvolumeclaim/app31-data created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.binbin-project/app31/02.pvc_app31-data.yaml
persistentvolumeclaim/app31-data created
root@master01:~#
root@master01:~# kubectl -n binbin get pvc/app31-data
NAME         STATUS   VOLUME                   CAPACITY   ACCESS MODES   STORAGECLASS                    AGE
app31-data   Bound    binbin-prod-app31-data   10Gi       RWX            binbin-project-prod-static-pv   22s
```

创建deploy/app31对象
```
root@master01:~# kubectl apply -f 03.binbin-project/app31/03.deploy_app31.yaml --dry-run=client
deployment.apps/app31 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.binbin-project/app31/03.deploy_app31.yaml
deployment.apps/app31 created
root@master01:~#
root@master01:~# kubectl -n binbin get deploy/app31
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
app31   2/2     2            2           23s
root@master01:~#
root@master01:~# kubectl -n binbin get pods -o wide | grep $(kubectl -n binbin describe deploy/app31 | grep "NewReplicaSet:" | cut -d " " -f 4)
app31-696c6c44bd-lk5ft   2/2     Running   0          80s   10.0.3.26   node01   <none>           <none>
app31-696c6c44bd-nwlwd   2/2     Running   0          80s   10.0.4.29   node02   <none>           <none>
```

以worker node之node01上的pod/app31-696c6c44bd-lk5ft为例查看其挂载信息
```
## 查看pod/app31-696c6c44bd-lk5ft对象的uid
root@master01:~# kubectl -n binbin get pods/app31-696c6c44bd-lk5ft -o json | jq ".metadata.uid"
"006f8e8f-89f5-468b-b647-72ed5389db16"

## 到worker node之node01上面查看挂载信息
root@node01:~# df -h | grep 006f8e8f-89f5-468b-b647-72ed5389db16
tmpfs                                                                                                           7.7G   12K  7.7G   1% /var/lib/kubelet/pods/006f8e8f-89f5-468b-b647-72ed5389db16/volumes/kubernetes.io~projected/kube-api-access-5nbm5
172.31.8.201:6789,172.31.8.202:6789,172.31.8.203:6789:/volumes/app31/data/157116e2-83b8-430b-a167-af886ec00e1a  474G     0  474G   0% /var/lib/kubelet/pods/006f8e8f-89f5-468b-b647-72ed5389db16/volumes/kubernetes.io~cephfs/binbin-prod-app31-data
```

会实现，多个Pod副本间的数据共享、各Pod副本中容器的数据共享
```
## worker node之node01上其pods/app31-696c6c44bd-lk5ft对象中相关容器读写数据
# <-- app31主容器
root@master01:~# kubectl -n binbin exec -it pods/app31-696c6c44bd-lk5ft -c app31 -- ls -ld /data/
drwxr-xr-x    2 root     root             0 Aug 19 07:04 /data/
root@master01:~# 
root@master01:~# kubectl -n binbin exec -it pods/app31-696c6c44bd-lk5ft -c app31 -- ls -l /data/
total 0
root@master01:~# 
root@master01:~# kubectl -n binbin exec -it pods/app31-696c6c44bd-lk5ft -c app31 -- touch /data/app31-container.txt
root@master01:~# 
root@master01:~# kubectl -n binbin exec -it pods/app31-696c6c44bd-lk5ft -c app31 -- ls -l /data/
total 0
-rw-r--r--    1 root     root             0 Aug 19 07:25 app31-container.txt

# <-- sidecar主容器
root@master01:~# kubectl -n binbin exec -it pods/app31-696c6c44bd-lk5ft -c sidecar -- ls -l /data/
total 0
-rw-r--r--    1 root     root             0 Aug 19 07:25 app31-container.txt
root@master01:~# 
root@master01:~# kubectl -n binbin exec -it pods/app31-696c6c44bd-lk5ft -c sidecar -- touch /data/sidecar-container.txt
root@master01:~# 
root@master01:~# kubectl -n binbin exec -it pods/app31-696c6c44bd-lk5ft -c sidecar -- ls -l /data/
total 0
-rw-r--r--    1 root     root             0 Aug 19 07:25 app31-container.txt
-rw-r--r--    1 root     root             0 Aug 19 07:26 sidecar-container.txt

## worker node之node02上其pods/app31-696c6c44bd-nwlwd对象中相关容器读写数据
# <-- app31、sidecar主容器读
root@master01:~# kubectl -n binbin exec -it pods/app31-696c6c44bd-nwlwd  -c app31  -- ls -l /data/
total 0
-rw-r--r--    1 root     root             0 Aug 19 07:25 app31-container.txt
-rw-r--r--    1 root     root             0 Aug 19 07:26 sidecar-container.txt
root@master01:~# 
root@master01:~# kubectl -n binbin exec -it pods/app31-696c6c44bd-nwlwd  -c sidecar  -- ls -l /data/
total 0
-rw-r--r--    1 root     root             0 Aug 19 07:25 app31-container.txt
-rw-r--r--    1 root     root             0 Aug 19 07:26 sidecar-container.txt

# <-- app31、sidecar主容器写
root@master01:~# kubectl -n binbin exec -it pods/app31-696c6c44bd-nwlwd  -c app31  -- touch /data/a.txt
root@master01:~# 
root@master01:~# kubectl -n binbin exec -it pods/app31-696c6c44bd-nwlwd  -c sidecar  -- touch /data/b.txt
root@master01:~# 
root@master01:~# kubectl -n binbin exec -it pods/app31-696c6c44bd-nwlwd  -c app31  -- ls -l /data/
total 0
-rw-r--r--    1 root     root             0 Aug 19 07:30 a.txt
-rw-r--r--    1 root     root             0 Aug 19 07:25 app31-container.txt
-rw-r--r--    1 root     root             0 Aug 19 07:30 b.txt
-rw-r--r--    1 root     root             0 Aug 19 07:26 sidecar-container.txt
root@master01:~# 
root@master01:~# kubectl -n binbin exec -it pods/app31-696c6c44bd-nwlwd  -c sidecar  -- ls -l /data/
total 0
-rw-r--r--    1 root     root             0 Aug 19 07:30 a.txt
-rw-r--r--    1 root     root             0 Aug 19 07:25 app31-container.txt
-rw-r--r--    1 root     root             0 Aug 19 07:30 b.txt
-rw-r--r--    1 root     root             0 Aug 19 07:26 sidecar-container.txt
```

依次删除deploy/app31、pvc/app31-data、pv/binbin-prod-app31-data对象
```
## 删除deploy/app31
root@master01:~# kubectl -n binbin get deploy/app31
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
app31   2/2     2            2           15m
root@master01:~#
root@master01:~# kubectl -n binbin delete deploy/app31
deployment.apps "app31" deleted

## 删除pvc/app31-data
root@master01:~# kubectl -n binbin get pvc/app31-data
NAME         STATUS   VOLUME                   CAPACITY   ACCESS MODES   STORAGECLASS                    AGE
app31-data   Bound    binbin-prod-app31-data   10Gi       RWX            binbin-project-prod-static-pv   17m
root@master01:~# 
root@master01:~# kubectl -n binbin delete pvc/app31-data
persistentvolumeclaim "app31-data" deleted

## 查看pv/binbin-prod-app31-data对象是否还在,是在的
#  使用cephfs卷类型的静态pv，其回收策略Delete是不起作用的
root@master01:~# kubectl get pv/binbin-prod-app31-data
NAME                     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS                    REASON   AGE
binbin-prod-app31-data   10Gi       RWX            Delete           Failed   binbin/app31-data   binbin-project-prod-static-pv            22m

## 删除pv/binbin-prod-app31-data对象
root@master01:~# kubectl delete pv/binbin-prod-app31-data
persistentvolume "binbin-prod-app31-data" deleted
```

重建pv/binbin-prod-app31-data、pvc/app31-data、deploy/app31对象，以某个Pod副本查看之前的数据是否还在，数据是在的
```
## 重建
root@master01:~# kubectl apply -f 03.binbin-project/app31/
persistentvolume/binbin-prod-app31-data created
persistentvolumeclaim/app31-data created
deployment.apps/app31 created

## 列出相关资源对象
root@master01:~# kubectl get -f 03.binbin-project/app31/
NAME                                      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS                    REASON   AGE
persistentvolume/binbin-prod-app31-data   10Gi       RWX            Delete           Bound    binbin/app31-data   binbin-project-prod-static-pv            30s

NAME                               STATUS   VOLUME                   CAPACITY   ACCESS MODES   STORAGECLASS                    AGE
persistentvolumeclaim/app31-data   Bound    binbin-prod-app31-data   10Gi       RWX            binbin-project-prod-static-pv   30s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/app31   2/2     2            2           30s

## 列出相关Pod资源对象
root@master01:~# kubectl -n binbin get pods -o wide | grep $(kubectl -n binbin describe deploy/app31 | grep "NewReplicaSet:" | cut -d " " -f 4)
app31-696c6c44bd-b9vpr   2/2     Running   0          68s   10.0.4.30   node02   <none>           <none>
app31-696c6c44bd-r7vmg   2/2     Running   0          68s   10.0.3.27   node01   <none>           <none>

## 到某Pod副本中某容器查看之前的数据是否还在，结果是在的
root@master01:~# kubectl -n binbin exec -it pods/app31-696c6c44bd-r7vmg -c app31 -- ls -l /data/
total 0
-rw-r--r--    1 root     root             0 Aug 19 07:30 a.txt
-rw-r--r--    1 root     root             0 Aug 19 07:25 app31-container.txt
-rw-r--r--    1 root     root             0 Aug 19 07:30 b.txt
-rw-r--r--    1 root     root             0 Aug 19 07:26 sidecar-container.txt
root@master01:~# 
root@master01:~# kubectl -n binbin exec -it pods/app31-696c6c44bd-r7vmg -c sidecar -- ls -l /data/
total 0
-rw-r--r--    1 root     root             0 Aug 19 07:30 a.txt
-rw-r--r--    1 root     root             0 Aug 19 07:25 app31-container.txt
-rw-r--r--    1 root     root             0 Aug 19 07:30 b.txt
-rw-r--r--    1 root     root             0 Aug 19 07:26 sidecar-container.txt
```

# 4 binbin项目其app32应用
相关文件
```
root@master01:~# tree 03.binbin-project/secrets_binbin-project-ceph-fs-in-binbinfs-user-key/
03.binbin-project/secrets_binbin-project-ceph-fs-in-binbinfs-user-key/
├── ceph.client.binbinfs.secret
├── command.sh
└── secrets_binbin-project-ceph-fs-in-binbinfs-user-key.yaml

0 directories, 3 files
root@master01:~#
root@master01:~#  tree 03.binbin-project/app32/
03.binbin-project/app32/
├── 01.pv_binbin-prod-app32-data.yaml
├── 02.pvc_app32-data.yaml
└── 03.deploy_app32.yaml

0 directories, 3 files
```

创建secrets/binbin-project-ceph-fs-in-binbinfs-user-key对象
```
## 快速编写其manifests
bash 03.binbin-project/secrets_binbin-project-ceph-fs-in-binbinfs-user-key/command.sh

## 应用manifests
kubectl apply -f 03.binbin-project/secrets_binbin-project-ceph-fs-in-binbinfs-user-key/secrets_binbin-project-ceph-fs-in-binbinfs-user-key.yaml --dry-run=client
kubectl apply -f 03.binbin-project/secrets_binbin-project-ceph-fs-in-binbinfs-user-key/secrets_binbin-project-ceph-fs-in-binbinfs-user-key.yaml

## 列出对象
root@master01:~# kubectl -n binbin get secrets/binbin-project-ceph-fs-in-binbinfs-user-key
NAME                                          TYPE     DATA   AGE
binbin-project-ceph-fs-in-binbinfs-user-key   Opaque   1      15s
```

创建pv/binbin-prod-app32-data、pvc/app32-data、deploy/app32对象
```
## 创建
root@master01:~# kubectl apply -f 03.binbin-project/app32/
persistentvolume/binbin-prod-app32-data created
persistentvolumeclaim/app32-data created
deployment.apps/app32 created

## 列出相平面资源对象
kubectl get -f 03.binbin-project/app32/
NAME                                      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS                    REASON   AGE
persistentvolume/binbin-prod-app32-data   10Gi       RWX            Delete           Bound    binbin/app32-data   binbin-project-prod-static-pv            44s

NAME                               STATUS   VOLUME                   CAPACITY   ACCESS MODES   STORAGECLASS                    AGE
persistentvolumeclaim/app32-data   Bound    binbin-prod-app32-data   10Gi       RWX            binbin-project-prod-static-pv   44s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/app32   2/2     2            2           44s

## 列出相关pods资源对象
root@master01:~# kubectl -n binbin get pods -o wide | grep $(kubectl -n binbin describe deploy/app32 | grep "NewReplicaSet:" | cut -d " " -f 4)
app32-749ffb974c-5xtzd   2/2     Running   0          69s   10.0.3.28   node01   <none>           <none>
app32-749ffb974c-7lp9r   2/2     Running   0          69s   10.0.4.31   node02   <none>           <none>
```

以worker node之node01上的pod/app32-749ffb974c-5xtzd为例查看其挂载信息
```
## 查看pods/app32-749ffb974c-5xtzd对象的uid
root@master01:~# kubectl -n binbin get pods/app32-749ffb974c-5xtzd -o json  | jq ".metadata.uid"
"acf9eaa9-ea6c-4349-b76a-43308072c6f5"

## 到worker node之node01上面查看挂载信息
root@node01:~# df -h | grep acf9eaa9-ea6c-4349-b76a-43308072c6f5
tmpfs                                                                                                           7.7G   12K  7.7G   1% /var/lib/kubelet/pods/acf9eaa9-ea6c-4349-b76a-43308072c6f5/volumes/kubernetes.io~projected/kube-api-access-bvkvg
172.31.8.201:6789,172.31.8.202:6789,172.31.8.203:6789:/volumes/app32/data/1ec4eb74-8733-409e-9812-07274170dfab  474G     0  474G   0% /var/lib/kubelet/pods/acf9eaa9-ea6c-4349-b76a-43308072c6f5/volumes/kubernetes.io~cephfs/binbin-prod-app32-data
```

会实现，多个Pod副本间的数据共享、各Pod副本中容器的数据共享
```
参考 "3 binbin项目其app31应用"
```

依次删除deploy/app31、pvc/app31-data、pv/binbin-prod-app31-data对象
```
参考 "3 binbin项目其app31应用"
```

重建pv/binbin-prod-app32-data、pvc/app32-data、deploy/app32对象，以某个Pod副本查看之前的数据是否还在，数据是在的
```
参考 "3 binbin项目其app31应用"
```

# 5 清理环境
```
kubectl delete -f 03.binbin-project/app31/

kubectl delete -f 03.binbin-project/app32/

kubectl delete -f 03.binbin-project/secrets_binbin-project-ceph-fs-in-binbinfs-user-key/
```
