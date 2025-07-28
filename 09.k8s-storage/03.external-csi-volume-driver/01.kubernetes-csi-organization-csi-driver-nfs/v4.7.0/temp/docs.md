# 1 csi-driver-nfs项目地址
```
https://github.com/kubernetes-csi/csi-driver-nfs
```

# 2 创建相关目录
```
mkdir 01.csi-node
mkdir 02.csi-controller
mkdir 03.csidrivers-resources-object
```

# 2 下载相关的manifests
**下载csi-node相关的**
```
wget https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/refs/tags/v4.7.0/deploy/v4.7.0/rbac-csi-nfs.yaml 
```
