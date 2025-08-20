# 1 为lanlan项目相关应用的块存储创建存储池
创建相关的data存储池
```
## 创建rbd-lanlan-project-data存储池
ceph osd pool ls | grep rbd-lanlan-project-data
ceph osd pool create    rbd-lanlan-project-data 32 32
ceph osd pool ls | grep rbd-lanlan-project-data 

## 开启rbd-lanlan-project-data存储池的rbd功能
ceph osd pool application enable rbd-lanlan-project-data  rbd
ceph osd pool ls detail   | grep rbd-lanlan-project-data  | grep rbd

## 初始化rbd-lanlan-project-data存储池
rbd pool init -p                 rbd-lanlan-project-data
ceph osd pool ls detail | grep   rbd-lanlan-project-data | grep  snaps
```

# 2 创建lanlanrbd用户并授权
## 2.1 创建lanlanrbd用户
```
ceph auth add client.lanlanrbd
ceph auth get client.lanlanrbd
```

## 2.2 为其lanlanrbd用户授权
```
ceph auth caps  client.lanlanrbd  mon 'allow r' osd 'allow rwx pool=rbd-lanlan-project-data'
```

## 2.3 导出lanlanrbd用户的secret
导出secret，给到lanlan项目的应用维护人员、k8s集群管理员。
```
ceph auth print-key client.lanlanrbd   # 屏幕上打印
ceph auth print-key client.lanlanrbd -o /tmp/ceph.client.lanlanrbd.secret
ls -l /tmp/ceph.client.lanlanrbd.secret

admin@ceph-mon01:~$ cat /tmp/ceph.client.lanlanrbd.secret
AQCNsZlojdw0MxAAyeyOoErUwqzZYRKuGp+o+A==
```

把ceph集群其monitors的连接地址告诉lanlan项目的应用维护人员、k8s集群管理员。
```
其monitory的连接地址为
  172.31.8.201:6789
  172.31.8.202:6789
  172.31.8.203:6789
```

# 3 这里不为lanlan项目相关应用创建image,因为后面实践的是动态pv
