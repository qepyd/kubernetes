# 1 存储系统nfs-server中做准备
```
参考 ./01.storage-admin/
```

# 2 k8s管理员做相关的准备
```
参考 ./02.k8s-admin/
```

# 3 binbin项目的app21应用
相关目录
```
tree 03.binbin-project/app21/
03.binbin-project/app21/
├── 01.pv_binbin-prod-app21.yaml
├── 02.pvc_app21.yaml
└── 03.deploy_app21.yaml

0 directories, 3 files
```

创建pv/binbin-prod-app21对象
```
root@master01:~# kubectl apply -f 03.binbin-project/app21/01.pv_binbin-prod-app21.yaml --dry-run=client
persistentvolume/binbin-prod-app21 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.binbin-project/app21/01.pv_binbin-prod-app21.yaml 
persistentvolume/binbin-prod-app21 created
root@master01:~#
root@master01:~#
root@master01:~# kubectl get pv/binbin-prod-app21
NAME                CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS                    REASON   AGE
binbin-prod-app21   10Gi       RWX            Delete           Available           binbin-project-prod-static-pv            31s
  #
  # STORAGECLASS：
  #   其值：
  #     若是sc资源对象，那么就是动态pv（dynamic pv）
  #     若不是sc资源对象，那么就是静态pv（static pv）
  #   空值
  #    那么pv一定是static pv。
  #  
  # STATUS：
  #   Available，可供pvc来进行匹配
  # 
  # RECLAIM POLICY：
  #   Delete
  #      静态pv之nfs卷类型，其与之绑定的pvc被删除后,静态pv不会自动回收，
  #      需求人为回收，人为回收后，是不会删除nfs-server中的数据的。
  # 
  # ACCESS MODES
  #   RWX(多路读写)
  #
  # 
```

创建pvc/app21对象
```
root@master01:~# kubectl apply -f 03.binbin-project/app21/02.pvc_app21.yaml  --dry-run=client
persistentvolumeclaim/app21 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.binbin-project/app21/02.pvc_app21.yaml 
persistentvolumeclaim/app21 created
root@master01:~#
root@master01:~# root@master01:~# kubectl -n binbin get pvc/app21
NAME    STATUS   VOLUME              CAPACITY   ACCESS MODES   STORAGECLASS                    AGE
app21   Bound    binbin-prod-app21   10Gi       RWX            binbin-project-prod-static-pv   35s
  #
  # 与pv/binbin-prod-app21进行了绑定
  #

```

创建deploy/app21对象
```
root@master01:~# kubectl apply -f 03.binbin-project/app21/03.deploy_app21.yaml --dry-run=client
deployment.apps/app21 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.binbin-project/app21/03.deploy_app21.yaml
deployment.apps/app21 created
root@master01:~#
root@master01:~# kubectl -n binbin get deploy/app21
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
app21   2/2     2            2           25s
```

其deploy/app21对象最新rs资源对象相关Pod副本
```
## 列出deploy/app21对象其最新的rs资源对象
root@master01:~# kubectl -n binbin get rs  $(kubectl -n binbin describe deploy/app21  | grep "NewReplicaSet:" | cut -d " " -f4)
NAME               DESIRED   CURRENT   READY   AGE
app21-68598fc86d   2         2         2       3m

## 列出deploy/app21对象其最新rs资源对象相关的pod副本
root@master01:~# kubectl -n binbin get pods -o wide | grep app21-68598fc86d
app21-68598fc86d-glmk8   2/2     Running   0          3m25s   10.0.3.22   node01   <none>           <none>
app21-68598fc86d-rnzpl   2/2     Running   0          3m25s   10.0.4.25   node02   <none>           <none>
```

