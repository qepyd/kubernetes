## 1.特别说明
```
01: wyc项目的各worker node上要安装ceph-common软件包。
02: 此目录下的实践(manifests),需要k8s管理员将wyc项目
    其在ceph中rbd存储相关用户(client.wycrbd)的secret
    交付到k8s中(以secrets资源对象),可在 ../secrets_wyc-project-ceph-rbd-in-wycrbd-user-key/ 目录下
    进行修改和创建。

    PS：用这种方法的话,各worker node上就不再需要wycrbd用户的keyring文件了。
```


## 2.再应用deploy_app02.yaml 这个manifests
```
##应用deploy_app02.yaml这个manifests

  root@k8s-master01:~/tools/storage/01.pods-to-storagesystem/09.cephfs-and-rbd-volume-type/rbd-volume-type/03.wyc-project-apps/app02# kubectl apply -f deploy_app02.yaml
  deployment.apps/app02 created
  
##列出其相应的deploy资源对象

  root@k8s-master01:~/tools/storage/01.pods-to-storagesystem/09.cephfs-and-rbd-volume-type/rbd-volume-type/03.wyc-project-apps/app02#  kubectl get -f deploy_app02.yaml
  NAME    READY   UP-TO-DATE   AVAILABLE   AGE
  app02   1/1     2            2           19s

##找到相应deploy资源对象其最新的rs资源对象

  root@k8s-master01:~/tools/storage/01.pods-to-storagesystem/09.cephfs-and-rbd-volume-type/rbd-volume-type/03.wyc-project-apps/app02# kubectl describe -f deploy_app02.yaml   | grep NewReplicaSet: | cut -d " " -f4
  app02-64ccb79ddc

##通过最新的rs资源对象的name,找到相应的Pod副本
  root@k8s-master01:~/tools/storage/01.pods-to-storagesystem/09.cephfs-and-rbd-volume-type/rbd-volume-type/03.wyc-project-apps/app02# kubectl get pods -n wyc  -o wide | grep  app02-64ccb79ddc
  app02-64ccb79ddc-c645f   1/1     Running   0          88s   10.244.5.122   k8s-node03.magedu.com   <none>           <none>
```


