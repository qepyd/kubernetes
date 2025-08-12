# 1 kubernetes的存储介绍
## 1.1 Pod对接存储(卷类型引出)
通过在Pod的Pod级别使用相关卷类型直接或间接的对接相关的所谓存储。容器级别各容器挂载Pod级别的相关卷到自己的文件系统中。
```
直接的例如：
  使用configMap卷类型对接所在名称空间的configmaps资源对象。
  使用secret卷类型对接所在名称空间的secrets资源资源对象。
  使用nfs卷类型对接nfs-server存储系统(事先得准备好相关路径并暴露)。
  使用cephfs卷类型对接ceph存储系统(事先得准备好相关fs和volume)。
  使用rbd郑类型对接ceph存储系统(事先得准备好相关image)。  

  注意：
   对于kubernetes的用户来说，若需要使用文件存储、块存储时还得涉及相关存储系统(例如：nfs-server、ceph)的
   架构、配置、使用逻辑，太难了。那么kubernetes也考滤到了这一点，其给出的解决方案为：Pod在Pod级别使用
   persistentVolumeClaim卷类型去关联所在名称空间中的pvc资源对象，前提是pvc资源对象已经与k8s集群级别的
   某pv资源(属于非namespace级别的资源)对象进行了绑定，pv资源对象才是真正对接存储系统（例如：nfs-server、
   ceph）的，当然pv资源对象也会使用到相关的卷类型，这就是间接的对接存储系统。


间接的例如：
   pod级别(persistentVolumeClaim卷类型)--->pvc资源对象--(绑定)--->pv资源对象(local卷类型对接worker node上的某目录)。
   pod级别(persistentVolumeClaim卷类型)--->pvc资源对象--(绑定)--->pv资源对象(nfs卷类型对接nfs-server)。
   pod级别(persistentVolumeClaim卷类型)--->pvc资源对象--(绑定)--->pv资源对象(cephfs卷类型对接ceph中某fs中的volume)。
   pod级别(persistentVolumeClaim卷类型)--->pvc资源对象--(绑定)--->pv资源对象(rbd卷类型对接ceph中某pool中的image)。

又到了注意：
  随着kubernetes版本的演进，像cephfs、rbd这样的卷类型已不再被支持(被移除了，那么相关的直接或间接也没办法了)。k8s让其使
  用csi卷类型(为了对接k8s外部存储卷驱动而内置的一个卷类型)对接k8s外部存储卷驱动(需要k8s管理员在k8s中部署相关存储系统的
  卷驱动到k8s中，部署好以后会有相应csidrivers资源对象，csidrivers资源是非namespace级别的资源)。

  pod级别(persistentVolumeClaim卷类型)--->pvc资源对象--(绑定)--->pv资源对象(csi卷类型对接csidrivers资源对象)
      #
      # 存储系统(例如：ceph)中也得准备好相应fs及volume、相应pool和image。
      # 
```

## 2.2 k8s的卷类型(树内卷插件)
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










