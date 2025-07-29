# 1 树内卷插件之downwardAPI的介绍
参考：https://kubernetes.io/zh-cn/docs/concepts/workloads/pods/downward-api  
pods资源对象在创建并运行后，其对象自身有一些信息，这些信息可以利用起来（比如给Pod中容器里面的程序使用）。
有两种方法可以将Pod信息和容器字段暴露给运行中的容器：环境变量和由特殊卷类型承载的文件。这两种暴露 Pod 和
容器字段的方法统称为 Downward API。

参考：https://kubernetes.io/zh-cn/docs/concepts/storage/volumes/#downwardapi  
而这里主要是涉及树内卷插件之downwardAPI。其也被分类于投射卷类。这这类卷中，所公开的数据以纯文本格式的
只读文件形式存在。树内卷插件之downwardAPI的规范可通过kubectl explain pods.spec.volumes.downwardAPI查看。
```
defaultMode: <integer>
items: <[]Object>
  path: <string> -required-
  fieldRef: <Object>
    apiVersion: <string>
    fieldPath: <string> -required-
  resourceFieldRef: <Object>
    containerName: <string>
    divisor: <string>
    resource: <string> -required-
  mode: <integer>
```

树内卷插件之downwardAPI其fieldRef可获取到的信息为:   
https://kubernetes.io/zh-cn/docs/concepts/workloads/pods/downward-api/#downwardapi-fieldRef
```
metadata.namespace
metadata.name
metadata.uid
metadata.labels['<KEY>']
metadata.annotations['<KEY>']
```

树内卷插件之downwardAPI其resourceFieldRef可获取到的信息为:
https://kubernetes.io/zh-cn/docs/concepts/workloads/pods/downward-api/#downwardapi-resourceFieldRef
```
resource: limits.cpu
resource: requests.cpu
resource: limits.memory
resource: requests.memory
resource: limits.hugepages-*
resource: requests.hugepages-*
resource: limits.ephemeral-storage
resource: requests.ephemeral-storage
```






