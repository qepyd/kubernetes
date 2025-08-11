# 1 为lili项目相关应用的块存储创建存储池
创建相关的data存储池
```
## 创建rbd-lili-project-data存储池
ceph osd pool create    rbd-lili-project-data 32 32
ceph osd pool ls | grep rbd-lili-project-data 

## 开启rbd-lili-project-data存储池的rbd功能
ceph osd pool application enable rbd-lili-project-data  rbd
ceph osd pool ls detail   | grep rbd-lili-project-data  | grep rbd

## 初始化rbd-lili-project-data存储池
rbd pool init -p                 rbd-lili-project-data
ceph osd pool ls detail | grep   rbd-lili-project-data | grep  snaps
```

# 2 创建lilirbd用户并授权
## 2.1 创建lilirbd用户
```
ceph auth add client.lilirbd
ceph auth get client.lilirbd
```

## 2.2 为其lilirbd用户授权
```
ceph auth caps client.lilirbd  mon 'allow r' osd 'allow rwx pool=rbd-lili-project-data'
```

## 2.3 导出lilirbd用户的secret和keyring
导出secret，给到lili项目的应用维护人员
```
ceph auth print-key client.lilirbd   # 屏幕上打印
ceph auth print-key client.lilirbd -o /tmp/ceph.client.lilirbd.secret
ls -l /tmp/ceph.client.lilirbd.secret

admin@ceph-mon01:~$ cat /tmp/ceph.client.lilirbd.secret
AQAiK5BoegbUCBAAAHS8rJmnML0XuJSCOJ250Q==
```

导出keyring，给到lili项目的应用维护人员
```
ceph auth get client.lilirbd         # 屏幕上打印 
ceph auth get client.lilirbd -o /tmp/ceph.client.lilirbd.keyring
ls -l /tmp/ceph.client.lilirbd.keyring

admin@ceph-mon01:~$ cat /tmp/ceph.client.lilirbd.keyring 
[client.lilirbd]
    key = AQAiK5BoegbUCBAAAHS8rJmnML0XuJSCOJ250Q==
    caps mon = "allow r"
    caps osd = "allow rwx pool=rbd-lili-project-data"
```

把ceph集群其monitors的连接地址告诉lili项目的应用维护人员
```
其monitory的连接地址为
  172.31.8.201:6789
  172.31.8.202:6789
  172.31.8.203:6789
```

# 3 为lili项目相关应用创建image
## 3.1 app81
```
rbd create --pool rbd-lili-project-data app81-data --size 5G  --image-format 2 --image-feature layering
rbd ls     --pool rbd-lili-project-data 
rbd ls  -l --pool rbd-lili-project-data
```

## 3.2 app82
```
rbd create --pool rbd-lili-project-data app82-data --size 5G  --image-format 2 --image-feature layering
rbd ls     --pool rbd-lili-project-data 
rbd ls  -l --pool rbd-lili-project-data
```

