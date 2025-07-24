只需要手动创建pvc
```
   
pvc资源对象指定集群的sc资源对象
   pvc.spec.storageClassName

sc资源对象会连接存储系统，根据pvc的需求创建出pv资源对象

pvc资源对象与pv进行一对一绑定，肯定是可以绑定的。
```
