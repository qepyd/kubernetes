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

## 3.2 相关应用的manifests
```
root@master01:~# tree 03.jmsco-project/
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
root@master01:~# kubectl get -f  ./03.jmsco-project/app61-cephfs/
NAME                                     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM              STORAGECLASS                   REASON   AGE
persistentvolume/jmsco-prod-app61-data   10Gi       RWX            Retain           Bound    jmsco/app61-data   jmsco-project-prod-static-pv            5s

NAME                               STATUS   VOLUME                  CAPACITY   ACCESS MODES   STORAGECLASS                   AGE
persistentvolumeclaim/app61-data   Bound    jmsco-prod-app61-data   10Gi       RWX            jmsco-project-prod-static-pv   5s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/app61   2/2     2            2           5s

## 列出相关pods资源对象
root@master01:~#  kubectl -n jmsco get pods -o wide | grep  $(kubectl -n jmsco describe deploy/app61  | grep "NewReplicaSet:" | cut -d " " -f 4)
app61-5b8f9759f5-8jcwr   2/2     Running   0          64s   10.0.3.34   node01   <none>           <none>
app61-5b8f9759f5-ftdbl   2/2     Running   0          64s   10.0.4.35   node02   <none>           <none>
```

到某Pod副本所在worker node上查看其挂载
```
## 查看pod/app61-5b8f9759f5-8jcwr对象的uid
root@master01:~# kubectl -n jmsco get pods/app61-5b8f9759f5-8jcwr -o json | jq ".metadata.uid"
"05fd98f1-d205-418e-b4e8-dd14a3f47593"

## 到所在worker node上查看其挂载
root@node01:~# df -h | grep 05fd98f1-d205-418e-b4e8-dd14a3f47593
tmpfs                                                                                                           7.7G   12K  7.7G   1% /var/lib/kubelet/pods/05fd98f1-d205-418e-b4e8-dd14a3f47593/volumes/kubernetes.io~projected/kube-api-access-xq8kj
172.31.8.201:6789,172.31.8.202:6789,172.31.8.203:6789:/volumes/app61/data/4521a3d7-d683-44f1-90c9-c18cfe4a2809  474G     0  474G   0% /var/lib/kubelet/pods/05fd98f1-d205-418e-b4e8-dd14a3f47593/volumes/kubernetes.io~csi/jmsco-prod-app61-data/mount
```

相关Pod副本中的主容器在其自身的/data/目录下产生数据
```
...................
```

销毁deploy/app61、pvc/app61-data、pv/jmsco-prod-app61-data
```
kubectl delete -f ./03.jmsco-project/app61-cephfs/ 
```

重建pv/jmsco-prod-app61-data、pvc/app61-data、deploy/app61后，到相关Pod副本中其相关主容器的/data/目录下查看之前的数据，看是否还在，结果是数据还在的哈。
```
...................
```


## 3.4 涉及rbd的应用实践(以app63为例)
创建secrets/jmsco-project-ceph-rbd-in-jmscorbd-user-key对象
```
## 快速编写manifests
bash  03.jmsco-project/secrets_jmsco-project-ceph-rbd-in-jmscorbd-user-key/command.sh

## 应用manifests
kubectl apply -f  03.jmsco-project/secrets_jmsco-project-ceph-rbd-in-jmscorbd-user-key/secrets_jmsco-project-ceph-rbd-in-jmscorbd-user-key.yaml  --dry-run=client
kubectl apply -f  03.jmsco-project/secrets_jmsco-project-ceph-rbd-in-jmscorbd-user-key/secrets_jmsco-project-ceph-rbd-in-jmscorbd-user-key.yaml

## 列出资源对象 
root@master01:~# kubectl -n jmsco get secrets/jmsco-project-ceph-rbd-in-jmscorbd-user-key
NAME                                          TYPE     DATA   AGE
jmsco-project-ceph-rbd-in-jmscorbd-user-key   Opaque   2      4d4h
```

创建deploy/app63对象
```
## 应用manifests
root@master01:~# kubectl apply -f 03.jmsco-project/app63-rbd/ --dry-run=client
persistentvolume/jmsco-prod-app63-data created (dry run)
persistentvolumeclaim/app63-data created (dry run)
pod/app63 created (dry run)
root@master01:~#
root@master01:~#  kubectl apply -f 03.jmsco-project/app63-rbd/
persistentvolume/jmsco-prod-app63-data created
persistentvolumeclaim/app63-data created
pod/app63 created

## 列出相关资源对象
root@master01:~# kubectl get -f 03.jmsco-project/app63-rbd/
NAME                                     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM              STORAGECLASS                   REASON   AGE
persistentvolume/jmsco-prod-app63-data   5Gi        RWO            Retain           Bound    jmsco/app63-data   jmsco-project-prod-static-pv            19s

NAME                               STATUS   VOLUME                  CAPACITY   ACCESS MODES   STORAGECLASS                   AGE
persistentvolumeclaim/app63-data   Bound    jmsco-prod-app63-data   5Gi        RWO            jmsco-project-prod-static-pv   19s

NAME        READY   STATUS    RESTARTS   AGE
pod/app63   2/2     Running   0          19s

## 列出pod/app63对象并显示详细信息
root@master01:~# kubectl -n jmsco get pod/app63 -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
app63   2/2     Running   0          74s   10.0.3.35   node01   <none>           <none>
```

到pod/app63其所在worker node上查看相平面挂载
```
## 查看pod/app63其uid
root@master01:~# kubectl -n jmsco get pods/app63 -o json | jq ".metadata.uid"
"93b5ebe8-6285-472d-aadd-e7c0c92e0590"

## 到所在worker node上查看挂载
root@node01:~# df -h | grep 93b5ebe8-6285-472d-aadd-e7c0c92e0590
tmpfs                                                                                                           7.7G   12K  7.7G   1% /var/lib/kubelet/pods/93b5ebe8-6285-472d-aadd-e7c0c92e0590/volumes/kubernetes.io~projected/kube-api-access-v6cbr
/dev/rbd0                                                                                                       4.9G   24K  4.9G   1% /var/lib/kubelet/pods/93b5ebe8-6285-472d-aadd-e7c0c92e0590/volumes/kubernetes.io~csi/jmsco-prod-app63-data/mount
```

在pod/app63其相关主容器的/data/目录下产生数据
```
...................
```

销毁pod/app63、pvc/app63-data、pv/jmsco-prod-app63-data
```
kubectl delete -f ./03.jmsco-project/app63-rbd/
```

重建pv/jmsco-prod-app63-data、pvc/app63-data、pods/app63后，到pods/app63对象其相关主容器的/data/目录下查看之前的数据，看是否还在，结果是数据还在的哈。
```
...................
```

# 4 清理环境（注意）
我这里不清理相关的secrets资源对象，因为在 ../07.dynamic-pv-use-csi-InTreeVolumePlugin/ 处还会用到。只清理相关的应用(app61、app63)
```
kubectl get    -f ./03.jmsco-project/app61-cephfs/
kubectl delete -f ./03.jmsco-project/app61-cephfs/

kubectl get    -f ./03.jmsco-project/app63-rbd/
kubectl delete -f ./03.jmsco-project/app63-rbd/
```


