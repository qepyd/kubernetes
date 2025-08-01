# 1 树内插件之emptyDir的介绍
参考： https://kubernetes.io/zh-cn/docs/concepts/storage/volumes/#emptydir

树内插件之emptyDir对接的存储由Pod副本所在worker node上的kubelet进行创建，就是个目录（最初是空的）。

Pod副本的emptyDir卷可以用于Pod中各容器进行数据共享，可以读写（你也可以在主容器挂载处设置为只读），Pod副本的
emptyDir卷其生命周期是随Pod副本的，一但Pod副本销毁，卷也会消失，数据当然也会丢失。

emptyDir卷的使用场景：
```
Pod中各容器间共享少量数据。
共享一些少量且这些数据是可丢失的。
```

emptyDir卷的存储介质：
```
kubectl explain pods.spec.volumes.emptyDir.medium
  # 
  # 默认值为""，可设值也只能是""或Memory。
  # 当为默认值时
  #    其emptyDir卷在worker node上所使用的存储介质可能是磁盘、SSD或网络存储，这取决于你的环境.
  #    其实就是个目录。即 /var/lib/kubelet/pods/<Pod的Uid>/volumes/kubernetes.io~empty-dir/<emptyDir的Name> ，不会被挂载。
  # 当为Memory时
  #    其实就是个目录，即 /var/lib/kubelet/pods/<Pod的Uid>/volumes/kubernetes.io~empty-dir/<emptyDir的Name> ，会被挂载，Filesystem为tmpfs
  #
kubectl explain pods.spec.volumes.emptyDir.sizeLimit
  #
  # 当存储介质为默认值时
  #    可以设置大小
  #
  # 当存储介绍为Memory时
  #    不设置大小
  #      所有主容器均未设置resources.limits.memory 或 多主容器下只要有一个主容器未设置resources.limits.memory 
  #        其大小为所在worker node其物理内存的配置大小
  #      所有主容器均有设置resources.limits.memory
  #        其大小为所有主容器resources.limits.memory之和
  #    应该设置大小
  #      具体大小应该根据其数据占用空间而设置，因为使用的是Memory。
  #      当设置的很大很大(超过worker node的内存)，所有主容器均未设置resources.limits.memory 或 多主容器下只要有一个主容器未设置resources.limits.memory
  #        其大小为所在worker node其物理内存的配置大小
  #        不会影响Pod的调度，即不会计入Pod的总resources.requests.memory。
  #        挂载它的容器若设置有resources.limits.memory,是受限制的。
  #      当设置的很大很大(超过worker node的内存)。所有主容器均有设置resources.limits.memory
  #        大小为所有主容器resources.limits.memory之和
  # 
```

# 2 默认存储介质
```
## 应用manifests
root@master01:~# kubectl apply -f 01.deploy_emptydir-default.yaml  --dry-run=client
deployment.apps/emptydir-default created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 01.deploy_emptydir-default.yaml
deployment.apps/emptydir-default created

## 列出相关资源对象
root@master01:~# kubectl  -n lili get deploy/emptydir-default
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
emptydir-default   2/2     2            2           20s
root@master01:~#
root@master01:~# kubectl  -n lili describe deploy/emptydir-default | grep "NewReplicaSet:" | cut -d " " -f4
emptydir-default-5c99c8589f
root@master01:~#
root@master01:~# kubectl  -n lili get pods -o wide | grep emptydir-default-5c99c8589f
emptydir-default-5c99c8589f-qqfrk   2/2     Running   0          75s   10.0.4.105   node02   <none>           <none>
emptydir-default-5c99c8589f-zjp66   2/2     Running   0          75s   10.0.3.112   node01   <none>           <none>

## node01上的pod/emptydir-default-5c99c8589f-zjp66为例
# <== 找到Pod的uid
root@master01:~# kubectl  -n lili get pod/emptydir-default-5c99c8589f-zjp66 -o json | jq ".metadata.uid"
"48d98867-505b-4438-b939-c33239cf8e3b"

# <== 其所在worker node上的emptydir卷
root@node01:~# df -h | grep 48d98867-505b-4438-b939-c33239cf8e3b
tmpfs           768M   12K  768M   1% /var/lib/kubelet/pods/48d98867-505b-4438-b939-c33239cf8e3b/volumes/kubernetes.io~projected/kube-api-access-4fgcn
  #
  # 这可不是emptydir卷哈，可看到是个投射卷(projected)
  #
root@node01:~# ls -l /var/lib/kubelet/pods/48d98867-505b-4438-b939-c33239cf8e3b/volumes/kubernetes.io~empty-dir/emptydir-default/
total 0
  #
  # 这才是其位置 
  # 

# <== pod/emptydir-default-5c99c8589f-zjp66 中 busybox01 容器在挂载emptyDir郑的挂载点下产生数据 
root@master01:~# kubectl  -n lili exec -it pod/emptydir-default-5c99c8589f-zjp66 -c busybox01 -- ls -l /data/emptydir-default
total 0
root@master01:~#
root@master01:~# kubectl  -n lili exec -it pod/emptydir-default-5c99c8589f-zjp66 -c busybox01 -- touch /data/emptydir-default/a.txt
root@master01:~#
root@master01:~# kubectl  -n lili exec -it pod/emptydir-default-5c99c8589f-zjp66 -c busybox01 -- ls -l /data/emptydir-default
total 0
-rw-r--r--    1 root     root             0 Jul 31 01:40 a.txt

# <== 再到其所在worker node上的位置上看一看
root@node01:~# ls -l /var/lib/kubelet/pods/48d98867-505b-4438-b939-c33239cf8e3b/volumes/kubernetes.io~empty-dir/emptydir-default/
total 0
-rw-r--r-- 1 root root 0 Jul 31 09:40 a.txt

# <== pod/emptydir-default-5c99c8589f-zjp66 中 busybox02 容器在挂载emptyDir郑的挂载点下查看数据
root@master01:~# kubectl  -n lili exec -it pod/emptydir-default-5c99c8589f-zjp66 -c busybox02 -- ls -l /data/emptydir-default
total 0
-rw-r--r--    1 root     root             0 Jul 31 01:40 a.txt

# <== 把 pod/emptydir-default-5c99c8589f-zjp66 销毁，销毁后会重建(因为是由Deployment控制器所编排的，那么emptyDir卷又是新创建的了，又是空的)
root@master01:~# kubectl  -n lili delete pod/emptydir-default-5c99c8589f-zjp66
pod "emptydir-default-5c99c8589f-zjp66" deleted

# <== 列出相关Pod
root@master01:~# kubectl  -n lili get pods -o wide | grep emptydir-default-5c99c8589f
emptydir-default-5c99c8589f-qqfrk   2/2     Running   0          12m   10.0.4.105   node02   <none>           <none>
emptydir-default-5c99c8589f-scxq8   2/2     Running   0          66s   10.0.3.113   node01   <none>           <none>  # 看时间(66s)，它是刚拉起来的Pod副本
root@master01:~#
root@master01:~# kubectl  -n lili exec -it pods/emptydir-default-5c99c8589f-scxq8 -c busybox01 -- ls -l /data/emptydir-default
total 0
root@master01:~# 
root@master01:~# kubectl  -n lili exec -it pods/emptydir-default-5c99c8589f-scxq8 -c busybox02 -- ls -l /data/emptydir-default
total 0
root@master01:~# 

## node02上的pod/emptydir-default-5c99c8589f-qqfrk 
验证操作参考上述的操作，它也有自己的emptyDir卷。
```


