```
## 应用manifests
root@master01:~# kubectl apply -f pods_app81.yaml  --dry-run=client
pod/app81 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f pods_app81.yaml
pod/app81 created


## 列出资源对象
root@master01:~# kubectl  -n lili get pod/app81 -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP         NODE     NOMINATED NODE   READINESS GATES
app81   1/1     Running   0          29s   10.0.4.9   node02   <none>           <none>


## 查看pods/app81对象其Pod级别的卷
root@master01:~# kubectl  -n lili get pod/app81 -o json | jq ".spec.volumes[].name"
"rbd-volume-data"             # 是这个
"kube-api-access-vdpbl"
root@master01:~#
root@master01:~# kubectl  -n lili get pod/app81 -o json | jq ".spec.volumes[0]"
{
  "name": "rbd-volume-data",
  "rbd": {
    "fsType": "ext4",
    "image": "app81-data",
    "keyring": "/etc/ceph/ceph.client.lilirbd.keyring",
    "monitors": [
      "172.31.8.201:6789",
      "172.31.8.202:6789",
      "172.31.8.203:6789"
    ],
    "pool": "rbd-lili-project-data",
    "user": "lilirbd"
  }
}


## 到pods/app81对象所在worker node上查看挂载
#  其挂载路径为：/var/lib/kubelet/plugins/kubernetes.io/rbd/mounts/<rbd的pool>-<关键字image>-<具体的image>
#  那么这里的为：/var/lib/kubelet/plugins/kubernetes.io/rbd/mounts/rbd-lili-project-data-image-app81-data
root@node02:~#
root@node02:~# df -h | grep  rbd-lili-project-data-image-app81-data
/dev/rbd0       4.9G   24K  4.9G   1% /var/lib/kubelet/plugins/kubernetes.io/rbd/mounts/rbd-lili-project-data-image-app81-data


## 删除pods/app81对象
kubectl delete -f pods_app81.yaml
```
