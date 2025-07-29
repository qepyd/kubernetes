# 1 卷类型(树内卷插件)
参考：https://kubernetes.io/zh-cn/docs/concepts/storage/volumes/#volume-types
参考：kubectl explain pods.spec.volumes
从官网可以看到有些卷类型已标记为弃用（将来会移除）、有些已移除。  
这些类类型由kubernetes提供，所以也称为树内（in-tree）卷插件。
```
特殊卷类型
  configMap
    #
    # 此树内卷插件对接的存储为configmaps资源对象。
    # configmaps资源对象中的数据(键值对)是放在kube-apiserver的后端存储之etcd中的。
    #
  secret
    # 
    # 此树内卷插件对接的存储为secrets资源对象。
    # configmaps资源对象中的数据(键值对)是放在kube-apiserver的后端存储之etcd中的。
    #
  downwardAPI
    #
    # 此树内卷插件对接的存储为自身所在Pod。用于获取Pod级别、容器级别相关信息(字段)。
    # Pod的实际状态数据是存放在kube-apiserver的后端存储之etcd中的。
    # 
  projected
    #
    # 此树内卷插件可以将若干现有的卷源进行映射/投射。
    #  configmaps、secrets、downwardAPI、serviceAccountToken、clusterTrustBundle
    #  
  persistentVolumeClaim
    # 
    # 此树内卷插件对接的存储为persistentvolumeclaims（简写pvc）资源对象。
    # pvc资源对象的实际状态数据是存放在kube-apiserver的后端存储之etcd中的
    #

临时卷类型
  emptyDir

本地卷类型
  local
  hostPath

网络存储卷类型
  文件系统：nfs、glusterfs、cephfs、cinder
  块 设 备：iscsi、fc、rbd、vsphereVolume
  存储平台：quobyte、portworxVolume、storageos、scaleIO
  云 存 储：awsElasticBlockStore、gcePersistentDisk、azureFile、azureDisk

扩展接口(为了对接"外部卷驱动程序"而准备的树内插件)
  flexVolume
  csi
```


# 2 持久卷申领、持久卷、存储类