# 3 Memory作为存储介质
这里就以 02.deploy_emptydir-memory01.yaml 这个manifests为例，主要是看看各Pod副本所在worker node上其emptyDir卷的位置(会被挂载，因为存储介质是memory)
```
## 应用manifests
root@master01:~# kubectl apply -f 02.deploy_emptydir-memory01.yaml  --dry-run=client
deployment.apps/emptydir-memory01 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 02.deploy_emptydir-memory01.yaml
deployment.apps/emptydir-memory01 created

## 列出相关资源对象
root@master01:~# kubectl -n lili get deploy/emptydir-memory01 
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
emptydir-memory01   2/2     2            2           22s
root@master01:~#
root@master01:~# kubectl -n lili describe deploy/emptydir-memory01  | grep "NewReplicaSet:" | cut -d " " -f4
emptydir-memory01-c77bcc566
root@master01:~#
root@master01:~# kubectl  -n lili get pods -o wide | grep emptydir-memory01-c77bcc566
emptydir-memory01-c77bcc566-gbqn2   2/2     Running   0          87s     10.0.3.114   node01   <none>           <none>
emptydir-memory01-c77bcc566-nd4jj   2/2     Running   0          87s     10.0.4.106   node02   <none>           <none>

## node01上其pod/emptydir-memory01-c77bcc566-gbqn2的emptyDir卷
root@master01:~# kubectl -n lili get pods/emptydir-memory01-c77bcc566-gbqn2 -o json | jq ".metadata.uid"
"ff647282-e10d-4a0b-a2eb-0489c34ad4d7"
root@master01:~# 

root@node01:~# df -h | grep ff647282-e10d-4a0b-a2eb-0489c34ad4d7
tmpfs           7.7G     0  7.7G   0% /var/lib/kubelet/pods/ff647282-e10d-4a0b-a2eb-0489c34ad4d7/volumes/kubernetes.io~empty-dir/emptydir-memory01
tmpfs           7.7G   12K  7.7G   1% /var/lib/kubelet/pods/ff647282-e10d-4a0b-a2eb-0489c34ad4d7/volumes/kubernetes.io~projected/kube-api-access-9jjgk
  #
  # 第一个，大小是7.7G，是因为我没有设置emptyDir卷的大小，所有主容器均未设置resources.limits.memory，其大小为所在worker node物理内存的配置大小
  #
root@node01:~# free -h
              total        used        free      shared  buff/cache   available
Mem:          7.7Gi       643Mi       4.0Gi       2.0Mi       3.1Gi       6.8Gi
Swap:            0B          0B          0B

## node02上其pod/emptydir-memory01-c77bcc566-nd4jj
验证操作参考上述的操作，它也有自己的emptyDir卷。
```

# 4 清理环境
```
kubectl delete -f ./01.deploy_emptydir-default.yaml
kubectl delete -f ./02.deploy_emptydir-memory01.yaml
kubectl delete -f ./03.deploy_emptydir-memory02.yaml
kubectl delete -f ./04.deploy_emptydir-memory03.yaml
kubectl delete -f ./05.deploy_emptydir-memory04.yaml
```
