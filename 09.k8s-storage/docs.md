# 1 卷类型(树内卷插件)
官方参考：https://kubernetes.io/zh-cn/docs/concepts/storage/volumes/#volume-types 
 
从官网可以看到有些卷类型已标记为弃用（将来会移除）、有些已移除。它们由kubernetes提供，所以也称为树内（in-tree）卷插件。  

这些树内（in-tree）卷插件可以在pods资源(简写po)、persistentvolumes资源(简写pv)的API规范中可以看到，以下对其做了一些分类。
```
特殊卷类型
  configMap
    #
    # pods.spec.volumes.configMap
    #
    # 树内卷插件之configMap的后端存储是configmaps资源对象
    # configmaps资源对象中的数据(key value)是存放到kube-apiserver的后端之etcd中的。
    #
  secret
    #
    # pods.spec.volumes.secret 
    # 
    # 树内卷插件之secret的后端存储是secrets资源对象。
    # secrets资源对象中的数据(key value)是存放到kube-apiserver的后端之etcd中的。
    #
  downwardAPI
    # 
    # pods.spec.volumes.downwardAPI
    #
    # 树内卷插件之downwardAPI的后端存储即Pod副本的相关信息(通过相关字段引用)
    # Pod副本自身相关信息是存放到kube-apiserver的后端之etcd中的。
    # 
  projected
    # 
    # pods.spec.volumes.projected
    #
    # 树内卷插件之projected的后端是现有的卷源，可以将若干现有的卷源进行映射/投射
    #  configmaps、secrets、downwardAPI、serviceAccountToken、clusterTrustBundle
    #  

临时卷类型
  emptyDir
    #
    # pods.spec.volumes.emptyDir
    # 
    # 树内卷插件之emptyDir的后端存储由Pod副本所在worker node上的kubelet进行创建（是个空目录）
    # 

本地卷类型
  hostPath
    # 
    # pods.spec.volumes.hostPath
    # pv.spec.hostPath
    #
  local
    # 
    # pv.spec.local
    #
    # 

网络存储卷类型
  文件系统：nfs、glusterfs、cephfs、cinder
    #
    # pods.spec.volumes.
    # pv.spec
    # 
  块 设 备：iscsi、fc、rbd、vsphereVolume
    #
    # pods.spec.volumes
    # pv.spec.
    #
  存储平台：quobyte、portworxVolume、storageos、scaleIO
    #
    # pods.spec.volumes
    # pv.spec
    # 
  云 存 储：awsElasticBlockStore、gcePersistentDisk、azureFile、azureDisk
    #
    # pods.spec.volumes
    # pv.spec.
    # 

扩展接口(为了对接"外部卷驱动程序"而准备的树内卷插件)
  flexVolume
    #
    # pods.spec.volumes
    # pv.spec
    # 
  csi
    # 
    # pods.spec.volumes
    # pv.spec
    # 
    # 通过PersistentVolumeClaim对象引用是最常用的
    # persistentVolumeClaim卷插件指定pvc资源对象。
    # pvc资源对象会与pv进行一一绑定。
    # pv中使用csi卷插件。  
    # 
```


# 2 持久卷申领、持久卷、存储类










