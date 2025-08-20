# 1 相关资源对象的manifests
```
root@master01:~# ./
├── 01.sc_jmsco-ceph-csi-cephfs
│   ├── sc_Delete_jmsco-ceph-csi-cephfs.yaml
│   └── sc_Retain_jmsco-ceph-csi-cephfs.yaml
├── 02.sc_jmsco-ceph-csi-rbd
│   ├── sc_Delete_jmsco-ceph-csi-rbd.yaml
│   └── sc_Retain_jmsco-ceph-csi-rbd.yaml
├── 03.jmsco-project
│   ├── app71-cephfs
│   │   ├── 01.pvc_app71-data.yaml
│   │   └── 02.deploy_app71.yaml
│   ├── app72-cephfs
│   │   ├── 01.pvc_app72-data.yaml
│   │   └── 02.deploy_app72.yaml
│   ├── app73-rbd
│   │   ├── 01.pvc_app73-data.yaml
│   │   └── 02.pods_app73.yaml
│   └── app74-rbd
│       ├── 01.pvc_app74-data.yaml
│       └── 02.pods_app74.yaml
├── README.md
└── docs.md

7 directories, 14 files
```

# 2 回收策略为Delete的动态pv在ceph集群中相关fs的csi subvolumegroup中创建subvolume,配合app71应用实践
创建sc/jmsco-ceph-csi-cephfs资源对象，其回收策略为Delete(不支持在线更改)
```
## 创建
root@master01:~# kubectl apply -f 01.sc_jmsco-ceph-csi-cephfs/sc_Delete_jmsco-ceph-csi-cephfs.yaml --dry-run=client
storageclass.storage.k8s.io/jmsco-ceph-csi-cephfs configured (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 01.sc_jmsco-ceph-csi-cephfs/sc_Delete_jmsco-ceph-csi-cephfs.yaml
storageclass.storage.k8s.io/jmsco-ceph-csi-cephfs created

## 列出相关资源对象
root@master01:~# kubectl -n jmsco get sc/jmsco-ceph-csi-cephfs
NAME                    PROVISIONER           RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
jmsco-ceph-csi-cephfs   cephfs.csi.ceph.com   Delete          Immediate           true                   36s
  #
  # 其回收策略为Delete，动态pv会继承它
  # 当删除与动态pv绑定的pvc后，自动回收pv，pv对接的ceph集群中相关fs volume中的subvolume也会被删除
  # 
  # 注意：此时还没有相应的动态pv出来,需要创建相应的pvc资源对象。
  # 
```

