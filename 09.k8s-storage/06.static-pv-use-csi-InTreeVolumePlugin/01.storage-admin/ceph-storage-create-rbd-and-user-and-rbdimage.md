# 1 为jmsco项目相关应用的块存储创建存储池
创建相关的data存储池
```
## 创建rbd-jmsco-project-data存储池
ceph osd pool ls | grep rbd-jmsco-project-data
ceph osd pool create    rbd-jmsco-project-data 32 32
ceph osd pool ls | grep rbd-jmsco-project-data 

## 开启rbd-jmsco-project-data存储池的rbd功能
ceph osd pool application enable rbd-jmsco-project-data  rbd
ceph osd pool ls detail   | grep rbd-jmsco-project-data  | grep rbd

## 初始化rbd-jmsco-project-data存储池
rbd pool init -p                 rbd-jmsco-project-data
ceph osd pool ls detail | grep   rbd-jmsco-project-data | grep  snaps
```

# 2 创建jmscorbd用户并授权
## 2.1 创建jmscorbd用户
```
ceph auth add client.jmscorbd
ceph auth get client.jmscorbd
```

## 2.2 为其jmscorbd用户授权
此用户具备在rbd-jmsco-project-data存储池中创建image的能力(**为了动态pv**)
```
ceph auth caps  client.jmscorbd  mon 'allow r' osd 'allow rwx pool=rbd-jmsco-project-data'
ceph auth get   client.jmscorbd
```

## 2.3 导出jmscorbd用户的secret
导出secret，给到jmsco项目的应用维护人员
```
ceph auth print-key client.jmscorbd   # 屏幕上打印
ceph auth print-key client.jmscorbd -o /tmp/ceph.client.jmscorbd.secret
ls -l /tmp/ceph.client.jmscorbd.secret

admin@ceph-mon01:~$ cat /tmp/ceph.client.jmscorbd.secret
QDv3J1oFWA2BhAA18FJBmSt9WKHY7NXqzHuAg==
```

把ceph集群其monitors的连接地址告诉jmsco项目的应用维护人员
```
其monitory的连接地址为
  172.31.8.201:6789
  172.31.8.202:6789
  172.31.8.203:6789
```

# 3 为jmsco项目相关应用创建image
## 3.1 app63
```
rbd ls  -l --pool rbd-jmsco-project-data
rbd create --pool rbd-jmsco-project-data app63-data --size 5G  --image-format 2 --image-feature layering
rbd ls     --pool rbd-jmsco-project-data
rbd ls  -l --pool rbd-jmsco-project-data
```

## 3.2 app64
```
rbd ls  -l --pool rbd-jmsco-project-data
rbd create --pool rbd-jmsco-project-data app64-data --size 5G  --image-format 2 --image-feature layering
rbd ls     --pool rbd-jmsco-project-data
rbd ls  -l --pool rbd-jmsco-project-data
```
