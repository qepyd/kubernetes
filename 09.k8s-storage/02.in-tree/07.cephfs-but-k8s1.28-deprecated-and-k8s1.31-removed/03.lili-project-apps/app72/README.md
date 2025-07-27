## 1 特别说明
```
01：wyc项目的各worker node上要安装ceph-common软件包。
02：此目录的manifests在应用前,需要将wyc项目其在ceph存储系统中cephfs相关用户(client.wycfs)的
    secret交付到k8s中(存放于secrets资源对象中),可在 ../secrets_wyc-project-cephfs-in-wyc-user-key/目录下
    进行修改和创建。
```

## 2.再应用deploy_app02.yaml 这个manifests
```
##应用deploy_app02.yaml这个manifests

  root@k8s-master01:~/tools/storage/01.pods-to-storagesystem/09.cephfs-and-rbd-volume-type/cephfs-volume-type/03.wyc-project-apps/app02# kubectl apply -f deploy_app02.yaml 
  deployment.apps/app02 created
  
##列出其相应的deploy资源对象

  root@k8s-master01:~/tools/storage/01.pods-to-storagesystem/09.cephfs-and-rbd-volume-type/cephfs-volume-type/03.wyc-project-apps/app02# kubectl get -f deploy_app02.yaml 
  NAME    READY   UP-TO-DATE   AVAILABLE   AGE
  app02   2/2     2            2           19s

##找到相应deploy资源对象其最新的rs资源对象

  root@k8s-master01:~/tools/storage/01.pods-to-storagesystem/09.cephfs-and-rbd-volume-type/cephfs-volume-type/03.wyc-project-apps/app02# kubectl describe -f deploy_app02.yaml   | grep NewReplicaSet: | cut -d " " -f4
  app02-5c5f5b4679

##通过最新的rs资源对象的name,找到相应的Pod副本

  root@k8s-master01:~/tools/storage/01.pods-to-storagesystem/09.cephfs-and-rbd-volume-type/cephfs-volume-type/03.wyc-project-apps/app02# kubectl get pods -n wyc  -o wide | grep  app02-5c5f5b4679
  app02-5c5f5b4679-9qpbz   1/1     Running       0          77s     10.244.5.114   k8s-node03.magedu.com   <none>           <none>
  app02-5c5f5b4679-ns25l   1/1     Running       0          77s     10.244.4.143   k8s-node02.magedu.com   <none>           <none>
```


## 3. 以 pods/app02-5c5f5b4679-9qpbz 对象为视角,观察观察
```
##通过其描述信息看看volume

  root@k8s-master01:~#  kubectl describe pods/app02-5c5f5b4679-9qpbz -n wyc | grep -A 10000 "Volumes:" | grep -B 10000 "QoS Class:" | sed '$'d
  Volumes:
    logs:         # <== 看这,其Type是 cephfs
      Type:        CephFS (a CephFS mount on the host that shares a pod's lifetime)
      Monitors:    [172.31.7.211:6789 172.31.7.212:6789 172.31.7.213:6789]
      Path:        /volumes/app02/logs/417909da-b727-495b-96f2-06da2cca686f
      User:        wycfs
      SecretFile:  
      SecretRef:   &LocalObjectReference{Name:wyc-project-cephfs-in-wycfs-user-key,}
      ReadOnly:    false
    kube-api-access-49scw:
      Type:                    Projected (a volume that contains injected data from multiple sources)
      TokenExpirationSeconds:  3607
      ConfigMapName:           kube-root-ca.crt
      ConfigMapOptional:       <nil>
      DownwardAPI:             true

##找到其uid

  root@k8s-master01:~#  kubectl get pods/app02-5c5f5b4679-9qpbz -n wyc -o yaml | grep uid | tail -1
    uid: 35cca9ed-8ba2-4541-8dd6-3adbf93b3534

##到所在worker node上df -h看一下,是有mount的，再看看挂载点下的内容

  root@k8s-node03:~# df -h | grep 35cca9ed-8ba2-4541-8dd6-3adbf93b3534
  tmpfs   3.8G   12K  3.8G   1% /var/lib/kubelet/pods/35cca9ed-8ba2-4541-8dd6-3adbf93b3534/volumes/kubernetes.io~projected/kube-api-access-49scw
  172.31.7.211:6789,172.31.7.212:6789,172.31.7.213:6789:/volumes/app02/logs/417909da-b727-495b-96f2-06da2cca686f  474G     0  474G   0% /var/lib/kubelet/pods/35cca9ed-8ba2-4541-8dd6-3adbf93b3534/volumes/kubernetes.io~cephfs/logs

  root@k8s-node03:~# ll /var/lib/kubelet/pods/35cca9ed-8ba2-4541-8dd6-3adbf93b3534/volumes/kubernetes.io~cephfs/logs
  total 8
  drwxr-xr-x 2 root root    2 Jun 26 09:30 ./
  drwxr-x--- 3 root root 4096 Jun 26 09:33 ../
  -rw-r--r-- 1 root root  362 Jun 26 09:31 access.log
  -rw-r--r-- 1 root root 2803 Jun 26 09:33 error.log
  root@k8s-node03:~#

##进入此Pod副本的app02容器中,df -h看一下,是有mount的，再看看挂载点下的内容

  root@k8s-master01:~#  kubectl exec -it pods/app02-5c5f5b4679-9qpbz -c app02 -n wyc -- df -h
  Filesystem                                                                                                      Size  Used Avail Use% Mounted on
  overlay                                                                                                          98G   15G   79G  16% /
  tmpfs                                                                                                            64M     0   64M   0% /dev
  tmpfs                                                                                                           2.0G     0  2.0G   0% /sys/fs/cgroup
  /dev/sda2                                                                                                        98G   15G   79G  16% /etc/hosts
  shm                                                                                                              64M     0   64M   0% /dev/shm
  172.31.7.211:6789,172.31.7.212:6789,172.31.7.213:6789:/volumes/app02/logs/417909da-b727-495b-96f2-06da2cca686f  474G     0  474G   0% /var/log/nginx   # <== 看这
  tmpfs                                                                                                           3.8G   12K  3.8G   1% /run/secrets/kubernetes.io/serviceaccount
  tmpfs                                                                                                           2.0G     0  2.0G   0% /proc/acpi
  tmpfs                                                                                                           2.0G     0  2.0G   0% /proc/scsi
  tmpfs                                                                                                           2.0G     0  2.0G   0% /sys/firmware

  root@k8s-master01:~#  kubectl exec -it pods/app02-5c5f5b4679-9qpbz -c app02 -n wyc -- ls -l /var/log/nginx
  total 4
  -rw-r--r-- 1 root root  362 Jun 26 01:31 access.log
  -rw-r--r-- 1 root root 2803 Jun 26 01:33 error.log
```


## 4. 以 pods/app02-5c5f5b4679-ns25l 对象为视角,观察观察
```
   请参考 " 3. 以 pods/app02-5c5f5b4679-9qpbz 对象为视角,观察观察  "
```


## 5.清理环境
```
  应该只删除 deploy/app02 对象，因为其用到的 secrets/wyc-project-cephfs-in-wyc-user-key 对象可能还被其它工作负载所引用
  kubectl delete -f ./deploy_app02.yaml
  kubectl get   -f ./deploy_app02.yaml
```