创建app71应用的pvc/app71-data
```
## 创建pvc/app71-data对象
root@master01:~# kubectl apply -f 03.jmsco-project/app71-cephfs/01.pvc_app71-data.yaml --dry-run=client
persistentvolumeclaim/app71-data created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.jmsco-project/app71-cephfs/01.pvc_app71-data.yaml
persistentvolumeclaim/app71-data created

## 列出pvc/app71-data对象
root@master01:~# kubectl -n jmsco get pvc/app71-data
NAME         STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS            AGE
app71-data   Bound    pvc-c42860c9-5bfb-4e0d-9550-fe49bba166f0   5Gi        RWX            jmsco-ceph-csi-cephfs   42s
   #
   # 其与pv/pvc-c42860c9-5bfb-4e0d-9550-fe49bba166f0进行了绑定(Bound)，
   # 其STORAGECLASS是jmsco-ceph-csi-cephfs(这是在前面创建的sc资源对象)
   #

## 查看其动态pv/pvc-c42860c9-5bfb-4e0d-9550-fe49bba166f0
# <-- 列出
root@master01:~# kubectl get pv/pvc-c42860c9-5bfb-4e0d-9550-fe49bba166f0
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM              STORAGECLASS            REASON   AGE
pvc-c42860c9-5bfb-4e0d-9550-fe49bba166f0   5Gi        RWX            Delete           Bound    jmsco/app71-data   jmsco-ceph-csi-cephfs            2m47s

# <-- 查看描述信息，其source.VolumeAttributes.subvolumePath就是动态pv在ceph集群相关pool中创建的subvolume
root@master01:~# kubectl describe pv/pvc-c42860c9-5bfb-4e0d-9550-fe49bba166f0 
Name:            pvc-c42860c9-5bfb-4e0d-9550-fe49bba166f0
Labels:          <none>
Annotations:     pv.kubernetes.io/provisioned-by: cephfs.csi.ceph.com
                 volume.kubernetes.io/provisioner-deletion-secret-name: jmsco-project-ceph-fs-in-jmscofs-user-key
                 volume.kubernetes.io/provisioner-deletion-secret-namespace: jmsco
Finalizers:      [external-provisioner.volume.kubernetes.io/finalizer kubernetes.io/pv-protection]
StorageClass:    jmsco-ceph-csi-cephfs
Status:          Bound
Claim:           jmsco/app71-data
Reclaim Policy:  Delete
Access Modes:    RWX
VolumeMode:      Filesystem
Capacity:        5Gi
Node Affinity:   <none>
Message:         
Source:
    Type:              CSI (a Container Storage Interface (CSI) volume source)
    Driver:            cephfs.csi.ceph.com
    FSType:            
    VolumeHandle:      0001-0024-2004f705-b556-4d05-9e73-7884379e07bb-0000000000000003-a9158b8b-e30d-4746-8fcd-b8ab1c2d09e9
    ReadOnly:          false
    VolumeAttributes:      clusterID=2004f705-b556-4d05-9e73-7884379e07bb                                                                   # 看这
                           fsName=jmsco                                                                                                     # 看这
                           pool=cephfs-jmsco-project-data                                                                                   # 看这
                           storage.kubernetes.io/csiProvisionerIdentity=1755685977281-7282-cephfs.csi.ceph.com
                           subvolumeName=csi-vol-a9158b8b-e30d-4746-8fcd-b8ab1c2d09e9
                           subvolumePath=/volumes/csi/csi-vol-a9158b8b-e30d-4746-8fcd-b8ab1c2d09e9/8dc6e8fd-b0f3-41b6-99a8-de2323c15ca4     # 看这
Events:                <none>
```

到ceph集群中其jmsco fs的csi subvolumegroup中查看subvolume
```
root@ceph-mon01:~# ceph fs subvolume ls  jmsco  csi
[
    {
        "name": "csi-vol-a9158b8b-e30d-4746-8fcd-b8ab1c2d09e9"
    }
]
```

删除pvc/app71-data资源对象，会回收其绑定的动态pv资源对象，会删除动态pv在ceph集群中创建的fs subvolume。数据丢失。
```
## 删除pvc/app71-data资源对象
root@master01:~# kubectl -n jmsco get pvc/app71-data
NAME         STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS            AGE
app71-data   Bound    pvc-c42860c9-5bfb-4e0d-9550-fe49bba166f0   5Gi        RWX            jmsco-ceph-csi-cephfs   9m4s
root@master01:~#
root@master01:~# kubectl -n jmsco delete pvc/app71-data
persistentvolumeclaim "app71-data" deleted

## 查看pvc/app71-data资源对象其之前绑定的动态pv是否还在,肯定是不在的
root@master01:~# kubectl get pv/pvc-c42860c9-5bfb-4e0d-9550-fe49bba166f0
Error from server (NotFound): persistentvolumes "pvc-c42860c9-5bfb-4e0d-9550-fe49bba166f0" not found

## 到ceph集群中其jmsco fs的csi subvolumegroup中查看相应subvolume是否还在，肯定是不在的
root@ceph-mon01:~# ceph fs subvolume ls  jmsco  csi
[]
root@ceph-mon01:~# 
```

