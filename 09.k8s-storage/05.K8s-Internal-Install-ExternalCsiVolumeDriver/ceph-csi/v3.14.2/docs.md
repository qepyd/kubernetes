# 1 ceph-csi其manifests的位置
```
https://github.com/ceph/ceph-csi/tree/v3.14.2/deploy
```

# 2 下载通用的相关资源对象其manifests
创建目录
```
mkdir 01.currency
ls -ld 01.currency
```

下载cm/ceph-config对象的manifests，并做相关的修改
https://github.com/ceph/ceph-csi/blob/v3.14.2/deploy/ceph-conf.yaml
```
## 下载manifests
wget https://raw.githubusercontent.com/ceph/ceph-csi/refs/tags/v3.14.2/deploy/ceph-conf.yaml   -O ./01.currency/cm_ceph-conf.yaml
   #
   # -O 表示指定下载路径及重命名
   # 
ls -l ./01.currency/cm_ceph-conf.yaml
cat   ./01.currency/cm_ceph-conf.yaml

## 修改manifests,主要是指定一下namespace为ceph-csi。
#  添加后的片段展示
root@master01:~# grep -A 2 "^metadata:" 01.currency/cm_ceph-conf.yaml 
metadata:
  namespace: ceph-csi
  name: ceph-config
```


创建cm/ceph-csi-config对象的manifests
参考：https://github.com/ceph/ceph-csi/blob/v3.14.2/deploy/csi-config-map-sample.yaml
```
cat >./01.currency/cm_ceph-csi-config.yaml<<'EOF'
---
apiVersion: v1
kind: ConfigMap
data:
  # <== clusterID字段和monitors字段的值,修改成你自己Ceph存储系统的相关值
  config.json: |-
    [
     {
      # ceph存储系统其集群ID,修改成自己的
      "clusterID": "2004f705-b556-4d05-9e73-7884379e07bb"
      # ceph存储系统其mon组件各实例的连接地址
      "monitors": [
        "172.31.8.201:6789",
        "172.31.8.202:6789",
        "172.31.8.203:6789"
        ]
      }
    ]
metadata:
  namespace: ceph-csi
  name: ceph-csi-config
EOF
```

# 3 部署cephfs的NodePlugin和CsiController
创建目录
```
mkdir 02.cephfs
ls -ld 02.cephfs
```

