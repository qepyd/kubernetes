# 1 为lili项目创建文件系统(FS)
## 1.1 创建metadata和data存储池
```
## 创建metadata存储池
ceph osd pool ls  | grep cephfs-lili-project-metadata
ceph osd pool create     cephfs-lili-project-metadata 32 32
ceph osd pool ls  | grep cephfs-lili-project-metadata

ceph osd pool application enable cephfs-lili-project-metadata cephfs
ceph osd pool ls detail   | grep cephfs-lili-project-metadata | grep "application cephfs"

## 创建data存储池
ceph osd pool ls  | grep cephfs-lili-project-data
ceph osd pool create     cephfs-lili-project-data 64 64
ceph osd pool ls  | grep cephfs-lili-project-data

ceph osd pool application enable cephfs-lili-project-data cephfs
ceph osd pool ls detail   | grep cephfs-lili-project-data | grep "application cephfs"
```

## 1.2 创建文件系统(FS)
```
ceph fs new lili  cephfs-lili-project-metadata  cephfs-lili-project-data
ceph fs ls
ceph fs ls | grep -w lili
ceph fs volume ls
ceph fs volume ls | grep -w lili
```

# 2 创建用户并授权
## 2.1 创建lilifs用户
```
ceph auth add client.lilifs
ceph auth get client.lilifs
```
	
## 2.2 为其lilifs用户授权
```
ceph auth caps client.lilifs  mon 'allow r'  mds 'allow rw'  osd 'allow rwx pool=cephfs-lili-project-data'
```

## 2.3 导出lilifs用户的secret
将导出的secret给到lili项目其维护
```
## 输出至屏幕
ceph auth print-key client.lilifs

## 保存至文件
ceph auth print-key client.lilifs -o /tmp/ceph.client.lilifs.secret
ls -l /tmp/ceph.client.lilifs.secret

## 我这里的信息为（为了后面的文档）
admin@ceph-mon01:~$ cat /tmp/ceph.client.lilifs.secret
AQB9fqFo1tQLKBAAjayi0VKa33WL/nQD6wzLXg==
```

将以下信息给到binbin项目其维护人员
```
ceph集群的monitors信息为
  172.31.8.201:6789
  172.31.8.202:6789
  172.31.8.203:6789
```

# 3 为lili项目相关应用创建volume
## 3.1 app71
```
## 查看是存在lili文件卷
admin@ceph-mon01:~$ ceph fs ls | grep lili
name: lili, metadata pool: cephfs-lili-project-metadata, data pools: [cephfs-lili-project-data ]

## 查看lili文件卷下有哪些subvolumegroup
admin@ceph-mon01:~$ ceph fs subvolumegroup ls  lili
[]

## 在lili文件系统下创建subvolumegroup(以应用程序的name来命名)
ceph fs subvolumegroup create  lili  app71
ceph fs subvolumegroup ls  lili

## 在lili文件系统下的app71 subvolumegroup下创建subvolume(以某应用程序的实践应用场景命名)
ceph fs subvolume create lili  data   app71
ceph fs subvolume ls     lili         app71

ceph fs subvolume info lili data app71
ceph fs subvolume info lili data app71 | grep path
  #
  # 我这的结果是："path": "/volumes/app71/data/91775ac5-bbb9-4e35-8536-01a5ef677697"
  # 将这的结果告诉lili项目的运维人员：
  #
```

## 3.2 app72 
```
## 查看是存在lili文件卷  
admin@ceph-mon01:~$ ceph fs ls | grep lili
name: lili, metadata pool: cephfs-lili-project-metadata, data pools: [cephfs-lili-project-data ]

## 查看lili文件卷下有哪些subvolumegroup
ceph fs subvolumegroup ls  lili

## 在lili文件系统下创建subvolumegroup(以应用程序的name来命名)
ceph fs subvolumegroup create  lili  app72
ceph fs subvolumegroup ls  lili

## 在lili文件系统下的 app72 subvolumegroup下创建subvolume(以某应用程序的实践应用场景命名)
ceph fs subvolume create lili  data   app72
ceph fs subvolume ls     lili  app72

ceph fs subvolume info lili data app72
ceph fs subvolume info lili data app72 | grep path
  #
  # 我这的结果是："path": "/volumes/app72/data/b36d80c4-ea26-4706-afd3-95e742c665f4"
  # 将这的结果告诉lili项目的运维人员：
  #
```

