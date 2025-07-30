# 1 树内卷插件之projected的介绍
参考: https://kubernetes.io/zh-cn/docs/concepts/storage/projected-volumes/  
一个 projected 卷可以将若干现有的卷源映射到同一个目录之上，目前，以下类型的卷源可以被投射：
```
configMap
  #
  # configmaps资源对象
  #
secret
  #
  # secrets资源对象
  # 
downwardAPI
  #
  # downwardAPI卷插件所能获取到Pod的相关信息
  #
serviceAccountToken
clusterTrustBundle
```
