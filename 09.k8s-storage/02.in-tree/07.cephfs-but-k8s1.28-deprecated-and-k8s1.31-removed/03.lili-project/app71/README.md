## 1.特别说明
```
01：wyc项目的各worker node上要安装ceph-common软件包。
02：此目录的manifests在应用前,需要将wyc项目其在ceph存储系统中cephfs相关用户(client.wycfs)的
    secret放在wyc所在worker node上。
```

## 2. 应用 deploy_app01.yaml 这个manifests
```
##应用manifests
  root@k8s-master01:~/tools/storage/01.pods-to-storagesystem/09.cephfs-and-rbd-volume-type/cephfs-volume-type/03.wyc-project-apps/app01# kubectl apply -f deploy_app01.yaml 
  deployment.apps/app01 created

##列出相应的资源对象
  root@k8s-master01:~/tools/storage/01.pods-to-storagesystem/09.cephfs-and-rbd-volume-type/cephfs-volume-type/03.wyc-project-apps/app01# kubectl get -f deploy_app01.yaml 
  NAME    READY   UP-TO-DATE   AVAILABLE   AGE
  app01   2/2     2            2           22s

##找到相应资源对象其最新的rs资源对象
  root@k8s-master01:~/tools/storage/01.pods-to-storagesystem/09.cephfs-and-rbd-volume-type/cephfs-volume-type/03.wyc-project-apps/app01# kubectl describe -f deploy_app01.yaml  | grep NewReplicaSet: | cut -d " " -f4
  app01-d6dbf868

##通过最新rs资源对象的name,找到所有的Pod副本
  root@k8s-master01:~/tools/storage/01.pods-to-storagesystem/09.cephfs-and-rbd-volume-type/cephfs-volume-type/03.wyc-project-apps/app01# kubectl get pods -n wyc -o wide | grep app01-d6dbf868
  app01-d6dbf868-ltf9v   1/1     Running   0          2m    10.244.5.115   k8s-node03.magedu.com   <none>           <none>
  app01-d6dbf868-xmmv4   1/1     Running   0          2m    10.244.4.144   k8s-node02.magedu.com   <none>           <none>
```


## 3.以 pods/app01-d6dbf868-ltf9v 为视角
```
##通过描述信息查看相应的volume
  root@k8s-master01:~# kubectl describe pods/app01-d6dbf868-ltf9v -n wyc   | grep -A 10000 "Volumes:" | grep -B 10000 "QoS Class:" | sed '$'d
  Volumes:
    logs:       <== 看这,其type为cephfs
      Type:        CephFS (a CephFS mount on the host that shares a pod's lifetime)
      Monitors:    [172.31.7.211:6789 172.31.7.212:6789 172.31.7.213:6789]
      Path:        /volumes/app01/logs/9b573841-abed-419e-b8f8-c8a18c50930b
      User:        wyc
      SecretFile:  /etc/ceph/ceph.client.wycfs.secret
      SecretRef:   nil
      ReadOnly:    false
    kube-api-access-f5n6h:
      Type:                    Projected (a volume that contains injected data from multiple sources)
      TokenExpirationSeconds:  3607
      ConfigMapName:           kube-root-ca.crt
      ConfigMapOptional:       <nil>
      DownwardAPI:             true

##找到其uid
  root@k8s-master01:~# kubectl get pods/app01-d6dbf868-ltf9v -n wyc -o yaml | grep uid | tail -1
    uid: fa32a519-7bc2-4af9-814e-9a366dd877d8

##到相应woker node上看看是否有mount(有的),看看挂载点下的内容
  root@k8s-node03:~# df -h | grep fa32a519-7bc2-4af9-814e-9a366dd877d8
  tmpfs     3.8G   12K  3.8G   1% /var/lib/kubelet/pods/fa32a519-7bc2-4af9-814e-9a366dd877d8/volumes/kubernetes.io~projected/kube-api-access-f5n6h
  172.31.7.211:6789,172.31.7.212:6789,172.31.7.213:6789:/volumes/app01/logs/9b573841-abed-419e-b8f8-c8a18c50930b  474G     0  474G   0% /var/lib/kubelet/pods/fa32a519-7bc2-4af9-814e-9a366dd877d8/volumes/kubernetes.io~cephfs/logs

  root@k8s-node03:~# ll /var/lib/kubelet/pods/fa32a519-7bc2-4af9-814e-9a366dd877d8/volumes/kubernetes.io~cephfs/logs
  total 12
  drwxr-xr-x 2 root root    2 Jun 26 08:25 ./
  drwxr-x--- 3 root root 4096 Jun 26 09:56 ../
  -rw-r--r-- 1 root root  273 Jun 26 08:27 access.log
  -rw-r--r-- 1 root root 7358 Jun 26 09:56 error.log

##到此Pod副本的app01容器中看看mount(有的),看看挂载点下的内容
  root@k8s-master01:~# kubectl exec -it pods/app01-d6dbf868-ltf9v -c app01 -n wyc -- df -h
  Filesystem                                                                                                       Size  Used Avail Use% Mounted on
  overlay                                                                                                           98G   15G   79G  16% /
  tmpfs                                                                                                             64M     0   64M   0% /dev
  tmpfs                                                                                                            2.0G     0  2.0G   0% /sys/fs/cgroup
  /dev/sda2                                                                                                         98G   15G   79G  16% /etc/hosts
  shm                                                                                                               64M     0   64M   0% /dev/shm
  172.31.7.211:6789,172.31.7.212:6789,172.31.7.213:6789:/volumes/app01/logs/9b573841-abed-419e-b8f8-c8a18c50930b  474G     0  474G   0% /var/log/nginx   # <== 看这
  tmpfs                                                                                                            3.8G   12K  3.8G   1% /run/secrets/kubernetes.io/serviceaccount
  tmpfs                                                                                                            2.0G     0  2.0G   0% /proc/acpi
  tmpfs                                                                                                            2.0G     0  2.0G   0% /proc/scsi
  tmpfs                                                                                                            2.0G     0  2.0G   0% /sys/firmware

  root@k8s-master01:~# kubectl exec -it pods/app01-d6dbf868-ltf9v -c app01 -n wyc -- ls -la /var/log/nginx
  total 12
  drwxr-xr-x 2 root root    2 Jun 26 00:25 .
  drwxr-xr-x 1 root root 4096 Dec 29  2021 ..
  -rw-r--r-- 1 root root  273 Jun 26 00:27 access.log
  -rw-r--r-- 1 root root 7358 Jun 26 01:56 error.log
```


## 4.以 pods/app01-d6dbf868-xmmv4 为视角
```
  参考 "2.以 pods/app01-d6dbf868-ltf9v 为视角"
```


## 5.清理环境
```
  kubectl get    -f ./deploy_app01.yaml
  kubectl delete -f ./deploy_app01.yaml
  kubectl get    -f ./deploy_app01.yaml
```
