# 1 为jmsco项目创建文件系统FS
## 1.1 创建metadata和data存储池
```
## 创建metadata存储池
ceph osd pool ls  | grep cephfs-jmsco-project-metadata
ceph osd pool create     cephfs-jmsco-project-metadata 32 32
ceph osd pool ls  | grep cephfs-jmsco-project-metadata
  
ceph osd pool application enable cephfs-jmsco-project-metadata cephfs
ceph osd pool ls detail   | grep cephfs-jmsco-project-metadata | grep "application cephfs"

## 创建data存储池
ceph osd pool ls  | grep cephfs-jmsco-project-data
ceph osd pool create     cephfs-jmsco-project-data 64 64
ceph osd pool ls  | grep cephfs-jmsco-project-data
  
ceph osd pool application enable cephfs-jmsco-project-data cephfs
ceph osd pool ls detail   | grep cephfs-jmsco-project-data | grep "application cephfs"
```

## 2.2 创建文件系统(FS)
以项目名来命名文件系统
```
ceph fs new jmsco  cephfs-jmsco-project-metadata  cephfs-jmsco-project-data
ceph fs ls 
ceph fs ls | grep -w jmsco
ceph fs volume ls 
ceph fs volume ls | grep -w jmsco
```

# 2 创建用户并授权
## 2.1 创建jmscofs用户
```
ceph auth add client.jmscofs
ceph auth get client.jmscofs
```

## 2.2 为其jmscofs用户授权
此用户具备在jmsco fs中创建、删除subvolumegroup和在某subvolumegroup中创建subvolume的能力(**为了动态pv**)
```
ceph auth caps client.jmscofs   \
  mon 'allow r   fsname=jmsco'   \
  mds 'allow r   fsname=jmsco'    \
  osd 'allow rw  pool=cephfs-jmsco-project-metadata,  allow rw pool=cephfs-jmsco-project-data'  \
  mgr 'allow rw'
```

## 2.2 导出jmscofs用户的secret
将导出的secret给到jmsco项目其维护
```
## 输出至屏幕
ceph auth print-key client.jmscofs

## 保存至文件
ceph auth print-key client.binbinfs -o /tmp/ceph.client.jmscofs.secret
ls -l /tmp/ceph.client.jmscofs.secret

## 我这里的信息为（为了后面的文档）
admin@ceph-mon01:~$ cat /tmp/ceph.client.jmscofs.secret
AQCnIaRosGViFRAAWRwEbJ7Dt7h0s8PPTmuMdg==
```

将以下信息给到binbin项目其维护人员
```
ceph集群的monitors信息为
  172.31.8.201:6789
  172.31.8.202:6789
  172.31.8.203:6789
```

# 3 为jmsco项目相关应用创建csi subvolumegroup，为动态pv使用
ceph-csi其cephfs的CsiController其provsionar不会在相关fs中创建subvolumegroup，而是引用csi subvolumegroup。
所以这里我们人为先创建好。
```
ceph fs subvolumegroup create  jmsco  csi
ceph fs subvolumegroup ls      jmsco
```

# 4 为jmsco项目相关应用创建volume，为静态pv使用
## 4.1 app61
```
## 在jmsco文件系统下创建subvolumegroup(以应用程序的name来命名)
ceph fs subvolumegroup create  jmsco  app61
ceph fs subvolumegroup ls      jmsco

## 在jmsco文件系统下的subvolumegroup下创建subvolume(以某应用程序的实践应用场景命名)
ceph fs subvolume create jmsco  data   app61
ceph fs subvolume ls     jmsco  app61

ceph fs subvolume info jmsco data app61
ceph fs subvolume info jmsco data app61 | grep path
  #
  # 我这的结果是："path": "/volumes/app61/data/4521a3d7-d683-44f1-90c9-c18cfe4a2809" 
  # 将这的结果告诉jmsco项目的运维人员：
  #
```

## 4.2 app62
```
## 在jmsco文件系统下创建subvolumegroup(以应用程序的name来命名)
ceph fs subvolumegroup create  jmsco  app62
ceph fs subvolumegroup ls  jmsco

## 在jmsco文件系统下的subvolumegroup下创建subvolume(以某应用程序的实践应用场景命名)
ceph fs subvolume create jmsco  data   app62
ceph fs subvolume ls     jmsco  app62

ceph fs subvolume info jmsco data app62
ceph fs subvolume info jmsco data app62 | grep path
  #
  # 我这的结果是："path": "/volumes/app62/data/2a8d4cf7-e8a4-40cf-b061-9d32e357efd9" 
  # 将这的结果告诉jmsco项目的运维人员：
  #
```
