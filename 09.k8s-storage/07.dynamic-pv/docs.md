# 1 还是jmsco项目
```
继续 ../06.static-pv-use-csi-InTreeVolumePlugin/
```

# 2 得完全的部署ceph-csi的cephfs、rbd
即：cephfs的(NodePlugin、CsiController、csidriver资源对象)
即：rbd的(NodePlugin、CsiController、csidriver资源对象)
```
../05.K8s-Internal-Install-ExternalCsiVolumeDriver/ceph-csi/v3.14.2/01.currency/
../05.K8s-Internal-Install-ExternalCsiVolumeDriver/ceph-csi/v3.14.2/02.cephfs/
../05.K8s-Internal-Install-ExternalCsiVolumeDriver/ceph-csi/v3.14.2/03.rbd/
```

# 3 在jmsco名称空间中创建好cephfs、rbd在挂载时要用到的secret资源对象
```
kubectl apply -f  ../06.static-pv-use-csi-InTreeVolumePlugin/03.jmsco-project/secrets_jmsco-project-ceph-fs-in-jmscofs-user-key
kubectl apply -f  ../06.static-pv-use-csi-InTreeVolumePlugin/03.jmsco-project/secrets_jmsco-project-ceph-rbd-in-jmscorbd-user-key/
```

# 4 在ceph-csi名称空间中创建好secrets/ceph-admin对象
```
kubectl apply -f ./01.secret_ceph-admin/ --dry-run=client
kubectl apply -f ./01.secret_ceph-admin/ 
```

# 5 创建jmsco项目其ceph-csi之cephfs的StorageClass资源对象
```
kubectl apply -f ./02.sc_jmsco-ceph-csi-cephfs/ --dry-run=client
kubectl apply -f ./02.sc_jmsco-ceph-csi-cephfs/
```

# 6 创建jmsco项目其ceph-csi之rbd的StorageClass资源对象
```
kubectl apply -f ./03.sc_jmsco-ceph-csi-rbd/ --dry-run=client
kubectl apply -f ./03.sc_jmsco-ceph-csi-rbd/
```

# 7 实践
```
参考 ./04.jmsco-project/
```



