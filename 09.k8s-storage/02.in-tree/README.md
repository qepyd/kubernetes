01：不会涉及 pv.spec 下的相关树内卷插件。

02：主要涉及 pods.spec.volumes 下的相关树内卷插件（非全部）。
```
作为kuernetes的用户
   特殊卷类型(得掌握，因为简单，不涉及到复杂的存储系统)
      configMap
      secret
      downwardAPI
      projected

   临时卷类型(得掌握，因为简单，不涉及到复杂的存储系统)
      emptyDir

   本地卷类型(得掌握，因为简单，不涉及到复杂的存储系统)
      hostPath
      local     # 此外不会涉及,在pv.spec下

   网络存储卷(在创建Pod时其要对接存储系统，还得了解相关的存储系统。kubernetes给出的方案是使用 persistentVolumeClaim 这个树内卷插件)
      文件系统：nfs、cephfs
      块存储：rbd
```

