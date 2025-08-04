```
## 应用manifests
root@master01:~# kubectl apply -f pods_app82.yaml --dry-run=client
pod/app82 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f pods_app82.yaml
pod/app82 created

## 列出资源对象
root@master01:~# kubectl  -n lili get pod/app82 -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
app82   1/1     Running   0          28s   10.0.3.10   node01   <none>           <none>

## 查看pods/app82对象其Pod级别的卷
root@master01:~# kubectl  -n lili get pod/app82 -o json | jq ".spec.volumes[].name"
"rbd-volume-data"             # 是这个
"kube-api-access-tqf8r"
root@master01:~#
root@master01:~# kubectl  -n lili get pod/app82 -o json | jq ".spec.volumes[0]"
{
  "name": "rbd-volume-data",
  "rbd": {
    "fsType": "ext4",
    "image": "app82-data",
    "keyring": "/etc/ceph/keyring",
    "monitors": [
      "172.31.8.201:6789",
      "172.31.8.202:6789",
      "172.31.8.203:6789"
    ],
    "pool": "rbd-lili-project-data",
    "secretRef": {
      "name": "lili-project-ceph-rbd-in-lilirbd-user-key"
    },
    "user": "lilirbd"
  }
}

## 到pods/app82对象所在worker node上查看挂载
#  其挂载路径为：/var/lib/kubelet/plugins/kubernetes.io/rbd/mounts/<rbd的pool>-<关键字image>-<具体的image>
#  那么这里的为：/var/lib/kubelet/plugins/kubernetes.io/rbd/mounts/rbd-lili-project-data-image-app82-data
root@node01:~#
root@node01:~# df -h | grep  rbd-lili-project-data-image-app82-data
/dev/rbd0       4.9G   24K  4.9G   1% /var/lib/kubelet/plugins/kubernetes.io/rbd/mounts/rbd-lili-project-data-image-app82-data

## 删除pods/app82对象
kubectl delete -f pods_app82.yaml
```
