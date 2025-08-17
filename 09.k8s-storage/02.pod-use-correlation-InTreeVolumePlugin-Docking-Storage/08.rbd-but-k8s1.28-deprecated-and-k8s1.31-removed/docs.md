# 1 存储系统ceph中做准备
```
参考 ./01.storage-admin
```

# 2 k8s管理员做相关准备
```
参考 ./02.k8s-admin
```

# 3 lili项目的app81应用
相关目录
```
root@master01:~# tree 03.lili-project/app81/
03.lili-project/app81/
└── pods_app81.yaml

0 directories, 1 file
```

特别注意
```
需要将 ./01.storage-admin 阶段其 lilirbd 用户的 keyring 导出后，放置到k8s各worker node或lili项目相关worker node的/etc/ceph/目录下
```

应用manifests
```
root@master01:~# kubectl apply -f 03.lili-project/app81/pods_app81.yaml  --dry-run=client
pod/app81 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.lili-project/app81/pods_app81.yaml
pod/app81 created
root@master01:~#
root@master01:~# kubectl -n lili get pods/app81 -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
app81   2/2     Running   0          45s   10.0.3.20   node01   <none>           <none>
```

到Pod相关worker node上查看挂载，到Pod中相关容器中读写数据
```
## 查看Pod的uid
root@master01:~# kubectl -n lili get pods/app81 -o json | jq ".metadata.uid"
"1a06aa6f-7d77-4de5-a155-b79f6c704c3e"

## 到worker node上查看挂载，结果是其挂载点不在相关路径下
root@node01:~# df -h | grep 1a06aa6f-7d77-4de5-a155-b79f6c704c3e
tmpfs           7.7G   12K  7.7G   1% /var/lib/kubelet/pods/1a06aa6f-7d77-4de5-a155-b79f6c704c3e/volumes/kubernetes.io~projected/kube-api-access-4vhkm

## 查看Pod其Pod级别rbd卷类型的信息，其image信息是关键信息
root@master01:~# kubectl -n lili get pods/app81 -o json | jq ".spec.volumes[].rbd"
{
  "fsType": "ext4",
  "image": "app81-data",
  "keyring": "/etc/ceph/ceph.client.lilirbd.keyring",
  "monitors": [
    "172.31.8.201:6789",
    "172.31.8.202:6789",
    "172.31.8.203:6789"
  ],
  "pool": "rbd-lili-project-data",
  "user": "lilirbd"
}
null


## 到worker node上查看相关挂载
root@node01:~# df -h | grep app81-data
/dev/rbd0       4.9G   20M  4.9G   1% /var/lib/kubelet/plugins/kubernetes.io/rbd/mounts/rbd-lili-project-data-image-app81-data
  #
  # 其 rbd-lili-project-data 是ceph集群中其image app81-data的数据存储池
  # 其 image 是关键字
  # 其 app81-data 是 ceph集群中其image之app81-data
  #

## Pod中相关容器读写数据
# <-- app81容器
root@master01:~# kubectl -n lili exec -it pods/app81 -c app81  -- ls -ld /data/
drwxr-xr-x    3 root     root          4096 Aug 17 10:01 /data/
root@master01:~# 
root@master01:~# 
root@master01:~# kubectl -n lili exec -it pods/app81 -c app81  -- ls -l /data/
total 16
drwx------    2 root     root         16384 Aug 17 10:01 lost+found
root@master01:~# 
root@master01:~# 
root@master01:~# kubectl -n lili exec -it pods/app81 -c app81  -- touch /data/app81-container.txt
root@master01:~# 
root@master01:~# 
root@master01:~# kubectl -n lili exec -it pods/app81 -c app81  -- ls -l /data/
total 16
-rw-r--r--    1 root     root             0 Aug 17 10:12 app81-container.txt
drwx------    2 root     root         16384 Aug 17 10:01 lost+found

# <-- sidecar容器
root@master01:~# kubectl -n lili exec -it pods/app81 -c sidecar  -- touch /data/sidecar-container.txt
root@master01:~# 
root@master01:~# 
root@master01:~# kubectl -n lili exec -it pods/app81 -c sidecar  -- ls -l /data/
total 16
-rw-r--r--    1 root     root             0 Aug 17 10:12 app81-container.txt
drwx------    2 root     root         16384 Aug 17 10:01 lost+found
-rw-r--r--    1 root     root             0 Aug 17 10:13 sidecar-container.txt
```

