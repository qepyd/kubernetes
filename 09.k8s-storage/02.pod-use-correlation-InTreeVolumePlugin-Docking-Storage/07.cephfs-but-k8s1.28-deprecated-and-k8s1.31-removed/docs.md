# 1 存储系统ceph中做准备
```
参考 ./01.storage-admin
```

# 2 k8s管理员做相关准备
```
参考 ./02.k8s-admin
```

# 3 lili项目的app71应用
相关目录
```
root@master01:~# tree 03.lili-project/app71/
03.lili-project/app71/
├── deploy_app71.yaml
└── docs.md

0 directories, 2 files
```

注意：
```
需要将 ./01.storage-admin 阶段其 lilifs 用户的key导出，放置到k8s各worker node或lili项目相关worker node的/etc/ceph/目录下
```

应用manifests
```
root@master01:~# kubectl apply -f 03.lili-project/app71/deploy_app71.yaml  --dry-run=client
deployment.apps/app71 created (dry run)

root@master01:~# kubectl apply -f 03.lili-project/app71/deploy_app71.yaml
deployment.apps/app71 created
```

列出相关资源对象
```
## 列出deploy/app71对象
root@master01:~# kubectl -n lili get deploy/app71
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
app71   2/2     2            2           31s

## 列出deploy/app71其最新的rs资源对象
root@master01:~# kubectl -n lili get rs $(kubectl -n lili describe deploy/app71  | grep "NewReplicaSet:" | cut -d " " -f 4)
NAME               DESIRED   CURRENT   READY   AGE
app71-74df6cd9cb   2         2         2       3m19s

## 列出rs/app71-74df6cd9cb对象所扩展的pod副本
root@master01:~# kubectl -n lili get pods  -o wide | grep app71-74df6cd9cb
app71-74df6cd9cb-f26mq   2/2     Running   0          3m52s   10.0.4.19   node02   <none>           <none>
app71-74df6cd9cb-mqpd5   2/2     Running   0          3m52s   10.0.3.16   node01   <none>           <none>
```

以worker node之node01上其Pod/app71-74df6cd9cb-mqpd5为例 
```
## 查看pod/app71-74df6cd9cb-mqpd5对象的uid
root@master01:~# kubectl -n lili get pod/app71-74df6cd9cb-mqpd5 -o json | jq ".metadata.uid"
"bc04d8e4-b77d-4a57-9c93-7978d3dd47f7"

## 到worker node之node01上查看其挂载
root@node01:~# df -h | grep bc04d8e4-b77d-4a57-9c93-7978d3dd47f7
tmpfs                                                                                                           7.7G   12K  7.7G   1% /var/lib/kubelet/pods/bc04d8e4-b77d-4a57-9c93-7978d3dd47f7/volumes/kubernetes.io~projected/kube-api-access-52p9w
172.31.8.201:6789,172.31.8.202:6789,172.31.8.203:6789:/volumes/app71/data/91775ac5-bbb9-4e35-8536-01a5ef677697  474G     0  474G   0% /var/lib/kubelet/pods/bc04d8e4-b77d-4a57-9c93-7978d3dd47f7/volumes/kubernetes.io~cephfs/share-data


## pod/app71-74df6cd9cb-mqpd5中的app71产生数据，并到sidecar容器中查看
root@master01:~# kubectl -n lili exec -it pod/app71-74df6cd9cb-mqpd5  -c app71 -- ls -ld /data
drwxr-xr-x    2 root     root             0 Aug 17 07:03 /data
root@master01:~# 
root@master01:~# kubectl -n lili exec -it pod/app71-74df6cd9cb-mqpd5  -c app71 -- ls -l /data
total 0
root@master01:~# 
root@master01:~# kubectl -n lili exec -it pod/app71-74df6cd9cb-mqpd5  -c app71 -- touch /data/app71-container.txt
root@master01:~# 
root@master01:~# kubectl -n lili exec -it pod/app71-74df6cd9cb-mqpd5  -c app71 -- ls -l /data
total 0
-rw-r--r--    1 root     root             0 Aug 17 07:25 app71-container.txt

root@master01:~# kubectl -n lili exec -it pod/app71-74df6cd9cb-mqpd5  -c sidecar -- ls -l /data
total 0
-rw-r--r--    1 root     root             0 Aug 17 07:25 app71-container.txt


## 注意
worker node之node02上的pod/app71-74df6cd9cb-f26mq对象其相关容器也可以查看到数据，写入数据。各Pod副本间可以相互查看数据
```

