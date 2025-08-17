# 1 存储系统ceph中做准备
```
参考 ./01.storage-admin
```

# 2 k8s管理员做相关准备
```
参考 ./02.k8s-admin
```

# 3 lili项目的app81应用
相关目录
```
root@master01:~# tree 03.lili-project/app81/
03.lili-project/app81/
└── pods_app81.yaml

0 directories, 1 file
```

特别注意
```
需要将 ./01.storage-admin 阶段其 lilirbd 用户的 keyring 导出后，放置到k8s各worker node或lili项目相关worker node的/etc/ceph/目录下
```




# 4 lili项目的app91应用
相关目录
```
root@master01:~# tree 03.lili-project/secrets_lili-project-ceph-rbd-in-lilirbd-user-key/
03.lili-project/secrets_lili-project-ceph-rbd-in-lilirbd-user-key/
├── ceph.client.lilirbd.secret
├── command.sh
└── secrets_lili-project-ceph-rbd-in-lilirbd-user-key.yaml

0 directories, 3 files
root@master01:~#
root@master01:~#
root@master01:~# tree 03.lili-project/app82/
03.lili-project/app82/
└── pods_app82.yaml

0 directories, 1 file
```

创建secrets/lili-project-ceph-rbd-in-lilirbd-user-key对象
```
## 快速编写其manifests
bash 03.lili-project/command.sh

## 应用manifests
kubectl apply -f  03.lili-project/secrets_lili-project-ceph-rbd-in-lilirbd-user-key.yaml --dry-run=client
kubectl apply -f  03.lili-project/secrets_lili-project-ceph-rbd-in-lilirbd-user-key.yaml

## 列出资源对象
kubectl -n lili  get secrets/lili-project-ceph-rbd-in-lilirbd-user-key

```