销毁pod/app81并重建，数据是还在的
```
## 销毁
kubectl delete -f 03.lili-project/app81/pods_app81.yaml

## 重建
kubectl apply -f 03.lili-project/app81/pods_app81.yaml

## pod/app81中相关容器查看数据
root@master01:~# kubectl -n lili get pods/app81 
NAME    READY   STATUS    RESTARTS   AGE
app81   2/2     Running   0          15s
root@master01:~#
root@master01:~# 
root@master01:~# kubectl -n lili exec -it  pods/app81  -c app81  -- ls -l /data/
total 16
-rw-r--r--    1 root     root             0 Aug 17 10:12 app81-container.txt
drwx------    2 root     root         16384 Aug 17 10:01 lost+found
-rw-r--r--    1 root     root             0 Aug 17 10:13 sidecar-container.txt
root@master01:~# 
root@master01:~# kubectl -n lili exec -it  pods/app81  -c sidecar  -- ls -l /data/
total 16
-rw-r--r--    1 root     root             0 Aug 17 10:12 app81-container.txt
drwx------    2 root     root         16384 Aug 17 10:01 lost+found
-rw-r--r--    1 root     root             0 Aug 17 10:13 sidecar-container.txt
```


# 4 lili项目的app91应用
相关目录
```
root@master01:~# tree 03.lili-project/secrets_lili-project-ceph-rbd-in-lilirbd-user-key/
03.lili-project/secrets_lili-project-ceph-rbd-in-lilirbd-user-key/
├── ceph.client.lilirbd.secret
├── command.sh
└── secrets_lili-project-ceph-rbd-in-lilirbd-user-key.yaml

0 directories, 3 files
root@master01:~#
root@master01:~#
root@master01:~# tree 03.lili-project/app82/
03.lili-project/app82/
└── pods_app82.yaml

0 directories, 1 file
```

创建secrets/lili-project-ceph-rbd-in-lilirbd-user-key对象
```
## 快速编写其manifests
bash 03.lili-project/secrets_lili-project-ceph-rbd-in-lilirbd-user-key/command.sh

## 应用manifests
kubectl apply -f  03.lili-project/secrets_lili-project-ceph-rbd-in-lilirbd-user-key/secrets_lili-project-ceph-rbd-in-lilirbd-user-key.yaml --dry-run=client
kubectl apply -f  03.lili-project/secrets_lili-project-ceph-rbd-in-lilirbd-user-key/secrets_lili-project-ceph-rbd-in-lilirbd-user-key.yaml

## 列出资源对象
root@master01:~# kubectl -n lili  get secrets/lili-project-ceph-rbd-in-lilirbd-user-key
NAME                                        TYPE     DATA   AGE
lili-project-ceph-rbd-in-lilirbd-user-key   Opaque   1      3s
```

创建pods/app82对象
```
root@master01:~# kubectl apply -f 03.lili-project/app82/pods_app82.yaml --dry-run=client
pod/app82 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.lili-project/app82/pods_app82.yaml
pod/app82 created
root@master01:~#
root@master01:~# kubectl -n lili get pods/app82 -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
app82   2/2     Running   0          28s   10.0.4.23   node02   <none>           <none>
```

