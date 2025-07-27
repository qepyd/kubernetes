
pods.spec.volumes.persistentVolumeClaim
```
指定pod所在namespace中的pvc资源对象(pvc是namespace级别的资源)。
pvc需要我们人为手动创建，至于pvc得要能够匹配到集群中的某pv，pvc与pv是一一对应。
这里我们还未涉及到pvc、pv的学习，所以这里也无法实践，看看上述的基本说明即可。
```

pods.spec.volumes.csi
```
不用它，我们用pv资源对象的spec.csi去对接外部csi驱动(external csi volume driver)
```