前面已知的是数据丢失的，这里把app71应用完整运行起来看看pod是否能够处于Running状态
```
## 部署app71应用
root@ceph-mon01:~# kubectl apply -f 03.jmsco-project/app71-cephfs/ --dry-run=client
persistentvolumeclaim/app71-data created (dry run)
deployment.apps/app71 created (dry run)
root@ceph-mon01:~#
root@ceph-mon01:~# 
root@ceph-mon01:~# kubectl apply -f 03.jmsco-project/app71-cephfs/
persistentvolumeclaim/app71-data created
deployment.apps/app71 created

## 列出相关资源对象
root@ceph-mon01:~#  kubectl get -f 03.jmsco-project/app71-cephfs/
NAME                               STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS            AGE
persistentvolumeclaim/app71-data   Bound    pvc-ab7e0a76-08b0-4cfc-9506-8eed5f46c56a   5Gi        RWX            jmsco-ceph-csi-cephfs   36s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/app71   2/2     2            2           36s


## 列出相关pods资源对象
root@master01:~# kubectl -n jmsco get pods -o wide | grep $(kubectl -n jmsco describe deploy/app71 | grep "NewReplicaSet:" | cut -d " " -f 4)
app71-5b87bf44c-xmckd   2/2     Running   0          113s   10.0.4.36   node02   <none>           <none>
app71-5b87bf44c-z5csn   2/2     Running   0          113s   10.0.3.38   node01   <none>           <none>

## 到某Pod副本所在worker node上查看其相关的挂载
# <-- 查看其uid
root@master01:~# kubectl -n jmsco get pods/app71-5b87bf44c-z5csn -o json | jq ".metadata.uid"
"da2bfbab-49f5-49a5-97f9-c7d274cda818"

# <-- 到所在worker node查看其相关的挂载
root@node01:~# df -h | grep da2bfbab-49f5-49a5-97f9-c7d274cda818
tmpfs                                                                                                                                                 7.7G   12K  7.7G   1% /var/lib/kubelet/pods/da2bfbab-49f5-49a5-97f9-c7d274cda818/volumes/kubernetes.io~projected/kube-api-access-qqfnv
172.31.8.201:6789,172.31.8.202:6789,172.31.8.203:6789:/volumes/csi/csi-vol-cfba37a0-4b52-4665-aca5-0dacc11cd859/36a4bfdd-b5a2-4f89-bbac-883a48143b64  5.0G     0  5.0G   0% /var/lib/kubelet/pods/da2bfbab-49f5-49a5-97f9-c7d274cda818/volumes/kubernetes.io~csi/pvc-ab7e0a76-08b0-4cfc-9506-8eed5f46c56a/mount
```

清理环境
```
kubectl delete -f 03.jmsco-project/app71-cephfs/
kubectl delete -f 01.sc_jmsco-ceph-csi-cephfs/sc_Delete_jmsco-ceph-csi-cephfs.yaml
```


# 3 回收策略为Retain的动态pv在ceph集群中相关fs的csi subvolumegroup中创建subvolume,配合app72应用实践
创建sc/jmsco-ceph-csi-cephfs资源,其回收策略为Retain(不支持在线更改)
```
## 创建
root@node01:~# kubectl apply -f 01.sc_jmsco-ceph-csi-cephfs/sc_Retain_jmsco-ceph-csi-cephfs.yaml --dry-run=client
storageclass.storage.k8s.io/jmsco-ceph-csi-cephfs created (dry run)
root@node01:~#
root@node01:~# kubectl apply -f 01.sc_jmsco-ceph-csi-cephfs/sc_Retain_jmsco-ceph-csi-cephfs.yaml
storageclass.storage.k8s.io/jmsco-ceph-csi-cephfs created

## 列出
root@master01:~# kubectl -n jmsco get sc/jmsco-ceph-csi-cephfs
NAME                    PROVISIONER           RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
jmsco-ceph-csi-cephfs   cephfs.csi.ceph.com   Retain          Immediate           true                   46s
   #
   # 其回收策略是Retain，动态pv会继承
   # 当删除与动态pv绑定的pvc后，不会自动回收动态pv。
   # 当人为回收动态pv，是不会删除动态pv在ceph中相关fs volume的csi subvolumegroup中所创建的subvolume
   # 
   # 但是：当再重新创建pvc资源对象后，又会产生new 动态pv(又会在ceph中相关fs volume的csi subvolumegroup中创建new subvolume)
   #  
```

