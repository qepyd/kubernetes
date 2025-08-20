01：此阶段还是jmsco项目，即继 ../06.static-pv-use-csi-InTreeVolumePlugin/ 。
```
需要用到其创建的相关secrets资源对象，即：
../06.static-pv-use-csi-InTreeVolumePlugin/03.jmsco-project/secrets_jmsco-project-ceph-fs-in-jmscofs-user-key/
../06.static-pv-use-csi-InTreeVolumePlugin/03.jmsco-project/secrets_jmsco-project-ceph-rbd-in-jmscorbd-user-key/
```

02：其 ../05.K8s-Internal-Install-ExternalCsiVolumeDriver/ceph-csi/v3.14.2/ 处需要完全部署
```
## 通用配置
../05.K8s-Internal-Install-ExternalCsiVolumeDriver/ceph-csi/v3.14.2/01.currency/

## ceph-csi其cephfs的NodePlugin、CsiController和csidrivers资源对象
../05.K8s-Internal-Install-ExternalCsiVolumeDriver/ceph-csi/v3.14.2/02.cephfs/

## ceph-csi其rbd的NodePlugin、CsiController和csidrivers资源对象
../05.K8s-Internal-Install-ExternalCsiVolumeDriver/ceph-csi/v3.14.2/03.rbd/
```



