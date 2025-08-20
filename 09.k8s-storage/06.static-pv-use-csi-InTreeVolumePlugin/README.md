01：此阶段实践"使用csi卷类型(树内卷插件)的静态pv"来对接的存储系统是ceph集群的cephfs和rbd。
```
因是静态pv，就得事先在ceph集群中准备好fs volume和image。当然还得指定ceph集群的连接地址、认证信息、fs volume和image。
因使用csi卷类型，就得指定csidrivers资源对象(人为部署ceph-csi之cephfs和rbd的对应csidrivers资源对象)
```

02：其 ../05.K8s-Internal-Install-ExternalCsiVolumeDriver/ceph-csi/v3.14.2/ 处的必要部署有。
```
## 通用配置
../05.K8s-Internal-Install-ExternalCsiVolumeDriver/ceph-csi/v3.14.2/01.currency/

## ceph-csi其cephfs的NodePlugin和csidrivers资源对象
../05.K8s-Internal-Install-ExternalCsiVolumeDriver/ceph-csi/v3.14.2/02.cephfs/01-1.rbac-cephfs-csi-nodeplugin.yaml
../05.K8s-Internal-Install-ExternalCsiVolumeDriver/ceph-csi/v3.14.2/02.cephfs/01-2.csi-cephfsplugin.yaml
../05.K8s-Internal-Install-ExternalCsiVolumeDriver/ceph-csi/v3.14.2/02.cephfs/csidriver.yaml

## ceph-csi其rbd的NodePlugin、CsiController（要用到其attach）和csidrivers资源对象
../05.K8s-Internal-Install-ExternalCsiVolumeDriver/ceph-csi/v3.14.2/03.rbd/
```