创建app71应用的pvc/app72-data
```
## 创建pvc/app72-data对象
root@master01:~# kubectl apply -f 03.jmsco-project/app72-cephfs/01.pvc_app72-data.yaml  --dry-run=client
persistentvolumeclaim/app72-data created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.jmsco-project/app72-cephfs/01.pvc_app72-data.yaml  
persistentvolumeclaim/app72-data created

## 列出pvc/app72-data对象
root@master01:~# kubectl -n jmsco get pvc/app72-data
NAME         STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS            AGE
app72-data   Bound    pvc-07e3c8f1-8d93-45e4-924e-3b7905dfa410   5Gi        RWX            jmsco-ceph-csi-cephfs   44s
  #
  # 可看出其已经和动态pv/pvc-07e3c8f1-8d93-45e4-924e-3b7905dfa410进行了绑定。
  # 为什么说是动态pv呢，因为STORAGECLASS字段处的jmsco-ceph-csi-cephfs是我们前面创建的一个sc资源对象
  #

## 查看其动态pv/pvc-07e3c8f1-8d93-45e4-924e-3b7905dfa410
# <-- 列出
root@master01:~# kubectl get pv/pvc-07e3c8f1-8d93-45e4-924e-3b7905dfa410
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM              STORAGECLASS            REASON   AGE
pvc-07e3c8f1-8d93-45e4-924e-3b7905dfa410   5Gi        RWX            Retain           Bound    jmsco/app72-data   jmsco-ceph-csi-cephfs            2m11s

# <-- 查看描述信息，其source.VolumeAttributes.subvolumePath就是动态pv在ceph集群相关pool中创建的subvolume
root@master01:~# kubectl describe pv/pvc-07e3c8f1-8d93-45e4-924e-3b7905dfa410
Name:            pvc-07e3c8f1-8d93-45e4-924e-3b7905dfa410
Labels:          <none>
Annotations:     pv.kubernetes.io/provisioned-by: cephfs.csi.ceph.com
                 volume.kubernetes.io/provisioner-deletion-secret-name: jmsco-project-ceph-fs-in-jmscofs-user-key
                 volume.kubernetes.io/provisioner-deletion-secret-namespace: jmsco
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:    jmsco-ceph-csi-cephfs
Status:          Bound
Claim:           jmsco/app72-data
Reclaim Policy:  Retain
Access Modes:    RWX
VolumeMode:      Filesystem
Capacity:        5Gi
Node Affinity:   <none>
Message:         
Source:
    Type:              CSI (a Container Storage Interface (CSI) volume source)
    Driver:            cephfs.csi.ceph.com
    FSType:            
    VolumeHandle:      0001-0024-2004f705-b556-4d05-9e73-7884379e07bb-0000000000000003-117cb34e-a9be-4c43-9861-1867269dc4ac
    ReadOnly:          false
    VolumeAttributes:      clusterID=2004f705-b556-4d05-9e73-7884379e07bb                                                                # 看这
                           fsName=jmsco                                                                                                  # 看这
                           pool=cephfs-jmsco-project-data                                                                                # 看这
                           storage.kubernetes.io/csiProvisionerIdentity=1755685977281-7282-cephfs.csi.ceph.com  
                           subvolumeName=csi-vol-117cb34e-a9be-4c43-9861-1867269dc4ac                                                    # 看这
                           subvolumePath=/volumes/csi/csi-vol-117cb34e-a9be-4c43-9861-1867269dc4ac/042bc86f-a070-4228-822c-5600af8426c1  # 看这
Events:                <none>
```

