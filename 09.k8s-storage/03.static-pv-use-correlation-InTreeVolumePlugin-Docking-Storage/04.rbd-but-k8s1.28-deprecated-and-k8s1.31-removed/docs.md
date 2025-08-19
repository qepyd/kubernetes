# 1 存储系统ceph中做准备
```
参考 ./01.storage-admin/
```

# 2 k8s管理员做相关准备
```
参考 ./02.k8s-admin/
```

# 3 binbin项目其app41应用
相关文件
```
root@master01:~# tree 03.binbin-project/app41/
03.binbin-project/app41/
├── 01.pv_binbin-prod-app41-data.yaml
├── 02.pvc_app41-data.yaml
└── 03.pods_app41.yaml

0 directories, 3 files

```

相关注意
```
需要将 ./01.storage-admin/ 处其binbinrbd用户的keyring放在k8s其worker node的/etc/ceph/目录下。
```

创建相关资源对象
```
## 创建相关资源对象
root@master01:~# kubectl apply -f 03.binbin-project/app41/ --dry-run=clientpersistentvolume/binbin-prod-app41-data created (dry run)
persistentvolumeclaim/app41-data created (dry run)
pod/app41 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.binbin-project/app41/
persistentvolume/binbin-prod-app41-data created
persistentvolumeclaim/app41-data created
pod/app41 created

## 列出相平关资源对象
root@master01:~# kubectl get -f 03.binbin-project/app41/
NAME                                      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS                    REASON   AGE
persistentvolume/binbin-prod-app41-data   5Gi        RWO            Delete           Bound    binbin/app41-data   binbin-project-prod-static-pv            36s

NAME                               STATUS   VOLUME                   CAPACITY   ACCESS MODES   STORAGECLASS                    AGE
persistentvolumeclaim/app41-data   Bound    binbin-prod-app41-data   5Gi        RWO            binbin-project-prod-static-pv   36s

NAME        READY   STATUS    RESTARTS   AGE
pod/app41   2/2     Running   0          36s

## 列出pod/app41，交显示详细信息
root@master01:~# kubectl -n binbin get pods/app41 -o wide
NAME    READY   STATUS    RESTARTS   AGE    IP          NODE     NOMINATED NODE   READINESS GATES
app41   2/2     Running   0          101s   10.0.3.29   node01   <none>           <none>
```

查看Pod/app41其在worker node的挂载信息
```
## 查看其间接引用pv资源对象的信息
root@master01:~# kubectl get pv  binbin-prod-app41-data -o json | jq ".spec.rbd.pool"
"rbd-binbin-project-data"
root@master01:~#
root@master01:~# kubectl get pv  binbin-prod-app41-data -o json | jq ".spec.rbd.image"
"app41-data"

## 到worker node之node01上查看挂载信息
root@node01:~# df -h | grep rbd-binbin-project-data
/dev/rbd0       4.9G   20M  4.9G   1% /var/lib/kubelet/plugins/kubernetes.io/rbd/mounts/rbd-binbin-project-data-image-app41-data
root@node01:~# 
root@node01:~# df -h | grep rbd-binbin-project-data | grep app41-data
/dev/rbd0       4.9G   20M  4.9G   1% /var/lib/kubelet/plugins/kubernetes.io/rbd/mounts/rbd-binbin-project-data-image-app41-data
```

在Pod/app41对象中产生数据
```
## 主容器app41写入数据

t@master01:~# kubectl -n binbin exec -it pods/app41 -c app41 -- ls -l /data/
total 16
drwx------    2 root     root         16384 Aug 19 10:41 lost+found
root@master01:~# 
root@master01:~# kubectl -n binbin exec -it pods/app41 -c app41 -- touch /data/a.txt
root@master01:~# 
root@master01:~# kubectl -n binbin exec -it pods/app41 -c app41 -- ls -l /data/
total 16
-rw-r--r--    1 root     root             0 Aug 19 10:57 a.txt
drwx------    2 root     root         16384 Aug 19 10:41 lost+found

## 主容器sidecar读数据
root@master01:~# kubectl -n binbin exec -it pods/app41 -c sidecar -- ls -l /data/
total 16
-rw-r--r--    1 root     root             0 Aug 19 10:57 a.txt
drwx------    2 root     root         16384 Aug 19 10:41 lost+found
```


依次删除pods/app41、pvc/app41-data、pv/binbin-prod-app41-data对象
```
## 删除pods/app41
root@master01:~# kubectl -n binbin get pods/app41
NAME    READY   STATUS    RESTARTS   AGE
app41   2/2     Running   0          8m14s
root@master01:~#
root@master01:~# kubectl -n binbin delete pods/app41
pod "app41" deleted

## 删除pvc/app41-data
root@master01:~# kubectl -n binbin get pvc/app41-data
NAME         STATUS   VOLUME                   CAPACITY   ACCESS MODES   STORAGECLASS                    AGE
app41-data   Bound    binbin-prod-app41-data   5Gi        RWO            binbin-project-prod-static-pv   10m
root@master01:~#
root@master01:~# kubectl -n binbin delete pvc/app41-data
persistentvolumeclaim "app41-data" deleted

## 查看pv/binbin-prod-app41-data是否还在
#  其回收策略虽然为Delete,但对于其rbd卷类型的静态pv,是不起作用的
root@master01:~# kubectl get pv/binbin-prod-app41-data
NAME                     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS                    REASON   AGE
binbin-prod-app41-data   5Gi        RWO            Delete           Failed   binbin/app41-data   binbin-project-prod-static-pv            10m

## 删除pv/binbin-prod-app41-data对象
root@master01:~# kubectl delete  pv/binbin-prod-app41-data
persistentvolume "binbin-prod-app41-data" deleted
```

