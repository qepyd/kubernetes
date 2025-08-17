==============================Pod使用相关树内(in tree)卷插件直接对接存储系统==============================

在Pod的Pod级别使用相关卷类型(树内卷插件，不涉及persistentVolumeClaim)直接与相关卷类型的后端存储打交道。
对于kubernetes的用户来说，将一个应用以Pod方式交付到k8s中，若涉及文件/共享存储(使用nfs、cephfs卷类型)、
块存储(使用rbd卷类型)时，还得了解相关存储系统的结构、配置，加大了其难度。

kubernetes给出的方案就是在Pod级别使用 persistentVolumeClaim 卷类型对接Pod所在namespace中已存在的pvc资源
对象（前提是与k8s集群级别的某pv已是绑定关系），这样Pod就是间接的对接到存储系统中。

对于kubernetes的用户来说，使用相关卷类型直接对接存储系统是要掌握的。
```
## 特殊卷类型
configMap    # pods.spec.volumes.configMap
secret       # pods.spec.volumes.secret
downwardAPI  # pods.spec.volumes.downwardAPI
emptyDir     # pods.spec.volumes.emptyDir

## 本地卷类型
hostPath     # pods.spec.volumes.hostPath   和  pv.spec.hostPath
```

对于kubernetes的管理员来说，使用相关卷类型直接对接存储系统是要掌握的。
```
## 特殊卷类型
configMap    # pods.spec.volumes.configMap
secret       # pods.spec.volumes.secret
downwardAPI  # pods.spec.volumes.downwardAPI
emptyDir     # pods.spec.volumes.emptyDir

## 本地卷类型
hostPath     # pods.spec.volumes.hostPath   和  pv.spec.hostPath

## 网络存储（了解即可）
nfs          # pods.spec.volumes.nfs        和  pv.spec.nfs
cephfs       # pods.spec.volumes.cephfs     和  pv.spec.cephfs
rbd          # pods.spec.volumes.rbd        和  pv.spec.rbd
```