到ceph集群中其jmsco fs的csi subvolumegroup中查看subvolume
```
root@ceph-mon01:~# ceph fs subvolume ls  jmsco  csi
[
    {
        "name": "csi-vol-117cb34e-a9be-4c43-9861-1867269dc4ac"
    }
]
```

删除pvc/app72-data资源对象，不会自动回收其绑定的动态pv资源对象。人为回收，不会删除动态pv在ceph集群中创建的fs subvolume。数据不丢失。
```
## 删除pvc/app72-data资源对象
root@master01:~# kubectl -n jmsco get pvc/app72-data
NAME         STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS            AGE
app72-data   Bound    pvc-07e3c8f1-8d93-45e4-924e-3b7905dfa410   5Gi        RWX            jmsco-ceph-csi-cephfs   5m23s
root@master01:~# 
root@master01:~# kubectl -n jmsco delete pvc/app72-data
persistentvolumeclaim "app72-data" deleted

## 查看pvc/app72-data资源对象其之前绑定的动态pv是否还在,是还在的
root@master01:~# kubectl get pv/pvc-07e3c8f1-8d93-45e4-924e-3b7905dfa410
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM              STORAGECLASS            REASON   AGE
pvc-07e3c8f1-8d93-45e4-924e-3b7905dfa410   5Gi        RWX            Retain           Released   jmsco/app72-data   jmsco-ceph-csi-cephfs            6m6s
  #
  # 若此时重建创建pvc/app72-data，会绑定new 动态pv，而不是此处的这个pv资源对象。
  #

## 人为回收pv/pvc-07e3c8f1-8d93-45e4-924e-3b7905dfa410
root@master01:~# kubectl delete pv/pvc-07e3c8f1-8d93-45e4-924e-3b7905dfa410
persistentvolume "pvc-07e3c8f1-8d93-45e4-924e-3b7905dfa410" deleted


## 到ceph集群中其jmsco fs的csi subvolumegroup中查看相应subvolume是否还在，结果是还在的
root@ceph-mon01:~# ceph fs subvolume ls  jmsco  csi
[
    {
        "name": "csi-vol-117cb34e-a9be-4c43-9861-1867269dc4ac"
    }
]
```

重新创建pvc/app72-data对象，会绑定new 动态pv(又会在ceph中创建new subvolume)，之前的数据得不到复用。
```
## 创建pvc/app72-data对象，并列出
root@master01:~# kubectl apply -f 03.jmsco-project/app72-cephfs/01.pvc_app72-data.yaml 
persistentvolumeclaim/app72-data created
root@master01:~#
root@master01:~# kubectl -n jmsco get pvc/app72-data
NAME         STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS            AGE
app72-data   Bound    pvc-32336363-4911-4e28-9e98-16e622c59694   5Gi        RWX            jmsco-ceph-csi-cephfs   31s

## 查看其绑定的动态pv/pvc-32336363-4911-4e28-9e98-16e622c59694其详细信息
root@master01:~# kubectl describe pv/pvc-32336363-4911-4e28-9e98-16e622c59694
Name:            pvc-32336363-4911-4e28-9e98-16e622c59694
Labels:          <none>
Annotations:     pv.kubernetes.io/provisioned-by: cephfs.csi.ceph.com
                 volume.kubernetes.io/provisioner-deletion-secret-name: jmsco-project-ceph-fs-in-jmscofs-user-key
                 volume.kubernetes.io/provisioner-deletion-secret-namespace: jmsco
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:    jmsco-ceph-csi-cephfs
Status:          Bound
Claim:           jmsco/app72-data
Reclaim Policy:  Retain
Access Modes:    RWX
VolumeMode:      Filesystem
Capacity:        5Gi
Node Affinity:   <none>
Message:         
Source:
    Type:              CSI (a Container Storage Interface (CSI) volume source)
    Driver:            cephfs.csi.ceph.com
    FSType:            
    VolumeHandle:      0001-0024-2004f705-b556-4d05-9e73-7884379e07bb-0000000000000003-f54c4141-dcdc-471d-8080-dc33ed6c3e95
    ReadOnly:          false
    VolumeAttributes:      clusterID=2004f705-b556-4d05-9e73-7884379e07bb                                                                # 看这
                           fsName=jmsco                                                                                                  # 看这
                           pool=cephfs-jmsco-project-data                                                                                # 看这
                           storage.kubernetes.io/csiProvisionerIdentity=1755685977281-7282-cephfs.csi.ceph.com
                           subvolumeName=csi-vol-f54c4141-dcdc-471d-8080-dc33ed6c3e95                                                    # 看这
                           subvolumePath=/volumes/csi/csi-vol-f54c4141-dcdc-471d-8080-dc33ed6c3e95/79aeb770-b271-4def-a699-b7b23f2b0512  # 看这
Events:                <none>

## 到ceph集群中查看相关的subvolume
root@ceph-mon01:~# ceph fs subvolume ls  jmsco  csi
[
    {
        "name": "csi-vol-117cb34e-a9be-4c43-9861-1867269dc4ac"                # 这是之前的
    },
    {
        "name": "csi-vol-f54c4141-dcdc-471d-8080-dc33ed6c3e95"                # 这是刚刚的
    }
]
```

