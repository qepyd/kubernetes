# 1 kubernetes的存储基本介绍
## 1.1 所谓的kubernetes存储
任何应用要交付到kubernetes中就得以Pod方式交付（不一定是用pods资源来进行编排哈）。Pod中


## 1.1 csi的设计方案
**参考**  
```
https://github.com/kubernetes/design-proposals-archive/blob/main/storage/container-storage-interface.md
```
**术语(Terminology)**
```
## csi(Container Storage Interface,容器存储接口)

## in-tree（树内）

## out-of-tree(树外)

## CSI Volume Plugin

## CSI Volume Driver
```


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

## 1.2 
