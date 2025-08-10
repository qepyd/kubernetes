# 1 为binbin项目创建文件系统(FS)
## 1.1 创建metadata和data存储池
```
## 创建metadata存储池
ceph osd pool ls  | grep cephfs-binbin-project-metadata
ceph osd pool create     cephfs-binbin-project-metadata 32 32
ceph osd pool ls  | grep cephfs-binbin-project-metadata
  
ceph osd pool application enable cephfs-binbin-project-metadata cephfs
ceph osd pool ls detail   | grep cephfs-binbin-project-metadata | grep "application cephfs"

## 创建data存储池
ceph osd pool ls  | grep cephfs-binbin-project-data
ceph osd pool create     cephfs-binbin-project-data 64 64
ceph osd pool ls  | grep cephfs-binbin-project-data
  
ceph osd pool application enable cephfs-binbin-project-data cephfs
ceph osd pool ls detail   | grep cephfs-binbin-project-data | grep "application cephfs"
```

## 1.2 创建文件系统(FS)
以项目名来命名文件系统 
```
ceph fs new binbin  cephfs-binbin-project-metadata  cephfs-binbin-project-data
ceph fs ls 
ceph fs ls | grep -w binbin
ceph fs volume ls 
ceph fs volume ls | grep -w binbin
```

# 2 创建用户并授权
## 2.1 创建binbinfs用户
```
ceph auth add client.binbinfs
ceph auth get client.binbinfs
``` 

## 2.2 为其binbinfs用户授权
```
ceph auth caps client.binbinfs  mon 'allow r'  mds 'allow rw'  osd 'allow rwx pool=cephfs-binbin-project-data'
```

## 2.3 导出binbinfs用户的secret
将导出的secret给到binbin项目其维护
```
## 输出至屏幕
ceph auth print-key client.binbinfs

## 保存至文件
ceph auth print-key client.binbinfs -o /tmp/ceph.client.binbinfs.secret
ls -l /tmp/ceph.client.binbinfs.secret

## 我这里的信息为（为了后面的文档）
admin@ceph-mon01:~$ cat /tmp/ceph.client.binbinfs.secret
AQDfF5RoeEUEHhAA1rQ+oVfTbMXD8nvI6lZ4WQ==
```

将以下信息给到binbin项目其维护人员
```
ceph集群的monitors信息为
  172.31.8.201:6789
  172.31.8.202:6789
  172.31.8.203:6789
```

# 3 为binbin项目相关应用创建volume
## 3.1 app31
```
## 在binbin文件系统下创建subvolumegroup(以应用程序的name来命名)
ceph fs subvolumegroup create  binbin  app31
ceph fs subvolumegroup ls  binbin

## 在binbin文件系统下的subvolumegroup下创建subvolume(以某应用程序的实践应用场景命名)
ceph fs subvolume create binbin  data   app31
ceph fs subvolume ls     binbin  app31

ceph fs subvolume info binbin data app31
ceph fs subvolume info binbin data app31 | grep path
  #
  # 我这的结果是： "path": "/volumes/app31/data/a05e623d-60ea-4ef2-9167-fcd944225fe0"
  # 将这的结果告诉binbin项目的运维人员：
  #
```

## 3.2 app32
```
## 在binbin文件系统下创建subvolumegroup(以应用程序的name来命名)
ceph fs subvolumegroup create  binbin  app32
ceph fs subvolumegroup ls  binbin


## 在binbin文件系统下的subvolumegroup下创建subvolume(以某应用程序的实践应用场景命名)
ceph fs subvolume create binbin  data   app32
ceph fs subvolume ls     binbin  app32

ceph fs subvolume info binbin data app32
ceph fs subvolume info binbin data app32 | grep path
  #
  # 我这的结果是："path": "/volumes/app32/data/ae1afebb-7f83-4809-9109-47a1bf1c5e52"
  # 将这的结果告诉binbin项目的运维人员：
  #
```