销毁deploy/app71并重建，之前的数据是还在的
```
## 销毁deploy/app71
kubectl delete -f 03.lili-project/app71/deploy_app71.yaml

## 重建
kubectl apply -f 03.lili-project/app71/deploy_app71.yaml

## 列出相关Pod副本
root@master01:~# kubectl -n lili get rs $(kubectl -n lili describe deploy/app71  | grep "NewReplicaSet:" | cut -d " " -f 4)
NAME               DESIRED   CURRENT   READY   AGE
app71-74df6cd9cb   2         2         2       21s
root@master01:~#
root@master01:~# kubectl -n lili get pods -o wide | grep app71-74df6cd9cb
app71-74df6cd9cb-ksts5   2/2     Running   0          42s   10.0.3.17   node01   <none>           <none>
app71-74df6cd9cb-r6r5g   2/2     Running   0          42s   10.0.4.20   node02   <none>           <none>

## 进入相关Pod副本的相关主容查看数据，之前的数据还在的
root@master01:~# kubectl -n lili exec -it pods/app71-74df6cd9cb-r6r5g -c app71  -- ls -l /data/
total 0
-rw-r--r--    1 root     root             0 Aug 17 07:25 app71-container.txt
root@master01:~# 
root@master01:~# kubectl -n lili exec -it pods/app71-74df6cd9cb-r6r5g -c sidecar  -- ls -l /data/
total 0
-rw-r--r--    1 root     root             0 Aug 17 07:25 app71-container.txt
```

# 4 lili项目的app72应用
相关目录
```
root@master01:~# tree 03.lili-project/secrets_lili-project-ceph-fs-in-lilifs-user-key/
03.lili-project/secrets_lili-project-ceph-fs-in-lilifs-user-key/
├── ceph.client.lilifs.secret
├── command.sh
└── secrets_lili-project-ceph-fs-in-lilifs-user-key.yaml

0 directories, 3 files
root@master01:~#
root@master01:~#
root@master01:~# tree 03.lili-project/app72/
03.lili-project/app72/
├── deploy_app72.yaml
└── docs.md

0 directories, 2 files
```

创建secrets/lili-project-ceph-fs-in-lilifs-user-key对象
```
## 快速编写其manifests
bash 03.lili-project/command.sh

## 应用manifests
kubectl apply -f 03.lili-project/secrets_lili-project-ceph-fs-in-lilifs-user-key/secrets_lili-project-ceph-fs-in-lilifs-user-key.yaml  --dry-run=client
kubectl apply -f 03.lili-project/secrets_lili-project-ceph-fs-in-lilifs-user-key/secrets_lili-project-ceph-fs-in-lilifs-user-key.yaml

## 列出资源对象
root@master01:~# kubectl -n lili get secrets/lili-project-ceph-fs-in-lilifs-user-key
NAME                                      TYPE     DATA   AGE
lili-project-ceph-fs-in-lilifs-user-key   Opaque   1      8s
```

创建deploy/app72资源对象
```
root@master01:~# kubectl apply -f 03.lili-project/app72/deploy_app72.yaml --dry-run=client
deployment.apps/app72 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.lili-project/app72/deploy_app72.yaml 
deployment.apps/app72 created
```

列出相关资源对象
```
## 列出deploy/app72对象
root@master01:~# kubectl -n lili get deploy/app71
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
app71   2/2     2            2           7m42s

## 列出deploy/app72其最新的rs资源对象
root@master01:~# kubectl -n lili get rs $(kubectl -n lili describe deploy/app72  | grep "NewReplicaSet:" | cut -d " " -f 4)
NAME               DESIRED   CURRENT   READY   AGE
app72-557f6f44dd   2         2         2       63s

## 列出deploy/app72其最新的rs资源对象的相关pod
root@master01:~# kubectl -n lili get pods -o wide | grep app72-557f6f44dd
app72-557f6f44dd-9k6pg   2/2     Running   0          90s     10.0.4.21   node02   <none>           <none>
app72-557f6f44dd-dkhdd   2/2     Running   0          90s     10.0.3.18   node01   <none>           <none>
```

