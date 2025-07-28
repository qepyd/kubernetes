# 1 csi-driver-nfs项目地址
```
https://github.com/kubernetes-csi/csi-driver-nfs
```

# 2 创建相关目录
```
mkdir 01.csi-node
mkdir 02.csi-controller
mkdir 03.csidrivers-storageclass 
```

# 3 下载相关的manifests
**相关manifests所在路径**
```
https://github.com/kubernetes-csi/csi-driver-nfs/tree/v4.7.0/deploy/v4.7.0
```

**下载 csi-node 相关的**
```
curl https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/refs/tags/v4.7.0/deploy/v4.7.0/rbac-csi-nfs.yaml  \
   -o ./01.csi-node/01.sa_csi-nfs-node-sa.yaml
   #
   # 下载后立即对 ./01.csi-node/01.sa_csi-nfs-node-sa.yaml 做修改。
   #    只保留 ServiceAccount/csi-nfs-node-sa 对象的manifests.
   #    其它的你可以将其注释掉。
   # 

curl https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/refs/tags/v4.7.0/deploy/v4.7.0/csi-nfs-node.yaml \
   -o ./01.csi-node/02.ds_csi-nfs-node.yaml
   #
   # 下载后，暂时不做任何的修改。
   # 
```

**下载 csi-controller相关的**
```
curl https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/refs/tags/v4.7.0/deploy/v4.7.0/rbac-csi-nfs.yaml \
   -o ./02.csi-controller/01.rbac_csi-nfs-controller-sa.yaml
   #
   # 下载后立即对 ./02.csi-controller/01.rbac_csi-nfs-controller-sa.yaml 做修改
   #   只注释 ServiceAccount/csi-nfs-node-sa 对象的manifests
   # 

curl https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/refs/tags/v4.7.0/deploy/v4.7.0/csi-nfs-controller.yaml \
   -o ./02.csi-controller/02.deploy_csi-nfs-controller.yaml
   #
   # 下载后，暂时不做任何的修改
   # 
```

**下载csidrivers、storageclass 资源对象的manifests**
```
curl https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/refs/tags/v4.7.0/deploy/v4.7.0/csi-nfs-driverinfo.yaml \
   -o ./03.csidrivers-storageclass/01.csidriver_nfs.csi.k8s.io.yaml
   #
   # 下载后，暂时不做任何的修改
   # 

curl https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/refs/tags/v4.7.0/deploy/v4.7.0/storageclass.yaml \
   -o ./03.csidrivers-storageclass/02.storageclass_nfs.csi.k8s.io.yaml
   #
   # 下载后，暂时不做任何的修改
   #
```

# 4 相关manifests的修改
**查看所用的namspace**
```
root@node01:~# grep "namespace:" 01.csi-node/*.yaml
01.csi-node/01.sa_csi-nfs-node-sa.yaml:#  namespace: kube-system
01.csi-node/01.sa_csi-nfs-node-sa.yaml:  namespace: kube-system
01.csi-node/01.sa_csi-nfs-node-sa.yaml:#    namespace: kube-system
01.csi-node/02.ds_csi-nfs-node.yaml:  namespace: kube-system
root@node01:~# grep "namespace:" 02.csi-controller/*.yaml
02.csi-controller/01.rbac_csi-nfs-controller-sa.yaml:  namespace: kube-system
02.csi-controller/01.rbac_csi-nfs-controller-sa.yaml:#  namespace: kube-system
02.csi-controller/01.rbac_csi-nfs-controller-sa.yaml:    namespace: kube-system
02.csi-controller/02.deploy_csi-nfs-controller.yaml:  namespace: kube-system
```

**修改image**
```
## 查看所用到的镜像
root@node01:~# grep "image:" 01.csi-node/*.yaml | sort
01.csi-node/02.ds_csi-nfs-node.yaml:          image: registry.k8s.io/sig-storage/csi-node-driver-registrar:v2.10.0
01.csi-node/02.ds_csi-nfs-node.yaml:          image: registry.k8s.io/sig-storage/livenessprobe:v2.12.0
01.csi-node/02.ds_csi-nfs-node.yaml:          image: registry.k8s.io/sig-storage/nfsplugin:v4.7.0

root@node01:~# grep "image:" 02.csi-controller/*.yaml | sort
02.csi-controller/02.deploy_csi-nfs-controller.yaml:          image: registry.k8s.io/sig-storage/csi-provisioner:v4.0.0
02.csi-controller/02.deploy_csi-nfs-controller.yaml:          image: registry.k8s.io/sig-storage/csi-snapshotter:v6.3.3
02.csi-controller/02.deploy_csi-nfs-controller.yaml:          image: registry.k8s.io/sig-storage/livenessprobe:v2.12.0
02.csi-controller/02.deploy_csi-nfs-controller.yaml:          image: registry.k8s.io/sig-storage/nfsplugin:v4.7.0

## 所用到的镜像为
registry.k8s.io/sig-storage/csi-node-driver-registrar:v2.10.0
registry.k8s.io/sig-storage/livenessprobe:v2.12.0
registry.k8s.io/sig-storage/nfsplugin:v4.7.0

registry.k8s.io/sig-storage/csi-provisioner:v4.0.0
registry.k8s.io/sig-storage/csi-snapshotter:v6.3.3


## 修改镜像
sed -i  's#registry.k8s.io/sig-storage/csi-node-driver-registrar:v2.10.0#swr.cn-north-1.myhuaweicloud.com/qepyd/sig-storage-csi-node-driver-registrar:v2.10.0#g'  01.csi-node/*.yaml
sed -i  's#registry.k8s.io/sig-storage/livenessprobe:v2.12.0#swr.cn-north-1.myhuaweicloud.com/qepyd/sig-storage-livenessprobe:v2.12.0#g'                          01.csi-node/*.yaml
sed -i  's#registry.k8s.io/sig-storage/nfsplugin:v4.7.0#swr.cn-north-1.myhuaweicloud.com/qepyd/sig-storage-nfsplugin:v4.7.0#g'                                    01.csi-node/*.yaml

sed -i  's#registry.k8s.io/sig-storage/csi-provisioner:v4.0.0#swr.cn-north-1.myhuaweicloud.com/qepyd/sig-storage-csi-provisioner:v4.0.0#g'                        02.csi-controller/*.yaml
sed -i  's#registry.k8s.io/sig-storage/csi-snapshotter:v6.3.3#swr.cn-north-1.myhuaweicloud.com/qepyd/sig-storage-csi-snapshotter:v6.3.3#g'                        02.csi-controller/*.yaml
sed -i  's#registry.k8s.io/sig-storage/livenessprobe:v2.12.0#swr.cn-north-1.myhuaweicloud.com/qepyd/sig-storage-livenessprobe:v2.12.0#g'                          02.csi-controller/*.yaml
sed -i  's#registry.k8s.io/sig-storage/nfsplugin:v4.7.0#swr.cn-north-1.myhuaweicloud.com/qepyd/sig-storage-nfsplugin:v4.7.0#g'                                    02.csi-controller/*.yaml
```

# 5 应用manifests
**应用manifests**
```
kubectl apply -f ./01.csi-node/ --dry-run=client
kubectl apply -f ./01.csi-node/

kubectl apply -f ./02.csi-controller/  --dry-run=client
kubectl apply -f ./02.csi-controller/ 

kubectl apply -f ./03.csidrivers-storageclass/ --dry-run=client
kubectl apply -f ./03.csidrivers-storageclass/
```

**列出关键资源**
```

```

