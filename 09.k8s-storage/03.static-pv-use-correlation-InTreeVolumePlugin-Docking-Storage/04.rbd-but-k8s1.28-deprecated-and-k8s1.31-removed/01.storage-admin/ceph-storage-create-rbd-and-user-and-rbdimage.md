# 1 为binbin项目相关应用的块存储创建存储池
创建相关的data存储池
```
## 创建rbd-binbin-project-data存储池
ceph osd pool ls | grep rbd-binbin-project-data
ceph osd pool create    rbd-binbin-project-data 32 32
ceph osd pool ls | grep rbd-binbin-project-data 

## 开启rbd-binbin-project-data存储池的rbd功能
ceph osd pool application enable rbd-binbin-project-data  rbd
ceph osd pool ls detail   | grep rbd-binbin-project-data  | grep rbd

## 初始化rbd-binbin-project-data存储池
rbd pool init -p                 rbd-binbin-project-data
ceph osd pool ls detail | grep   rbd-binbin-project-data | grep  snaps
```

# 2 创建binbinrbd用户并授权
## 2.1 创建binbinrbd用户
```
ceph auth add client.binbinrbd
ceph auth get client.binbinrbd
```

## 2.2 为其binbinrbd用户授权
```
ceph auth caps  client.binbinrbd  mon 'allow r' osd 'allow rwx pool=rbd-binbin-project-data'
```

## 2.3 导出binbinrbd用户的secret和keyring
导出secret，给到binbin项目的应用维护人员
```
ceph auth print-key client.binbinrbd   # 屏幕上打印
ceph auth print-key client.binbinrbd -o /tmp/ceph.client.binbinrbd.secret
ls -l /tmp/ceph.client.binbinrbd.secret

admin@ceph-mon01:~$ cat /tmp/ceph.client.binbinrbd.secret
AQBYU6RoK9tUHhAAYE2lxF/uzzPj6SA+PB3YmA==
```

导出keyring，给到binbin项目的应用维护人员
```
ceph auth get client.binbinrbd         # 屏幕上打印
ceph auth get client.binbinrbd -o /tmp/ceph.client.binbinrbd.keyring
ls -l /tmp/ceph.client.binbinrbd.keyring

admin@ceph-mon01:~$ cat /tmp/ceph.client.binbinrbd.keyring
[client.binbinrbd]
        key = AQBYU6RoK9tUHhAAYE2lxF/uzzPj6SA+PB3YmA== 
        caps mon = "allow r"
        caps osd = "allow rwx pool=rbd-binbin-project-data"
```

把ceph集群其monitors的连接地址告诉binbin项目的应用维护人员
```
其monitory的连接地址为
  172.31.8.201:6789
  172.31.8.202:6789
  172.31.8.203:6789
```


# 3 为binbin项目相关应用创建image
## 3.1 app41
```
rbd ls  -l --pool rbd-binbin-project-data
rbd create --pool rbd-binbin-project-data app41-data --size 5G  --image-format 2 --image-feature layering
rbd ls     --pool rbd-binbin-project-data
rbd ls  -l --pool rbd-binbin-project-data
```

## 3.2 app42
```
rbd ls  -l --pool rbd-binbin-project-data
rbd create --pool rbd-binbin-project-data app42-data --size 5G  --image-format 2 --image-feature layering
rbd ls     --pool rbd-binbin-project-data
rbd ls  -l --pool rbd-binbin-project-data
```

