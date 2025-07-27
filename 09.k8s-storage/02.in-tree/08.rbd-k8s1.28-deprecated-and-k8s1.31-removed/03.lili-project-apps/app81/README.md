## 1.特别说明
```
01: wyc项目的各worker node上要安装ceph-common软件包。
02: 此目录下的实践(manifests),需要k8s管理员将wyc项目
    其在ceph中rbd存储相关用户(client.wycrbd)的keyring文
    件拷贝至wyc项目相关的woker node上。
```

## 2. 应用 deploy_app01.yaml 这个manifests
```
##应用manifests
  root@k8s-master01:~/tools/storage/01.pods-to-storagesystem/09.cephfs-and-rbd-volume-type/rbd-volume-type/03.wyc-project-apps/app01# kubectl apply -f deploy_app01.yaml
  deployment.apps/app01 created

##列出相应的资源对象
  root@k8s-master01:~/tools/storage/01.pods-to-storagesystem/09.cephfs-and-rbd-volume-type/rbd-volume-type/03.wyc-project-apps/app01# kubectl get -f deploy_app01.yaml
  NAME    READY   UP-TO-DATE   AVAILABLE   AGE
  app01   1/1     2            2           22s

##找到相应资源对象其最新的rs资源对象
  root@k8s-master01:~/tools/storage/01.pods-to-storagesystem/09.cephfs-and-rbd-volume-type/rbd-volume-type/03.wyc-project-apps/app01#  kubectl describe -f deploy_app01.yaml  | grep NewReplicaSet: | cut -d " " -f4
  app01-784c8b5945

##通过最新rs资源对象的name,找到所有的Pod副本
  root@k8s-master01:~/tools/storage/01.pods-to-storagesystem/09.cephfs-and-rbd-volume-type/rbd-volume-type/03.wyc-project-apps/app01# kubectl get pods -n wyc -o wide | grep app01-784c8b5945
  app01-784c8b5945-knj87   1/1     Running   0          65s   10.244.5.121   k8s-node03.magedu.com   <none>           <none>
```


