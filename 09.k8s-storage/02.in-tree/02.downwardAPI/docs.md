# 1 树内卷插件之downwardAPI的介绍
参考：https://kubernetes.io/zh-cn/docs/concepts/workloads/pods/downward-api  
Pod在创建并运行后，自身有一些信息，这些信息可以利用起来（服务Pod中容器里面的应用程序）。通常有两种
方法可以将Pod信息和Pod中容器字段暴露给运行中的容器：环境变量和由特殊卷类型承载的文件。这两种暴露
Pod和容器字段的方法统称为Downward API。

参考：https://kubernetes.io/zh-cn/docs/concepts/storage/volumes/#downwardapi  
downwardAPI卷用于为应用提供Downward API数据。 在这类卷(特殊卷类型)中，所公开的数据以纯文本格式的
只读文件形式存在。  
树内卷插件之downwardAPI的规范可通过kubectl explain pods.spec.volumes.downwardAPI查看。
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

# 2 pods.spec.volumes.downwardAPI.items.fieldRef
```
## 应用manifests
root@master01:~#
root@master01:~# kubectl apply -f 01.pods_volume-downwardapi-fieldref.yaml  --dry-run=client
pod/volume-downwardapi-fieldref created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 01.pods_volume-downwardapi-fieldref.yaml
pod/volume-downwardapi-fieldref created

## 列出资源对象
root@master01:~#
root@master01:~# kubectl  -n lili get pod/volume-downwardapi-fieldref
NAME                          READY   STATUS    RESTARTS   AGE
volume-downwardapi-fieldref   1/1     Running   0          26s


## 进入Pod中的容器查看
root@master01:~#
root@master01:~# kubectl  -n lili exec -it  pod/volume-downwardapi-fieldref -c busybox /bin/sh -- ls -l /data
total 0
drwxrwxrwt    3 root     root           180 Jul 29 03:02 pod-info-metadata
root@master01:~#
root@master01:~# kubectl  -n lili exec -it  pod/volume-downwardapi-fieldref -c busybox /bin/sh -- ls -l /data/pod-info-metadata
total 0
lrwxrwxrwx    1 root     root            25 Jul 29 03:02 annotations.author -> ..data/annotations.author
lrwxrwxrwx    1 root     root            13 Jul 29 03:02 labels -> ..data/labels
lrwxrwxrwx    1 root     root            11 Jul 29 03:02 name -> ..data/name
lrwxrwxrwx    1 root     root            16 Jul 29 03:02 namespace -> ..data/namespace
lrwxrwxrwx    1 root     root            10 Jul 29 03:02 uid -> ..data/uid
root@master01:~#
root@master01:~# kubectl  -n lili exec -it  pod/volume-downwardapi-fieldref -c busybox /bin/sh -- cat /data/pod-info-metadata/namespace
lili
```


# 3 pods.spec.volumes.downwardAPI.items.resourceFieldRef
```
## 应用manifests
root@master01:~# 
root@master01:~# kubectl apply -f 02.pods_volume-downwardapi-resourcefieldref.yaml  --dry-run=client
pod/volume-downwardapi-resourcefieldref created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 02.pods_volume-downwardapi-resourcefieldref.yaml
pod/volume-downwardapi-resourcefieldref created

## 列出资源对象
root@master01:~# 
root@master01:~# kubectl  -n lili get pod/volume-downwardapi-resourcefieldref
NAME                                  READY   STATUS    RESTARTS   AGE
volume-downwardapi-resourcefieldref   1/1     Running   0          34s

## 进入Pod中的容器查看
root@master01:~# 
root@master01:~# kubectl  -n lili exec -it  pod/volume-downwardapi-resourcefieldref -c busybox /bin/sh  -- ls -l /data
total 0
drwxrwxrwt    3 root     root           160 Jul 29 03:05 busybox-container-resources
root@master01:~# 
root@master01:~# kubectl  -n lili exec -it  pod/volume-downwardapi-resourcefieldref -c busybox /bin/sh  -- ls -l /data/busybox-container-resources
total 0
lrwxrwxrwx    1 root     root            17 Jul 29 03:05 limits-cpu -> ..data/limits-cpu
lrwxrwxrwx    1 root     root            20 Jul 29 03:05 limits-memory -> ..data/limits-memory
lrwxrwxrwx    1 root     root            19 Jul 29 03:05 requests-cpu -> ..data/requests-cpu
lrwxrwxrwx    1 root     root            22 Jul 29 03:05 requests-memory -> ..data/requests-memory
root@master01:~#
root@master01:~# kubectl  -n lili exec -it  pod/volume-downwardapi-resourcefieldref -c busybox /bin/sh  -- cat /data/busybox-container-resources/limits-cpu
100
root@master01:~#
root@master01:~# kubectl  -n lili exec -it  pod/volume-downwardapi-resourcefieldref -c busybox /bin/sh  -- cat /data/busybox-container-resources/limits-memory
256
```

# 4 清理环境
```
kubectl delete -f  ./01.pods_volume-downwardapi-fieldref.yaml
kubectl delete -f  ./02.pods_volume-downwardapi-resourcefieldref.yaml
```