以worker node之node01上的pod/app72-557f6f44dd-dkhdd为例
```
## 查看pod/app72-557f6f44dd-dkhdd的uid
root@master01:~# kubectl -n lili get pod/app72-557f6f44dd-dkhdd -o json | jq ".metadata.uid"
"9894531a-6fa2-455a-a0da-42016cce95c2"

## 到worker node之node01上查看相关的挂载
root@node01:~# df -h | grep 9894531a-6fa2-455a-a0da-42016cce95c2
tmpfs                                                                                                           7.7G   12K  7.7G   1% /var/lib/kubelet/pods/9894531a-6fa2-455a-a0da-42016cce95c2/volumes/kubernetes.io~projected/kube-api-access-tcxpp
172.31.8.201:6789,172.31.8.202:6789,172.31.8.203:6789:/volumes/app72/data/b36d80c4-ea26-4706-afd3-95e742c665f4  474G     0  474G   0% /var/lib/kubelet/pods/9894531a-6fa2-455a-a0da-42016cce95c2/volumes/kubernetes.io~cephfs/share-data

## pod/app72-557f6f44dd-dkhdd中相关容器产生数据、查看数据
root@master01:~# kubectl -n lili exec -it pod/app72-557f6f44dd-dkhdd -c app72 -- ls -ld /data/
drwxr-xr-x    2 root     root             0 Aug 17 07:05 /data/
root@master01:~# 
root@master01:~# kubectl -n lili exec -it pod/app72-557f6f44dd-dkhdd -c app72 -- ls -l /data/
total 0
root@master01:~# 
root@master01:~# kubectl -n lili exec -it pod/app72-557f6f44dd-dkhdd -c app72 -- touch /data/app72-container.txt
root@master01:~# 
root@master01:~# kubectl -n lili exec -it pod/app72-557f6f44dd-dkhdd -c app72 -- ls -l /data/
total 0
-rw-r--r--    1 root     root             0 Aug 17 07:38 app72-container.txt

root@master01:~# kubectl -n lili exec -it pod/app72-557f6f44dd-dkhdd -c sidecar -- ls -l /data/
total 0
-rw-r--r--    1 root     root             0 Aug 17 07:38 app72-container.txt

## 注意
worker node之node02上的pod/app72-557f6f44dd-9k6pg对象其相关容器也可以查看到数据，写入数据。各Pod副本间可以相互查看数据
```

销毁deploy/app72对象并重建，之前的数据还在的
```
## 销毁
kubectl delete -f 03.lili-project/app72/deploy_app72.yaml

## 重建
kubectl apply -f 03.lili-project/app72/deploy_app72.yaml

## 列出相关Pod
root@master01:~# kubectl -n lili get pods -o wide | grep  $(kubectl -n lili describe deploy/app72  | grep "NewReplicaSet:" | cut -d " " -f 4)
app72-557f6f44dd-444mr   2/2     Running   0          24s    10.0.3.19   node01   <none>           <none>
app72-557f6f44dd-rk8ph   2/2     Running   0          24s    10.0.4.22   node02   <none>           <none>

## 某Pod副本中相关容器查看数据是否还在
root@master01:~# kubectl -n lili exec -it pods/app72-557f6f44dd-rk8ph -c app72 -- ls -l /data/
total 0
-rw-r--r--    1 root     root             0 Aug 17 07:38 app72-container.txt
root@master01:~# 
root@master01:~# kubectl -n lili exec -it pods/app72-557f6f44dd-rk8ph -c sidecar -- ls -l /data/
total 0
-rw-r--r--    1 root     root             0 Aug 17 07:38 app72-container.txt
root@master01:~# 
```

# 5 清理环境
```
kubectl delete -f 03.lili-project/app71/

kubectl delete -f 03.lili-project/app72/
kubectl delete -f 03.lili-project/secrets_lili-project-ceph-fs-in-lilifs-user-key/
```
