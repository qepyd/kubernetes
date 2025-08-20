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

03：这里实践的动态pv其基本说明。
```
先为jmsco项目创建cephfs的sc资源对象、rbd的sc资源对象。
  需指定ceph-csi其cephfs在部署后的csidrivers资源对象。
  需指定ceph-csi其rbd在部署后的csidrivers资源对象。
  需指定ceph集群的id、相关fs volume及pool、相关rbd的pool。
  还得指定其回收策略，动态创建出来的pv会继承。
    当回收策略为Delete时：
      删除与动态pv绑定的pvc后。会回收pv。
      同时会删除ceph集群中的fs volume中的subvolume、rbd相关pool中的image，
      数据丢失。
    当回收策略为Retain时：
      删除与动态pv绑定的的pvc后，不会回收pv。
      当人为回收pv后，不会删除ceph集群中相关fs volume中的subvolume，rbd相关pool中的image。
      当再创建pvc后，又会动态创建pv资源(在ceph fs volume中创建new subvolume，rbd相关pool中创建new image），之前的数据不会被复用。
   
为相关应用创建pvc资源对象(指定sc资源对象)，pod级别使用persistentVolumeClaim卷类型指定所在namespace中的pvc资源对象。
```
