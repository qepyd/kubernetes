# 1 ceph集群中的管理
```
参考 ./01.storage-admin/
```

# 2 k8s集群中的管理
```
参考 ./02.k8s-admin/
```

# 3 jmsco项目相关应用的部署
## 3.1 创建ns/jmsco对象
```
kubectl apply -f ns_jmsco.yaml
kubectl get  ns/jmsco 
```

## 3.3 相关应用的manifests
```
root@master01:/qepyd/kubernetes/09.k8s-storage/06.static-pv-use-csi-InTreeVolumePlugin# tree 03.jmsco-project/
03.jmsco-project/
├── app61-cephfs
│   ├── 01.pv_jmsco-prod-app61-data.yaml
│   ├── 02.pvc_app61-data.yaml
│   └── 03.deploy_app61.yaml
├── app62-cephfs
│   ├── 01.pv_jmsco-prod-app62-data.yaml
│   ├── 02.pvc_app62-data.yaml
│   └── 03.deploy_app62.yaml
├── app63-rbd
│   ├── 01.pv_jmsco-prod-app63-data.yaml
│   ├── 02.pvc_app63-data.yaml
│   └── 03.pods_app63.yaml
├── app64-rbd
│   ├── 01.pv_jmsco-prod-app64-data.yaml
│   ├── 02.pvc_app64-data.yaml
│   └── 03.pods_app64.yaml
├── secrets_jmsco-project-ceph-fs-in-jmscofs-user-key
│   ├── ceph.client.jmscofs.secret
│   ├── command.sh
│   └── secrets_jmsco-project-ceph-fs-in-jmscofs-user-key.yaml
└── secrets_jmsco-project-ceph-rbd-in-jmscorbd-user-key
    ├── ceph.client.jmscorbd.secret
    ├── command.sh
    └── secrets_jmsco-project-ceph-rbd-in-jmscorbd-user-key.yaml

6 directories, 18 files
```

## 3.3 涉及cephfs的应用实践(以app61为例)
创建secrets/jmsco-project-ceph-fs-in-jmscofs-user-key对象
```
## 快速编写manifests
bash 03.jmsco-project/secrets_jmsco-project-ceph-fs-in-jmscofs-user-key/command.sh

## 应用manifests
root@master01:~# kubectl apply -f 03.jmsco-project/secrets_jmsco-project-ceph-fs-in-jmscofs-user-key/secrets_jmsco-project-ceph-fs-in-jmscofs-user-key.yaml --dry-run=client
secret/jmsco-project-ceph-fs-in-jmscofs-user-key configured (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.jmsco-project/secrets_jmsco-project-ceph-fs-in-jmscofs-user-key/secrets_jmsco-project-ceph-fs-in-jmscofs-user-key.yaml
secret/jmsco-project-ceph-fs-in-jmscofs-user-key configured

## 列出资源对象
root@master01:~# kubectl -n jmsco get secret/jmsco-project-ceph-fs-in-jmscofs-user-key 
NAME                                        TYPE     DATA   AGE
jmsco-project-ceph-fs-in-jmscofs-user-key   Opaque   2      4d2h
```

创建deploy/app61对象
```
## 应用manifests
root@master01:~# kubectl apply -f  ./03.jmsco-project/app61-cephfs/ --dry-run=client
persistentvolume/jmsco-prod-app61-data created (dry run)
persistentvolumeclaim/app61-data created (dry run)
deployment.apps/app61 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f  ./03.jmsco-project/app61-cephfs/ 
persistentvolume/jmsco-prod-app61-data created
persistentvolumeclaim/app61-data created
deployment.apps/app61 created

## 列出相关资源对象



```


## 3.3 涉及rbd的应用实践(以app63为例)
创建secrets/jmsco-project-ceph-rbd-in-jmscorbd-user-key对象
```
## 快速编写manifests
bash 


```