## 3. 以 pods/app02-64ccb79ddc-c645f 对象为视角,观察观察
```
##通过其描述信息看看volume
  root@k8s-master01:~# kubectl describe pods/app02-64ccb79ddc-c645f -n wyc | grep -A 10000 "Volumes:" | grep -B 10000 "QoS Class:" | sed '$'d
  Volumes:
    data:
      Type:          RBD (a Rados Block Device mount on the host that shares a pod's lifetime)
      CephMonitors:  [172.31.7.211:6789 172.31.7.212:6789 172.31.7.213:6789]
      RBDImage:      app02-data
      FSType:        ext4
      RBDPool:       rbd-wyc-project-data
      RadosUser:     wycrbd
      Keyring:       /etc/ceph/keyring        # 它是默认值哈,当有SecretRef时,此字段的值不生效,相应worker node上也没有此文件
      SecretRef:     &LocalObjectReference{Name:wyc-project-ceph-rbd-in-wycrbd-user-key,}
      ReadOnly:      false
    kube-api-access-zqhc9:
      Type:                    Projected (a volume that contains injected data from multiple sources)
      TokenExpirationSeconds:  3607
      ConfigMapName:           kube-root-ca.crt
      ConfigMapOptional:       <nil>
      DownwardAPI:             true

##到所在worker node上df -h看一下,是有mount的，再看看挂载点下的内容

  root@k8s-node03:~# df -Th | grep rbd-wyc-project-data-image-app02-data    # RBDPool和RBDImage的组合
  /dev/rbd0      ext4      4.9G   20M  4.9G   1% /var/lib/kubelet/plugins/kubernetes.io/rbd/mounts/rbd-wyc-project-data-image-app02-data

  root@k8s-node03:~# ll /var/lib/kubelet/plugins/kubernetes.io/rbd/mounts/rbd-wyc-project-data-image-app02-data
  total 24
  drwxr-xr-x 3 root root  4096 Jun 27 09:01 ./
  drwxr-x--- 3 root root  4096 Jun 27 09:40 ../
  drwx------ 2 root root 16384 Jun 27 09:01 lost+found/

##进入此Pod副本的app02容器中,df -h看一下,是有mount的，再看看挂载点下的内容

  root@k8s-master01:~# kubectl exec -it pods/app02-64ccb79ddc-c645f -c app02 -n wyc -- df -h
  Filesystem                Size      Used Available Use% Mounted on
  overlay                  97.9G     14.3G     78.6G  15% /
  tmpfs                    64.0M         0     64.0M   0% /dev
  tmpfs                     1.9G         0      1.9G   0% /sys/fs/cgroup
  /dev/rbd0                 4.9G     20.0M      4.8G   0% /data                  # <== 看这
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

  root@k8s-master01:~# kubectl exec -it pods/app02-64ccb79ddc-c645f -c app02 -n wyc -- ls -la /data
  total 24
  drwxr-xr-x    3 root     root          4096 Jun 27 01:01 .
  drwxr-xr-x    1 root     root          4096 Jun 27 01:40 ..
  drwx------    2 root     root         16384 Jun 27 01:01 lost+found

##进入此Pod容器的app02容器中,在其挂载点/data下生成文件
  root@k8s-master01:~#  kubectl exec -it pods/app02-64ccb79ddc-c645f -c app02 -n wyc -- touch /data/app02.txt
  root@k8s-master01:~# 
  root@k8s-master01:~# 
  root@k8s-master01:~# kubectl exec -it pods/app02-64ccb79ddc-c645f -c app02 -n wyc -- ls -la /data
  total 24
  drwxr-xr-x    3 root     root          4096 Jun 27 01:45 .
  drwxr-xr-x    1 root     root          4096 Jun 27 01:40 ..
  -rw-r--r--    1 root     root             0 Jun 27 01:45 app02.txt
  drwx------    2 root     root         16384 Jun 27 01:01 lost+found

##到相应worker node上的挂载点下,看看内容

  root@k8s-node03:~# ll /var/lib/kubelet/plugins/kubernetes.io/rbd/mounts/rbd-wyc-project-data-image-app02-data
  total 24
  drwxr-xr-x 3 root root  4096 Jun 27 09:45 ./
  drwxr-x--- 3 root root  4096 Jun 27 09:40 ../
  -rw-r--r-- 1 root root     0 Jun 27 09:45 app02.txt
  drwx------ 2 root root 16384 Jun 27 09:01 lost+found/
```


## 4.销毁Pod后重建,再到Pod中看是否有相应的数据(肯定是有的)
```
##销毁Pod重建
  kubectl delete -f ./deploy_app02.yaml
  kubectl apply  -f ./deploy_app02.yaml
  kubectl get    -f ./deploy_app02.yaml 

##列出Pod中其app01容器其挂载点/data下的文件(有的,就是之前产生的数据)
  root@k8s-master01:~/tools/storage/01.pods-to-storagesystem/09.cephfs-and-rbd-volume-type/rbd-volume-type/03.wyc-project-apps/app02# kubectl exec -it pods/$(kubectl get pods -n wyc | grep $(kubectl describe  -f ./deploy_app02.yaml  | grep NewReplicaSet: | cut -d " " -f 4)) -n wyc -- ls -la /data
  total 24
  drwxr-xr-x    3 root     root          4096 Jun 27 01:45 .
  drwxr-xr-x    1 root     root          4096 Jun 27 01:49 ..
  -rw-r--r--    1 root     root             0 Jun 27 01:45 app02.txt
  drwx------    2 root     root         16384 Jun 27 01:01 lost+found
```


## 5.清理环境
```
  应该删除 deploy/app02 对象，因为其用到的 secrets/wyc-project-ceph-rbd-in-wycrbd-user-key 对象可能还被其它工作负载所引用
  kubectl delete -f ./deploy_app02.yaml
  kubectl get   -f ./deploy_app02.yaml
```