worker node之node01上其pod/app21-68598fc86d-glmk8的挂载信息，相关容器读写数据
```
## 查看pod的uid
root@master01:~# kubectl -n binbin get pods/app21-68598fc86d-glmk8  -o json | jq ".metadata.uid"
"15abff34-742e-4297-8bbd-5344f9879cde"

## worker node之node01上查看挂载信息
root@node01:~# df -h | grep 15abff34-742e-4297-8bbd-5344f9879cde
tmpfs                            7.7G   12K  7.7G   1% /var/lib/kubelet/pods/15abff34-742e-4297-8bbd-5344f9879cde/volumes/kubernetes.io~projected/kube-api-access-bqwf4
172.31.7.203:/data/binbin/app21   98G  9.2G   84G  10% /var/lib/kubelet/pods/15abff34-742e-4297-8bbd-5344f9879cde/volumes/kubernetes.io~nfs/binbin-prod-app21


## 相关容器读写数据
# <-- app21主容器
root@master01:~# kubectl -n binbin exec -it pods/app21-68598fc86d-glmk8  -c app21  -- ls -ld /data/
drwxr-xr-x    2 root     root          4096 Aug 17 11:18 /data/
root@master01:~# 
root@master01:~# 
root@master01:~# kubectl -n binbin exec -it pods/app21-68598fc86d-glmk8  -c app21  -- ls -ls /data/
total 0
root@master01:~# 
root@master01:~# 
root@master01:~# kubectl -n binbin exec -it pods/app21-68598fc86d-glmk8  -c app21  -- touch  /data/app21-container.txt
root@master01:~# 
root@master01:~# kubectl -n binbin exec -it pods/app21-68598fc86d-glmk8  -c app21  -- ls -ls /data/
total 0
     0 -rw-r--r--    1 root     root             0 Aug 17 11:42 app21-container.txt

# <-- sidecar主容器
root@master01:~# kubectl -n binbin exec -it pods/app21-68598fc86d-glmk8  -c sidecar  -- ls -ls /data/
total 0
     0 -rw-r--r--    1 root     root             0 Aug 17 11:42 app21-container.txt
root@master01:~# 
root@master01:~# kubectl -n binbin exec -it pods/app21-68598fc86d-glmk8  -c sidecar  -- touch /data/sidecar-container.txt
root@master01:~# 
root@master01:~# kubectl -n binbin exec -it pods/app21-68598fc86d-glmk8  -c sidecar  -- ls -ls /data/
total 0
     0 -rw-r--r--    1 root     root             0 Aug 17 11:42 app21-container.txt
     0 -rw-r--r--    1 root     root             0 Aug 17 11:43 sidecar-container.txt
```

销毁deploy/app21及相关的pvc、pv
```
## 删除deploy/app21
root@master01:~# kubectl -n binbin get deploy/app21
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
app21   2/2     2            2           9m36s
root@master01:~# 
root@master01:~# kubectl -n binbin delete deploy/app21
deployment.apps "app21" deleted

## 删除pvc/app21
root@master01:~# kubectl -n binbin get pvc/app21
NAME    STATUS   VOLUME              CAPACITY   ACCESS MODES   STORAGECLASS                    AGE
app21   Bound    binbin-prod-app21   10Gi       RWX            binbin-project-prod-static-pv   13m
root@master01:~# 
root@master01:~# 
root@master01:~# kubectl -n binbin delete pvc/app21
persistentvolumeclaim "app21" deleted
root@master01:~#

## 查看其pv是否还存在,是存在的，其回收策略之Delete在静态pv之nfs卷类型下不起作用，需要人为回收
root@master01:~# kubectl get pv/binbin-prod-app21
NAME                CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM          STORAGECLASS                    REASON   AGE
binbin-prod-app21   10Gi       RWX            Delete           Failed   binbin/app21   binbin-project-prod-static-pv            26m
  #
  # STATUS
  #   Failed
  #

## 现在不人为回收，我再把pvc/app21给创建出来，是无法再匹配到 pv/binbin-prod-app21 对象的
root@master01:~# kubectl apply -f 03.binbin-project/app21/02.pvc_app21.yaml 
persistentvolumeclaim/app21 created
root@master01:~#
root@master01:~# kubectl get -f 03.binbin-project/app21/02.pvc_app21.yaml 
NAME    STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS                    AGE
app21   Pending                                      binbin-project-prod-static-pv   23s


## 删除pvc/app21、pv/binbin-prod-app21对象
# <-- 删除pvc/app21
root@master01:~# kubectl get -f 03.binbin-project/app21/02.pvc_app21.yaml 
NAME    STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS                    AGE
app21   Pending                                      binbin-project-prod-static-pv   59s
root@master01:~#
root@master01:~# kubectl delete -f 03.binbin-project/app21/02.pvc_app21.yaml 
persistentvolumeclaim "app21" deleted

# <-- 删除pv/binbin-prod-app21
root@master01:~# kubectl get -f 03.binbin-project/app21/01.pv_binbin-prod-app21.yaml 
NAME                CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM          STORAGECLASS                    REASON   AGE
binbin-prod-app21   10Gi       RWX            Delete           Failed   binbin/app21   binbin-project-prod-static-pv            30m
root@master01:~#
root@master01:~# kubectl delete -f 03.binbin-project/app21/01.pv_binbin-prod-app21.yaml 
persistentvolume "binbin-prod-app21" deleted
```