下载NodePlugin相关的manifests并修改
```
## 下载NodePlugin其rbac相关的manifests
#  https://github.com/ceph/ceph-csi/blob/v3.14.2/deploy/cephfs/kubernetes/csi-nodeplugin-rbac.yaml
wget https://raw.githubusercontent.com/ceph/ceph-csi/refs/tags/v3.14.2/deploy/cephfs/kubernetes/csi-nodeplugin-rbac.yaml -O ./02.cephfs/01-1.rbac-cephfs-csi-nodeplugin.yaml
ls -l   ./02.cephfs/01-1.rbac-cephfs-csi-nodeplugin.yaml
cat   ./02.cephfs/01-1.rbac-cephfs-csi-nodeplugin.yaml

## 修改NodePlugin其rbac相关的manifests
grep "namespace: default"  ./02.cephfs/01-1.rbac-cephfs-csi-nodeplugin.yaml
sed    's#namespace: default#namespace: ceph-csi#g'  ./02.cephfs/01-1.rbac-cephfs-csi-nodeplugin.yaml
sed -i 's#namespace: default#namespace: ceph-csi#g'  ./02.cephfs/01-1.rbac-cephfs-csi-nodeplugin.yaml

## 下载NodePlugin的manifests
#   https://github.com/ceph/ceph-csi/blob/v3.14.2/deploy/cephfs/kubernetes/csi-cephfsplugin.yaml
wget https://raw.githubusercontent.com/ceph/ceph-csi/refs/tags/v3.14.2/deploy/cephfs/kubernetes/csi-cephfsplugin.yaml -O ./02.cephfs/01-2.csi-cephfsplugin.yaml
ls -l ./02.cephfs/01-2.csi-cephfsplugin.yaml
cat   ./02.cephfs/01-2.csi-cephfsplugin.yaml

## 修改NodePlugin的manifests
# <-- 为ds/csi-cephfsplugin和svc/csi-metrics-cephfsplugin指定namespace为ceph-csi
.............................
.............................

# <-- 查看用到了哪些image
root@master01:~# grep "image:" 02.cephfs/01-2.csi-cephfsplugin.yaml 
          image: quay.io/cephcsi/cephcsi:v3.14.2
          image: registry.k8s.io/sig-storage/csi-node-driver-registrar:v2.13.0
          image: quay.io/cephcsi/cephcsi:v3.14.2

# <-- 说明
NodePlugin会在相关worker node上运行一个Pod副本,包含了CSI Plugin和Driver Reistrar。
其CSI Plugin     ： 由 quay.io/cephcsi/cephcsi:v3.14.2 来实现
其Driver Reistrar： 由 registry.k8s.io/sig-storage/csi-node-driver-registrar:v2.13.0 来实现
其worker node上的kubelet内置了VolumeManager和VolumePlugin(例如：csi)

# <-- 替换image,我已将相关image tag后推送到了我的私有image仓库中，并公开。
sed    's#quay.io/cephcsi/cephcsi:v3.14.2#swr.cn-north-1.myhuaweicloud.com/qepyd/cephcsi-cephcsi:v3.14.2#g'   02.cephfs/01-2.csi-cephfsplugin.yaml
sed -i 's#quay.io/cephcsi/cephcsi:v3.14.2#swr.cn-north-1.myhuaweicloud.com/qepyd/cephcsi-cephcsi:v3.14.2#g'   02.cephfs/01-2.csi-cephfsplugin.yaml


sed    's#registry.k8s.io/sig-storage/csi-node-driver-registrar:v2.13.0#swr.cn-north-1.myhuaweicloud.com/qepyd/sig-storage-csi-node-driver-registrar:v2.13.0#g'  02.cephfs/01-2.csi-cephfsplugin.yaml  
sed -i 's#registry.k8s.io/sig-storage/csi-node-driver-registrar:v2.13.0#swr.cn-north-1.myhuaweicloud.com/qepyd/sig-storage-csi-node-driver-registrar:v2.13.0#g'  02.cephfs/01-2.csi-cephfsplugin.yaml  

grep "image:" 02.cephfs/01-2.csi-cephfsplugin.yaml


## 修改ds/csi-cephfsplugin对象
将Pod级别的ceph-csi-encryption-kms-config 卷给注释掉
将容器级别引用 ceph-csi-encryption-kms-config 卷的挂载给注释掉
```