前面已知的是数据是不会丢失，但无法复用。这里把app72应用部署起来(就差创建deploy/app72对象了)
```
## 创建deploy/app72
root@ceph-mon01:~# kubectl apply -f 03.jmsco-project/app72-cephfs/ --dry-run=client
persistentvolumeclaim/app72-data configured (dry run)
deployment.apps/app72 created (dry run)
root@ceph-mon01:~#
root@ceph-mon01:~# kubectl apply -f 03.jmsco-project/app72-cephfs/
persistentvolumeclaim/app72-data unchanged
deployment.apps/app72 created

## 列出相关资源对象
root@ceph-mon01:~# kubectl get -f 03.jmsco-project/app72-cephfs/
NAME                               STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS            AGE
persistentvolumeclaim/app72-data   Bound    pvc-32336363-4911-4e28-9e98-16e622c59694   5Gi        RWX            jmsco-ceph-csi-cephfs   8m41s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/app72   2/2     2            2           36s


## 列出相关pod资源对象
root@master01:~# kubectl -n jmsco get pods -o wide | grep $(kubectl -n jmsco describe deploy/app72 | grep "NewReplicaSet:" | cut -d " " -f 4)
app72-7b658bb866-f6dpr   2/2     Running   0          69s   10.0.3.39   node01   <none>           <none>
app72-7b658bb866-fl9hn   2/2     Running   0          69s   10.0.4.37   node02   <none>           <none>

## 到某Pod副本所在worker node上查看其相关的挂载
# <-- 查看uid
root@master01:~# kubectl -n jmsco get pods/app72-7b658bb866-f6dpr -o json | jq ".metadata.uid"
"68859545-e45d-48a4-b9cf-5f075d73f355"

# <-- 到所在worker node查看其相关的挂载
root@node01:~# df -h | grep 68859545-e45d-48a4-b9cf-5f075d73f355
tmpfs                                                                                                                                                 7.7G   12K  7.7G   1% /var/lib/kubelet/pods/68859545-e45d-48a4-b9cf-5f075d73f355/volumes/kubernetes.io~projected/kube-api-access-t7r76
172.31.8.201:6789,172.31.8.202:6789,172.31.8.203:6789:/volumes/csi/csi-vol-f54c4141-dcdc-471d-8080-dc33ed6c3e95/79aeb770-b271-4def-a699-b7b23f2b0512  5.0G     0  5.0G   0% /var/lib/kubelet/pods/68859545-e45d-48a4-b9cf-5f075d73f355/volumes/kubernetes.io~csi/pvc-32336363-4911-4e28-9e98-16e622c59694/mount
```