重建deploy/app21及相关的pvc、pv，再到相关Pod副本的相关容器查看之前的数据，是还在的
```
## 应用manifests
root@master01:~# kubectl apply -f 03.binbin-project/app21/
persistentvolume/binbin-prod-app21 created
persistentvolumeclaim/app21 created
deployment.apps/app21 created

## 列出相关资源对象
root@master01:~# kubectl get pv/binbin-prod-app21
NAME                CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM          STORAGECLASS                    REASON   AGE
binbin-prod-app21   10Gi       RWX            Delete           Bound    binbin/app21   binbin-project-prod-static-pv            58s
root@master01:~#
root@master01:~# kubectl -n binbin get pvc/app21
NAME    STATUS   VOLUME              CAPACITY   ACCESS MODES   STORAGECLASS                    AGE
app21   Bound    binbin-prod-app21   10Gi       RWX            binbin-project-prod-static-pv   69s
root@master01:~#
root@master01:~# kubectl -n binbin get deploy/app21
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
app21   2/2     2            2           109s
root@master01:~#
root@master01:~# kubectl -n binbin get pods -o wide | grep $( kubectl -n binbin describe deploy/app21 | grep "NewReplicaSet:" | cut -d " " -f4)
app21-68598fc86d-4z488   2/2     Running   0          2m43s   10.0.4.26   node02   <none>           <none>
app21-68598fc86d-dcnwv   2/2     Running   0          2m43s   10.0.3.23   node01   <none>           <none>

## 相关Pod副本里面的相关容器查看之前的数据是否还在，数据是在的。
root@master01:~# kubectl -n binbin exec -it pods/app21-68598fc86d-dcnwv  -c app21 -- ls -l /data/
total 0
-rw-r--r--    1 root     root             0 Aug 17 11:42 app21-container.txt
-rw-r--r--    1 root     root             0 Aug 17 11:43 sidecar-container.txt
root@master01:~# 
root@master01:~# 
root@master01:~# kubectl -n binbin exec -it pods/app21-68598fc86d-dcnwv  -c sidecar -- ls -l /data/
total 0
-rw-r--r--    1 root     root             0 Aug 17 11:42 app21-container.txt
-rw-r--r--    1 root     root             0 Aug 17 11:43 sidecar-container.txt
```

# 4 binbin项目的app22应用
```
实践参考 "3 binbin项目的app21应用"
```

# 5 清理环境
```
kubectl delete -f 03.binbin-project/app21/

kubectl delete -f 03.binbin-project/app22/
```