## 3.以 pods/app01-784c8b5945-knj87 为视角
```
##通过描述信息查看相应的volume
  root@k8s-master01:~# kubectl describe pods/app01-784c8b5945-knj87 -n wyc   | grep -A 10000 "Volumes:" | grep -B 10000 "QoS Class:" | sed '$'d
  Volumes:
    data:       <== 看这
      Type:          RBD (a Rados Block Device mount on the host that shares a pod's lifetime)  # <== 卷类型
      CephMonitors:  [172.31.7.211:6789 172.31.7.212:6789 172.31.7.213:6789]                    # <== Ceph存储系统其Monitors组件的各实例
      RBDImage:      app01-data                                                                 # <== RBDImage的name
      FSType:        ext4                                                                       # <== RBDImage被挂载前格式成什么文件系统模式
      RBDPool:       rbd-wyc-project-data                                                       # <== RBDImage所在的存储池
      RadosUser:     wycrbd                                                                     # <== 认证用户
      Keyring:       /etc/ceph/ceph.client.wycrbd.keyring                                       # <== 用户的密钥环(得在各woker node上存在)
      SecretRef:     nil                                                                        # <== 其Keyring和SecretRef是两种指定用户密钥的方式,此SecretRef是指k8s中的secrets资源对象
      ReadOnly:      false                                                                      # <== Pod级别中其volume对只读的限制,false表示可读写
    kube-api-access-fnglm:
      Type:                    Projected (a volume that contains injected data from multiple sources)
      TokenExpirationSeconds:  3607
      ConfigMapName:           kube-root-ca.crt
      ConfigMapOptional:       <nil>
      DownwardAPI:             true


##到相应woker node上看看是否有mount(有的),看看挂载点下的内容
  root@k8s-node03:~# df -Th | grep rbd-wyc-project-data        # 其过滤的是上面看到的RBDPool,若指定全的话就是<RBDPool>-<image>-<RBDImage>
  /dev/rbd0      ext4      4.9G   20M  4.9G   1% /var/lib/kubelet/plugins/kubernetes.io/rbd/mounts/rbd-wyc-project-data-image-app01-data
     #
     #  可看到被格式化成了ext4文件系统
     #  第一个4.9G是指rbd image的大小,我在ceph中rbd-wyc-project-data的pool中创建app01-data image时,指定大小是5G
     #  从挂载点中,可看到没有Pod的uid。
     #

  root@k8s-node03:~# ls -l /var/lib/kubelet/plugins/kubernetes.io/rbd/mounts/rbd-wyc-project-data-image-app01-data
  total 16
  drwx------ 2 root root 16384 Jun 27 08:54 lost+found

##到此Pod副本的app01容器中看看mount(有的),看看挂载点下的内容
  root@k8s-master01:~# kubectl exec -it pods/app01-784c8b5945-knj87 -c app01 -n wyc -- df -h
  Filesystem                Size      Used Available Use% Mounted on
  overlay                  97.9G     14.3G     78.6G  15% /
  tmpfs                    64.0M         0     64.0M   0% /dev
  tmpfs                     1.9G         0      1.9G   0% /sys/fs/cgroup
  /dev/rbd0                 4.9G     20.0M      4.8G   0% /data            <== 看这
  /dev/sda2                97.9G     14.3G     78.6G  15% /dev/termination-log
  /dev/sda2                97.9G     14.3G     78.6G  15% /etc/resolv.conf
  /dev/sda2                97.9G     14.3G     78.6G  15% /etc/hostname
  /dev/sda2                97.9G     14.3G     78.6G  15% /etc/hosts
  shm                      64.0M         0     64.0M   0% /dev/shm
  tmpfs                     3.7G     12.0K      3.7G   0% /var/run/secrets/kubernetes.io/serviceaccount
  tmpfs                     1.9G         0      1.9G   0% /proc/acpi
  tmpfs                    64.0M         0     64.0M   0% /proc/kcore
  tmpfs                    64.0M         0     64.0M   0% /proc/keys
  tmpfs                    64.0M         0     64.0M   0% /proc/timer_list
  tmpfs                    64.0M         0     64.0M   0% /proc/sched_debug
  tmpfs                     1.9G         0      1.9G   0% /proc/scsi
  tmpfs                     1.9G         0      1.9G   0% /sys/firmware

  root@k8s-master01:~# kubectl exec -it pods/app01-784c8b5945-knj87 -c app01 -n wyc -- ls -la /data
  total 24
  drwxr-xr-x    3 root     root          4096 Jun 27 00:54 .
  drwxr-xr-x    1 root     root          4096 Jun 27 01:08 ..
  drwx------    2 root     root         16384 Jun 27 00:54 lost+found

##到此Pod副本的app01容器中看看mount(有的),到挂载点下生成相应的数据
  root@k8s-master01:~# kubectl exec -it pods/app01-784c8b5945-knj87 -c app01 -n wyc -- touch /data/app01.txt
  root@k8s-master01:~# 
  root@k8s-master01:~# kubectl exec -it pods/app01-784c8b5945-knj87 -c app01 -n wyc -- ls -la /data
  total 24
  drwxr-xr-x    3 root     root          4096 Jun 27 01:24 .
  drwxr-xr-x    1 root     root          4096 Jun 27 01:08 ..
  -rw-r--r--    1 root     root             0 Jun 27 01:24 app01.txt
  drwx------    2 root     root         16384 Jun 27 00:54 lost+found

##到相应worker node上,查看相应挂载点下的内容（是有的）
  root@k8s-node03:~# ls -l /var/lib/kubelet/plugins/kubernetes.io/rbd/mounts/rbd-wyc-project-data-image-app01-data
  total 16
  -rw-r--r-- 1 root root     0 Jun 27 09:24 app01.txt
  drwx------ 2 root root 16384 Jun 27 08:54 lost+found
```


## 4.销毁Pod后重建,再到Pod中看是否有相应的数据(肯定是有的)
```
##销毁Pod重建
  kubectl delete -f ./deploy_app01.yaml
  kubectl apply  -f ./deploy_app01.yaml
  kubectl get    -f ./deploy_app01.yaml 

##列出Pod中其app01容器其挂载点/data下的文件(有的,就是之前产生的数据)
  root@k8s-master01:~/tools/storage/01.pods-to-storagesystem/09.cephfs-and-rbd-volume-type/rbd-volume-type/03.wyc-project-apps/app01# kubectl exec -it pods/$(kubectl get pods -n wyc | grep $(kubectl describe  -f ./deploy_app01.yaml  | grep NewReplicaSet: | cut -d " " -f 4)) -n wyc -- ls -la /data
  total 24
  drwxr-xr-x    3 root     root          4096 Jun 27 01:24 .
  drwxr-xr-x    1 root     root          4096 Jun 27 01:28 ..
  -rw-r--r--    1 root     root             0 Jun 27 01:24 app01.txt
  drwx------    2 root     root         16384 Jun 27 00:54 lost+found
```

## 5.清理环境
```
  kubectl get    -f ./deploy_app01.yaml
  kubectl delete -f ./deploy_app01.yaml
  kubectl get    -f ./deploy_app01.yaml
```
