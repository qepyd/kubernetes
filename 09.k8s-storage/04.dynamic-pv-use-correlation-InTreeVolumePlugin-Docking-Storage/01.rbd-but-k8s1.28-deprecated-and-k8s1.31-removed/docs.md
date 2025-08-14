# 1 存储系统ceph中的准备
参考 ./01.storage-admin/ceph-storage-create-rbd-and-user-and-rbdimage.md

# 2 k8s-admin相关
参考 ./02.k8s-admin/k8s-control-plane-and-worker-node-install-ceph-common.md

# 3 实践
## 3.1 相关目录
```
root@node01:~# tree 03.lanlan-project/
03.lanlan-project/
├── app11
│   ├── 01.pvc_app11.yaml
│   └── 02.pods_app11.yaml
├── app12
│   ├── 01.pvc_app12.yaml
│   └── 02.pods_app12.yaml
├── sc_lanlan-project-rbd-sc
│   └── sc_lanlan-project-rbd-sc.yaml
└── secrets_lanlan-project-ceph-rbd-in-lanlanrbd-user-key
    ├── ceph.client.lanlanrbd.secret
    ├── command.sh
    └── secrets_lanlan-project-ceph-rbd-in-lanlanrbd-user-key.yaml

4 directories, 8 files
```
## 3.2 创建sc/lanlan-project-ceph-rbd-in-lanlanrbd-user-key对象
会被sc/lanlan-project-rbd-sc引用
```
root@master01:~# kubectl apply -f 03.lanlan-project/secrets_lanlan-project-ceph-rbd-in-lanlanrbd-user-key/
secret/lanlan-project-ceph-rbd-in-lanlanrbd-user-key created
```

## 3.3 创建sc/lanlan-project-rbd-sc对象
```
root@master01:~# kubectl apply -f 03.lanlan-project/sc_lanlan-project-rbd-sc/
storageclass.storage.k8s.io/lanlan-project-rbd-sc created
root@master01:~# 
root@master01:~# kubectl get sc/lanlan-project-rbd-sc
NAME                    PROVISIONER         RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
lanlan-project-rbd-sc   kubernetes.io/rbd   Delete          Immediate           false                  47s
  #
  # 制备器为kubernetes.io/rbd的sc资源对象,不要指定sc.reclaimPolicy字段,不然pvc的需求过来后,无法创建动态pv,
  # pvc资源对象的信息中会看到报错信息：invalid option "reclaimPolicy" for volume plugin kubernetes.io/rbd。
  # 
  # 制备器kubernetes.io/rbd对卷的回收策略为Delete,所创建出来的pv资源会继承其回收策略Delete。
  #   当与pv绑定的pvc资源被删除后,pv会自动回收,且存储中的相应pool中的image会被删除，数据会丢失。
  #
```

## 3.4 app11应用
创建pvc/app11对象，会创建出pv资源对象,会在存储系统中创建相关pool中创建image
```
## 创建pvc/app11对象
root@master01:~# kubectl apply -f 03.lanlan-project/app11/01.pvc_app11.yaml 
persistentvolumeclaim/app11 created
root@master01:~#
root@master01:~# kubectl -n lanlan get pvc/app11
NAME    STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS            AGE
app11   Bound    pvc-3cab03ed-3e8b-40bc-a376-814f28ca8eb4   5Gi        RWO            lanlan-project-rbd-sc   7s

## 列出其绑定的pv
root@master01:~# kubectl get pv/pvc-3cab03ed-3e8b-40bc-a376-814f28ca8eb4
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM          STORAGECLASS            REASON   AGE
pvc-3cab03ed-3e8b-40bc-a376-814f28ca8eb4   5Gi        RWO            Delete           Bound    lanlan/app11   lanlan-project-rbd-sc            39s

## 列出ceph集群中其rbd-lanlan-project-data存储池中所有的image
admin@ceph-mon01:~$ rbd ls -l --pool rbd-lanlan-project-data
NAME                                                         SIZE   PARENT  FMT  PROT  LOCK
kubernetes-dynamic-pvc-c61a99bb-c63e-4ea4-98d6-e2294460cc48  5 GiB            2 
```

创建pods/app11对象,到其所在worker node上查看磁盘的挂载
```
## 创建pods/app11对象
root@master01:~# kubectl apply -f 03.lanlan-project/app11/02.pods_app11.yaml 
pod/app11 created
root@master01:~#
root@master01:~# kubectl -n lanlan get pods/app11 -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
app11   2/2     Running   0          29s   10.0.4.10   node02   <none>           <none>

## 查看pods/app11对象的uid
root@master01:~# kubectl -n lanlan get pods/app11 -o json | jq ".metadata.uid"
"553a95d7-93c3-4445-9cc7-f79c3244c8a4"

## 到node02这个worker node上查看相关挂载
root@node02:~# df -h | grep 553a95d7-93c3-4445-9cc7-f79c3244c8a4
tmpfs           3.6G   12K  3.6G   1% /var/lib/kubelet/pods/553a95d7-93c3-4445-9cc7-f79c3244c8a4/volumes/kubernetes.io~projected/kube-api-access-zt7s7
/dev/rbd0       4.9G   24K  4.9G   1% /var/lib/kubelet/pods/553a95d7-93c3-4445-9cc7-f79c3244c8a4/volumes/kubernetes.io~rbd/pvc-3cab03ed-3e8b-40bc-a376-814f28ca8eb4
   #
   # 可看到其pv/pvc-3cab03ed-3e8b-40bc-a376-814f28ca8eb4
   #
```

删除pods/app11、pvc/app11，其pv会被回收，且ceph中的数据也会丢失。
```
## 删除pods/app11
root@master01:~# kubectl -n lanlan get pods/app11
NAME    READY   STATUS    RESTARTS   AGE
app11   2/2     Running   0          4m3s
root@master01:~#
root@master01:~# kubectl -n lanlan delete pods/app11
pod "app11" deleted

## 删除pvc/app11
root@master01:~#  kubectl -n lanlan get pvc/app11
NAME    STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS            AGE
app11   Bound    pvc-3cab03ed-3e8b-40bc-a376-814f28ca8eb4   5Gi        RWO            lanlan-project-rbd-sc   8m4s
root@master01:~#
root@master01:~# kubectl -n lanlan delete pvc/app11
persistentvolumeclaim "app11" deleted

## 之前的pv/pvc-3cab03ed-3e8b-40bc-a376-814f28ca8eb4对象也没有了
root@master01:~# kubect get pv/pvc-3cab03ed-3e8b-40bc-a376-814f28ca8eb4
Error from server (NotFound): persistentvolumes "pvc-3cab03ed-3e8b-40bc-a376-814f28ca8eb4" not foundlumes "pvc-3cab03ed-3e8b-40bc-a376-814f28ca8eb4对" not found

## 列出ceph集群中其rbd-lanlan-project-data存储池中所有的image，
#  可看到 kubernetes-dynamic-pvc-c61a99bb-c63e-4ea4-98d6-e2294460cc48 image不存在了
#  数据丢失了
admin@ceph-mon01:~$ rbd ls -l --pool rbd-lanlan-project-data
admin@ceph-mon01:~$ 
```

## 3.5 app12应用
参考 3.4 app11应用 

