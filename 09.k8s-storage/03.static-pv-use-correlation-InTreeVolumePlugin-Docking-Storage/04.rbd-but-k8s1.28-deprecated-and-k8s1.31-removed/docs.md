# 1 存储系统ceph中做准备
```
参考 ./01.storage-admin/
```

# 2 k8s管理员做相关准备
```
参考 ./02.k8s-admin/
```

# 3 binbin项目其app41应用
相关文件
```
root@master01:~# tree 03.binbin-project/app41/
03.binbin-project/app41/
├── 01.pv_binbin-prod-app41-data.yaml
├── 02.pvc_app41-data.yaml
└── 03.pods_app41.yaml

0 directories, 3 files

```

相关注意
```
需要将 ./01.storage-admin/ 处其binbinrbd用户的keyring放在k8s其worker node的/etc/ceph/目录下。
```






# 4 binbin项目其app42应用


# 5 清理环境
```
kubectl delete -f  03.binbin-project/app41/

kubectl delete -f  03.binbin-project/app42/

kubectl delete -f  03.binbin-project/app42/secrets_binbin-project-ceph-rbd-in-binbinrbd-user-key/
```


