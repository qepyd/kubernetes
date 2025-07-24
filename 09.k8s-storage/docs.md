# 1 kubernetes的存储基本介绍
## 1.1 此阶段会涉及到的资源(resources)
```
persistentvolumeclaims
   #
   # 简写pvc，类型为PersistentVolumeClaim
   # kubernetes的标准资源，属于namespace级别的资源
   #
persistentvolumes
   #
   # 简写pv，类型为PersistentVolume
   # kubernetes的标准资源，属于非namespace级别的资源
   # 
storageclasses
   #
   # 简写sc，类型为StorageClass
   # kubernetes的标准资源，属于非namespace级别的资源
   #
csidrivers
   #
   # 无简写，类型为CSIDriver
   # kubernetes的标准资源，属于非namespace级别的资源
   # 
```