下载CsiController相关manifests并修改
```
## 下载CsiController其rbac相关的manifests
#  https://github.com/ceph/ceph-csi/blob/v3.14.2/deploy/cephfs/kubernetes/csi-provisioner-rbac.yaml
wget https://raw.githubusercontent.com/ceph/ceph-csi/refs/tags/v3.14.2/deploy/cephfs/kubernetes/csi-provisioner-rbac.yaml  -O  ./02.cephfs/02-1.rbac-csi-provisioner.yaml
ls -l ./02.cephfs/02-1.rbac-csi-provisioner.yaml
cat   ./02.cephfs/02-1.rbac-csi-provisioner.yaml

## 修改CsiController其rbac相关的manifests
grep "namespace: default"  ./02.cephfs/02-1.rbac-csi-provisioner.yaml
sed     's#namespace: default#namespace: ceph-csi#g'  ./02.cephfs/02-1.rbac-csi-provisioner.yaml  | grep "namespace: ceph-csi"
sed -i  's#namespace: default#namespace: ceph-csi#g'  ./02.cephfs/02-1.rbac-csi-provisioner.yaml


## 下载CsiController的manifests
#  https://github.com/ceph/ceph-csi/blob/v3.14.2/deploy/cephfs/kubernetes/csi-cephfsplugin-provisioner.yaml
wget https://raw.githubusercontent.com/ceph/ceph-csi/refs/tags/v3.14.2/deploy/cephfs/kubernetes/csi-cephfsplugin-provisioner.yaml  -O ./02.cephfs/02-2.csi-cephfsplugin-provisioner.yaml
ls -l ./02.cephfs/02-2.csi-cephfsplugin-provisioner.yaml
cat   ./02.cephfs/02-2.csi-cephfsplugin-provisioner.yaml

## 修改CsiController的manifests
# <-- 为svc/csi-cephfsplugin-provisioner、deploy/csi-cephfsplugin-provisioner对象指定namespace为ceph-csi
................................
...............................

# <-- 查看用到了哪些image
root@master01:~# grep "image:" ./02.cephfs/02-2.csi-cephfsplugin-provisioner.yaml | sort
          image: quay.io/cephcsi/cephcsi:v3.14.2
          image: quay.io/cephcsi/cephcsi:v3.14.2
          image: registry.k8s.io/sig-storage/csi-provisioner:v5.1.0
          image: registry.k8s.io/sig-storage/csi-resizer:v1.13.1
          image: registry.k8s.io/sig-storage/csi-snapshotter:v8.2.0

# <== 替换image,我已将相关image tag后推送到了我的私有image仓库中，并公开。
sed     's#quay.io/cephcsi/cephcsi:v3.14.2#swr.cn-north-1.myhuaweicloud.com/qepyd/cephcsi-cephcsi:v3.14.2#g'  ./02.cephfs/02-2.csi-cephfsplugin-provisioner.yaml
sed  -i 's#quay.io/cephcsi/cephcsi:v3.14.2#swr.cn-north-1.myhuaweicloud.com/qepyd/cephcsi-cephcsi:v3.14.2#g'  ./02.cephfs/02-2.csi-cephfsplugin-provisioner.yaml

sed     's#registry.k8s.io/sig-storage/csi-provisioner:v5.1.0#swr.cn-north-1.myhuaweicloud.com/qepyd/sig-storage-csi-provisioner:v5.1.0 #g'  ./02.cephfs/02-2.csi-cephfsplugin-provisioner.yaml
sed  -i 's#registry.k8s.io/sig-storage/csi-provisioner:v5.1.0#swr.cn-north-1.myhuaweicloud.com/qepyd/sig-storage-csi-provisioner:v5.1.0 #g'  ./02.cephfs/02-2.csi-cephfsplugin-provisioner.yaml

sed     's#registry.k8s.io/sig-storage/csi-resizer:v1.13.1#swr.cn-north-1.myhuaweicloud.com/qepyd/sig-storage-csi-resizer:v1.13.1#g'  ./02.cephfs/02-2.csi-cephfsplugin-provisioner.yaml
sed  -i 's#registry.k8s.io/sig-storage/csi-resizer:v1.13.1#swr.cn-north-1.myhuaweicloud.com/qepyd/sig-storage-csi-resizer:v1.13.1#g'  ./02.cephfs/02-2.csi-cephfsplugin-provisioner.yaml

sed     's#registry.k8s.io/sig-storage/csi-snapshotter:v8.2.0#swr.cn-north-1.myhuaweicloud.com/qepyd/sig-storage-csi-snapshotter:v8.2.0#g'  ./02.cephfs/02-2.csi-cephfsplugin-provisioner.yaml
sed  -i 's#registry.k8s.io/sig-storage/csi-snapshotter:v8.2.0#swr.cn-north-1.myhuaweicloud.com/qepyd/sig-storage-csi-snapshotter:v8.2.0#g'  ./02.cephfs/02-2.csi-cephfsplugin-provisioner.yaml

grep "image:" ./02.cephfs/02-2.csi-cephfsplugin-provisioner.yaml | sort


## 修改deploy/csi-cephfsplugin-provisioner对象
将Pod级别的 ceph-csi-encryption-kms-config 卷给注释掉
将容器级别引用 ceph-csi-encryption-kms-config 卷的挂载给注释掉
我将其副本数修改成1，它默认是3(表示可以多副本)。
   我的k8s其woker node有3个(1个是master01,上面有污点，另2个是运行业务的worker node)
   其manifests没有容忍master的污点。
   其manifests有Pod亲和性，会导致有一个Pod副本处于Pending状态
   所以我将副本数修改成1,当然我也可以修改成2.
```







