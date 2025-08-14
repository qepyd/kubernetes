ceph-csi仅需要部署
```
ceph-csi其cephfs的NodePlugin部分和csidriver。
ceph-csi其rbd的NodePlugin、CsiController(要用到其attacher)部分和csidriver。
   
即：
 ../05.K8s-Internal-Install-ExternalCsiVolumeDriver/ceph-csi/v3.14.2/01.currency/

 ../05.K8s-Internal-Install-ExternalCsiVolumeDriver/ceph-csi/v3.14.2/02.cephfs/01-1.rbac-cephfs-csi-nodeplugin.yaml
 ../05.K8s-Internal-Install-ExternalCsiVolumeDriver/ceph-csi/v3.14.2/02.cephfs/01-2.csi-cephfsplugin.yaml
 ../05.K8s-Internal-Install-ExternalCsiVolumeDriver/ceph-csi/v3.14.2/02.cephfs/csidriver.yaml

 ../05.K8s-Internal-Install-ExternalCsiVolumeDriver/ceph-csi/v3.14.2/03.rbd/
```

此阶段实践"静态pv通过csi卷类型"对接ceph存储系统中的fs、rbd
```
ceph存储系统中要准备好相应的fs volume、rbd image。创建好用户并授权。
静态pv需要指定ceph-csi其cephfs的csidriver、ceph-csi其rbd的csidriver。
静态pv需要指定ceph集群的uid、fs volume、rbd image等。
```
