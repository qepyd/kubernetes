# 1 存储系统nfs-server中做准备
```
参考 ./01.storage-admin
```

# 2 k8s管理员做相关的准备
```
参考 ./02.k8s-admin
```

# 3 lili项目的app61项目
相关目录
```
root@master01:~# tree 03.lili-project/app61/
03.lili-project/app61/
└── deploy_app61.yaml

0 directories, 1 file
```

应用manifests
```
root@master01:~# kubectl apply -f 03.lili-project/app61/deploy_app61.yaml --dry-run=client
deployment.apps/app61 created (dry run)

root@master01:~# kubectl apply -f 03.lili-project/app61/deploy_app61.yaml
deployment.apps/app61 created
```

列出相关资源对象
```
## 列出deploy/app61对象
root@master01:~# kubectl -n lili get deploy/app61
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
app61   2/2     2            2           39s

## 查看deploy/app61其最新的rs资源对象名称
root@master01:~# kubectl -n lili describe deploy/app61 | grep "NewReplicaSet:" | cut -d " " -f 4
app61-7944bdbcd

## 列出deploy/app61其最新的rs资源对象
root@master01:~# kubectl -n lili get rs/app61-7944bdbcd
NAME              DESIRED   CURRENT   READY   AGE
app61-7944bdbcd   2         2         2       3m20s


## 列出rs/app61-7944bdbcd所扩展的相关Pod副本
root@master01:~# kubectl -n lili get pods -o wide | grep app61-7944bdbcd
app61-7944bdbcd-68t2z   2/2     Running   0          4m2s   10.0.4.17   node02   <none>           <none>
app61-7944bdbcd-ff657   2/2     Running   0          4m2s   10.0.3.14   node01   <none>           <none>
```

以node01上其Pod/app61-7944bdbcd-ff657查看相关挂载,容器中测试读写
```
## 查看pods/app61-7944bdbcd-ff657的uid
root@master01:~# kubectl -n lili get pods/app61-7944bdbcd-ff657 -o json | jq ".metadata.uid"
"5c2c01e1-babc-43c4-8ede-bc80a5515e6c"

## 到node01上查看相关的挂载
root@node01:~# df -h | grep 5c2c01e1-babc-43c4-8ede-bc80a5515e6c
tmpfs                          7.7G   12K  7.7G   1% /var/lib/kubelet/pods/5c2c01e1-babc-43c4-8ede-bc80a5515e6c/volumes/kubernetes.io~projected/kube-api-access-jf8sc
172.31.7.203:/data/lili/app61   98G  9.2G   84G  10% /var/lib/kubelet/pods/5c2c01e1-babc-43c4-8ede-bc80a5515e6c/volumes/kubernetes.io~nfs/data-volume

## 到pods/app61-7944bdbcd-ff657中的app61容器的/data/目录下中产生数据
root@master01:~# kubectl -n lili exec -it pods/app61-7944bdbcd-ff657 -c app61 -- ls -ld /data
drwxr-xr-x    2 root     root          4096 Aug 17 05:40 /data
root@master01:~#
root@master01:~# kubectl -n lili exec -it pods/app61-7944bdbcd-ff657 -c app61 -- ls -l /data
total 0
root@master01:~# kubectl -n lili exec -it pods/app61-7944bdbcd-ff657 -c app61 -- touch /data/app61-container.txt
root@master01:~# 
root@master01:~# kubectl -n lili exec -it pods/app61-7944bdbcd-ff657 -c app61 -- ls -l /data
total 0
-rw-r--r--    1 root     root             0 Aug 17 05:52 app61-container.txt

## 到pods/app61-7944bdbcd-ff657中的sidecar容器的/data/目录下中产生数据
root@master01:~# kubectl -n lili exec -it pods/app61-7944bdbcd-ff657 -c sidecar -- ls -l /data
total 0
-rw-r--r--    1 root     root             0 Aug 17 05:52 app61-container.txt
root@master01:~#
root@master01:~# kubectl -n lili exec -it pods/app61-7944bdbcd-ff657 -c sidecar -- touch /data/sidecar-container.txt
root@master01:~# 
root@master01:~# kubectl -n lili exec -it pods/app61-7944bdbcd-ff657 -c sidecar -- ls -l /data
total 0
-rw-r--r--    1 root     root             0 Aug 17 05:52 app61-container.txt
-rw-r--r--    1 root     root             0 Aug 17 05:53 sidecar-container.txt
```

到存储系统nfs-server中查看相关的数据
```
root@master01:~# ls -l /data/lili/app61/
total 0
-rw-r--r-- 1 root root 0 Aug 17 13:52 app61-container.txt
-rw-r--r-- 1 root root 0 Aug 17 13:53 sidecar-container.txt
```

销毁deploy/app61后重建，其数据肯定是还在的
```
## 销毁
root@master01:~# kubectl delete -f 03.lili-project/app61/deploy_app61.yaml
deployment.apps "app61" deleted

## 重建
root@master01:~# kubectl apply -f 03.lili-project/app61/deploy_app61.yaml
deployment.apps/app61 created


## 列出相关pod副本
root@master01:~# kubectl -n lili get pods -o wide | grep $(kubectl -n lili describe deploy/app61 | grep "NewReplicaSet:" | cut -d " " -f 4)
app61-7944bdbcd-4nxdr   2/2     Running   0          114s   10.0.3.15   node01   <none>           <none>
app61-7944bdbcd-9wvdc   2/2     Running   0          114s   10.0.4.18   node02   <none>           <none>

## 到某pod副本中查看数据,之前的数据还在
root@master01:~# kubectl -n lili exec -it pods/app61-7944bdbcd-9wvdc -c app61 -- ls -l /data/
total 0
-rw-r--r--    1 root     root             0 Aug 17 05:52 app61-container.txt
-rw-r--r--    1 root     root             0 Aug 17 05:53 sidecar-container.txt
```

# 4 lili项目的app62项目
```
参考 lili 项目的app61项目
```

# 5 清理环境
```
kubectl delete -f 03.lili-project/app61/
kubectl delete -f 03.lili-project/app62/
```