重建pods/app41、pvc/app41-data、pv/binbin-prod-app41-data对象，查看之前的数据是否还在
```
## 重建
kubectl apply -f 03.binbin-project/app41/
persistentvolume/binbin-prod-app41-data created
persistentvolumeclaim/app41-data created
pod/app41 created

## 列出相关资源对象
kubectl get -f 03.binbin-project/app41/
NAME                                      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS                    REASON   AGE
persistentvolume/binbin-prod-app41-data   5Gi        RWO            Delete           Bound    binbin/app41-data   binbin-project-prod-static-pv            18s

NAME                               STATUS   VOLUME                   CAPACITY   ACCESS MODES   STORAGECLASS                    AGE
persistentvolumeclaim/app41-data   Bound    binbin-prod-app41-data   5Gi        RWO            binbin-project-prod-static-pv   18s

NAME        READY   STATUS    RESTARTS   AGE
pod/app41   2/2     Running   0          18s

## 从Pod/app41中相关容器视角检查之前的数据是否还在，是在的。
root@master01:~# kubectl -n binbin exec -it pods/app41 -c app41  -- ls -l /data/
total 16
-rw-r--r--    1 root     root             0 Aug 19 10:57 a.txt
drwx------    2 root     root         16384 Aug 19 10:41 lost+found
```

# 4 binbin项目其app42应用
相关文件
```
root@master01:~# tree 03.binbin-project/secrets_binbin-project-ceph-rbd-in-binbinrbd-user-key/
03.binbin-project/secrets_binbin-project-ceph-rbd-in-binbinrbd-user-key/
├── ceph.client.binbinrbd.secret
├── command.sh
└── secrets_binbin-project-ceph-rbd-in-binbinrbd-user-key.yaml

0 directories, 3 files
root@master01:~#
root@master01:~# tree 03.binbin-project/app42/
03.binbin-project/app42/
├── 01.pv_binbin-prod-app42-data.yaml
├── 02.pvc_app42-data.yaml
└── 03.pods_app42.yaml

0 directories, 3 files
```

创建secrets/binbin-project-ceph-rbd-in-binbinrbd-user-key对象
```
## 快速编写manifests
bash 03.binbin-project/secrets_binbin-project-ceph-rbd-in-binbinrbd-user-key/command.sh

## 应用manifests
kubectl apply -f 03.binbin-project/secrets_binbin-project-ceph-rbd-in-binbinrbd-user-key/secrets_binbin-project-ceph-rbd-in-binbinrbd-user-key.yaml

## 列出资源对象
root@master01:~# kubectl -n binbin get secrets binbin-project-ceph-rbd-in-binbinrbd-user-key
NAME                                            TYPE     DATA   AGE
binbin-project-ceph-rbd-in-binbinrbd-user-key   Opaque   1      7s
```

创建app42应用
```
## 创建
root@master01:~# kubectl apply -f 03.binbin-project/app42/ --dry-run=clientpersistentvolume/binbin-prod-app42-data created (dry run)
persistentvolumeclaim/app42-data created (dry run)
pod/app42 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.binbin-project/app42/
persistentvolume/binbin-prod-app42-data created
persistentvolumeclaim/app42-data created
pod/app42 created

## 列出相关资源对象
root@master01:~# kubectl get -f 03.binbin-project/app42/
NAME                                      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS                    REASON   AGE
persistentvolume/binbin-prod-app42-data   5Gi        RWO            Delete           Bound    binbin/app42-data   binbin-project-prod-static-pv            35s

NAME                               STATUS   VOLUME                   CAPACITY   ACCESS MODES   STORAGECLASS                    AGE
persistentvolumeclaim/app42-data   Bound    binbin-prod-app42-data   5Gi        RWO            binbin-project-prod-static-pv   35s

NAME        READY   STATUS    RESTARTS   AGE
pod/app42   2/2     Running   0          35s

## 列出pods/app42应用并显示详细信息
root@master01:~# kubectl -n binbin get pod/app42 -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
app42   2/2     Running   0          61s   10.0.4.32   node02   <none>           <none>
```

到pod/app42所在worker node上查看相关挂载
```
## 查看pod/app42间接所引用pv资源对象中的相关信息
root@master01:~# kubectl get pv/binbin-prod-app42-data  -o json | jq ".spec.rbd.pool"
"rbd-binbin-project-data"
root@master01:~# 
root@master01:~# kubectl get pv/binbin-prod-app42-data  -o json | jq ".spec.rbd.image"
"app42-data"

## 到pod/app42所在worker node查看相关挂载
root@node02:~# df -h | grep rbd-binbin-project-data
/dev/rbd0       4.9G   20M  4.9G   1% /var/lib/kubelet/plugins/kubernetes.io/rbd/mounts/rbd-binbin-project-data-image-app42-data
root@node02:~# 
root@node02:~# df -h | grep rbd-binbin-project-data | grep app42-data
/dev/rbd0       4.9G   20M  4.9G   1% /var/lib/kubelet/plugins/kubernetes.io/rbd/mounts/rbd-binbin-project-data-image-app42-data
```

在Pod/app42对象中相关容器里面产生数据
```
参考 "3 binbin项目其app41应用"
```

依次删除pods/app42、pvc/app42-data、pv/binbin-prod-app42-data对象
```
参考 "3 binbin项目其app41应用"
```

重建pods/app42、pvc/app42-data、pv/binbin-prod-app42-data对象，查看之前的数据是否还在
```
参考 "3 binbin项目其app41应用"
```

# 5 清理环境
```
kubectl delete -f  03.binbin-project/app41/

kubectl delete -f  03.binbin-project/app42/

kubectl delete -f  03.binbin-project/secrets_binbin-project-ceph-rbd-in-binbinrbd-user-key/
```
