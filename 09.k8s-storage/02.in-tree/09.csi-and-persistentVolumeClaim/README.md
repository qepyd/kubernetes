https://kubernetes.io/zh-cn/docs/concepts/storage/volumes/#csi   
一旦在 Kubernetes 集群上部署了 CSI 兼容卷驱动程序，用户就可以使用 csi 卷类型来挂接、挂载 CSI 驱动所提供的卷。  
csi 卷可以在 Pod 中以三种方式使用
```
通过 PersistentVolumeClaim 对象引用
  #
  # PersistentVolumeClaim卷类型指定pvc资源对象
  # pvc资源对象会与pv进行一一绑定。
  # pv中使用csi卷插件(kubectl explain pv.spec.csi)
  #  

使用一般性的临时卷
  #
  # 了解即可
  #

使用 CSI 临时卷， 前提是驱动支持这种用法
  #
  # 了解即可
  #
```
