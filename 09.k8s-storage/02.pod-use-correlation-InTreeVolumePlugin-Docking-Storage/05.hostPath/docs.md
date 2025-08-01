# 1 树内插件之hostPath的介绍
官方参考：https://kubernetes.io/zh-cn/docs/concepts/storage/volumes/#hostpath

其API规范：kubectl explain pods.spec.volumes.hostPath
```
path: <string> -required-
  # 
  # 指定worker node上的某目录或某文件
  #
type: <string>
  #
  # 默认值为""
  # 可设置值有：
  #   Directory
  #     worker node上某目录，得事先存在。
  #
  #   DirectoryOrCreate 
  #     worker node上某目录，若有父目录不存在，创建目录是成功的。
  #
  #   File
  #     worker node上某文件的绝对路径，得事先存在。
  #
  #   FileOrCreate
  #     worker node上文件的绝对路径，若有父目录不存在，创建文件失败的。
  #     创建的是空文件，，权限设置为 0644，具有与 kubelet 相同的组和所有权
  #
  #   Socket
  #     在给定路径上必须存在的 UNIX 套接字。
  #
  #   CharDevice
  #     （仅 Linux 节点） 在给定路径上必须存在的字符设备
  #    
  #   BlockDevice
  #     （仅 Linux 节点） 在给定路径上必须存在的块设备。
```




