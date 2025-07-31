# 1 树内插件之emptyDir的介绍
参考： https://kubernetes.io/zh-cn/docs/concepts/storage/volumes/#emptydir

树内插件之emptyDir后端的存储(emptyDir卷)由Pod副本所在worker node上的kubelet进行创建，
emptyDir卷最初是空的。

Pod副本的emptyDir卷可以用于Pod中各容器进行数据共享，可以读写。挂载了emptyDir卷的容器
在崩溃期间是不影响emptyDir卷中的数据安全，但是当Pod副本销毁重建后，emptyDir卷是会被
移除，从而数据也会丢失。

emptyDir卷的使用场景：
```
Pod中各容器间共享数据
共享一些少量且可丢失的数据
```

emptyDir卷的存储介质：
```
kubectl explain pods.spec.volumes.emptyDir.medium
  # 
  # 默认值为""，可设值也只能是""或Memory。
  # 当为默认值时
  #    其emptyDir卷在worker node上所使用的存储介质可能是磁盘、SSD或网络存储，这取决于你的环境.
  #    其实就是个目录。/var/lib/kubelet/pods/<Pod的Uid>/volumes/kubernetes.io~empty-dir/<emptyDir的Name>
  # 当为Memory时
  #    会将/var/lib/kubelet/pods/<Pod的Uid>/volumes/kubernetes.io~empty-dir/<emptyDir的Name>在worker node上进行挂载
  #    其Filesystem为tmpfs
  #
kubectl explain pods.spec.volumes.emptyDir.sizeLimit
  #
  # 当存储介质为默认值时
  #    可以设置大小
  #
  # 当存储介绍为Memory时
  #    不设置大小
  #      所有主容器均未设置resources.limits.memory或只有一个设置了resources.limits.memory时，其大小即为所在worker node上的所有内存空间。
  #      所有主容器均有设置resources.limits.memory，其大小为所有主容器resources.limits.memory的总和。
  #    应该设置大小
  #      根据所共享数据的大小(一般是少量数据、可丢失的数据)。
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
  # 这可不是emptydir卷哈，可看到是个投射卷(project)
  #
root@node01:~# ls -l /var/lib/kubelet/pods/48d98867-505b-4438-b939-c33239cf8e3b/volumes/kubernetes.io~empty-dir/emptydir-default/
total 0
  #
  # 这才是其位置 
  # 

# <== pod/emptydir-default-5c99c8589f-zjp66中某容器写入数据 
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

# <== pod/emptydir-default-5c99c8589f-zjp66中另一容器查看数据
root@master01:~# kubectl  -n lili exec -it pod/emptydir-default-5c99c8589f-zjp66 -c busybox02 -- ls -l /data/emptydir-default
total 0
-rw-r--r--    1 root     root             0 Jul 31 01:40 a.txt

# <== pod/emptydir-default-5c99c8589f-zjp66销毁，销毁后会重建(由Deployment控制器再拉起Pod副本，那么emptyDir卷又是新的了,又是空的了)
root@master01:~# kubectl  -n lili delete pod/emptydir-default-5c99c8589f-zjp66
pod "emptydir-default-5c99c8589f-zjp66" deleted

# <== 列出相关Pod
root@master01:~# kubectl  -n lili get pods -o wide | grep emptydir-default-5c99c8589f
emptydir-default-5c99c8589f-qqfrk   2/2     Running   0          12m   10.0.4.105   node02   <none>           <none>
emptydir-default-5c99c8589f-scxq8   2/2     Running   0          66s   10.0.3.113   node01   <none>           <none>  # 看时间(66s)，它是重新拉起来的Pod副本
root@master01:~#
root@master01:~# kubectl  -n lili exec -it pods/emptydir-default-5c99c8589f-scxq8 -c busybox01 -- ls -l /data/emptydir-default
total 0
root@master01:~# 
root@master01:~# kubectl  -n lili exec -it pods/emptydir-default-5c99c8589f-scxq8 -c busybox02 -- ls -l /data/emptydir-default
total 0
root@master01:~# 

## node02上的pod/emptydir-default-5c99c8589f-qqfrk为例
跟上现是一样的,即使它也在node01这个worker node上。
```


# 2 Memory
```


```
