https://kubernetes.io/zh-cn/docs/concepts/storage/volumes/#csi
通过PersistentVolumeClaim对象引用是最常用的。即：
```
persistentVolumeClaim卷插件指定pvc资源对象。
pvc资源对象会与pv进行一一绑定。
pv中使用csi卷插件。  
```