到相关worker node上查看挂载，Pod中相关容器读写数据
```
## 查看pod其rbd卷类型的volume
root@master01:~# kubectl -n lili get pods/app82 -o json | jq ".spec.volumes[].rbd"
{
  "fsType": "ext4",
  "image": "app82-data",
  "keyring": "/etc/ceph/keyring",
  "monitors": [
    "172.31.8.201:6789",
    "172.31.8.202:6789",
    "172.31.8.203:6789"
  ],
  "pool": "rbd-lili-project-data",
  "secretRef": {
    "name": "lili-project-ceph-rbd-in-lilirbd-user-key"
  },
  "user": "lilirbd"
}
null

## 到worker node之node02上查看相关挂载
root@node02:~# df -h | grep app82-data
/dev/rbd0       4.9G   20M  4.9G   1% /var/lib/kubelet/plugins/kubernetes.io/rbd/mounts/rbd-lili-project-data-image-app82-data


## Pod中相关容器读写数据
# <-- app82主容器
root@master01:~# kubectl -n lili exec -it pods/app82  -c app82 -- ls -ld /data/
drwxr-xr-x    3 root     root          4096 Aug 17 10:21 /data/
root@master01:~# 
root@master01:~# 
root@master01:~# kubectl -n lili exec -it pods/app82  -c app82 -- ls -l /data/
total 16
drwx------    2 root     root         16384 Aug 17 10:21 lost+found
root@master01:~# 
root@master01:~# kubectl -n lili exec -it pods/app82  -c app82 -- touch /data/app82-container.txt
root@master01:~# 
root@master01:~# kubectl -n lili exec -it pods/app82  -c app82 -- ls -l /data/
total 16
-rw-r--r--    1 root     root             0 Aug 17 10:23 app82-container.txt
drwx------    2 root     root         16384 Aug 17 10:21 lost+found

# <-- sidecar主容器
root@master01:~# kubectl -n lili exec -it pods/app82  -c sidecar -- ls -l /data/
total 16
-rw-r--r--    1 root     root             0 Aug 17 10:23 app82-container.txt
drwx------    2 root     root         16384 Aug 17 10:21 lost+found
root@master01:~# 
root@master01:~# kubectl -n lili exec -it pods/app82  -c sidecar -- touch /data/sidecar-container.txt
root@master01:~# 
root@master01:~# kubectl -n lili exec -it pods/app82  -c sidecar -- ls -l /data/
total 16
-rw-r--r--    1 root     root             0 Aug 17 10:23 app82-container.txt
drwx------    2 root     root         16384 Aug 17 10:21 lost+found
-rw-r--r--    1 root     root             0 Aug 17 10:24 sidecar-container.txt
```

销毁pods/app82并重建，之前的数据还在
```
## 销毁
kubectl delete -f 03.lili-project/app82/pods_app82.yaml

## 重建
kubectl apply -f 03.lili-project/app82/pods_app82.yaml

## 查看之前的数据，数据还在
root@master01:~# kubectl -n lili get pods/app82
NAME    READY   STATUS    RESTARTS   AGE
app82   2/2     Running   0          14s
root@master01:~#
root@master01:~# kubectl -n lili exec -it  pods/app82  -c app82  -- ls -l /data/
total 16
-rw-r--r--    1 root     root             0 Aug 17 10:23 app82-container.txt
drwx------    2 root     root         16384 Aug 17 10:21 lost+found
-rw-r--r--    1 root     root             0 Aug 17 10:24 sidecar-container.txt
root@master01:~# 
root@master01:~# kubectl -n lili exec -it  pods/app82  -c sidecar  -- ls -l /data/
total 16
-rw-r--r--    1 root     root             0 Aug 17 10:23 app82-container.txt
drwx------    2 root     root         16384 Aug 17 10:21 lost+found
-rw-r--r--    1 root     root             0 Aug 17 10:24 sidecar-container.txt
```

# 5 清理环境
```
kubectl delete -f 03.lili-project/app81/

kubectl delete -f 03.lili-project/app82/

kubectl delete -f 03.lili-project/secrets_lili-project-ceph-rbd-in-lilirbd-user-key/
```

