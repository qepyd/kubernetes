```
## 应用manifests
root@master01:~# kubectl apply -f deploy_app71.yaml  --dry-run=client
deployment.apps/app71 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f deploy_app71.yaml 
deployment.apps/app71 created

## 列出相关资源对象
root@master01:~# kubectl -n lili get deploy/app71
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
app71   2/2     2            2           29s

## 查看deploy/app71对象其最新的rs资源对象
root@master01:~# kubectl -n lili describe deploy/app71 | grep "NewReplicaSet:" | cut -d " " -f4
app71-56bd47556b

## 列出相关的pods
root@master01:~# kubectl -n lili get pods -o wide | grep app71-56bd47556b
app71-56bd47556b-nqbh7   1/1     Running   0          47s   10.0.3.7   node01   <none>           <none>
app71-56bd47556b-q8zqc   1/1     Running   0          47s   10.0.4.6   node02   <none>           <none>

## 以node01这个worker node上的pods/app71-56bd47556b-nqbh7为例查看卷
root@master01:~# kubectl -n lili get pods/app71-56bd47556b-nqbh7 -o json | jq ".metadata.uid"
"d9902fd6-5c52-4c5b-8853-7ad250c49cd2"

root@node01:~# df -h | grep d9902fd6-5c52-4c5b-8853-7ad250c49cd2
tmpfs                                                                                                           3.7G   12K  3.7G   1% /var/lib/kubelet/pods/d9902fd6-5c52-4c5b-8853-7ad250c49cd2/volumes/kubernetes.io~projected/kube-api-access-fz2xc
172.31.8.201:6789,172.31.8.202:6789,172.31.8.203:6789:/volumes/app71/data/bd10274b-8792-496a-a1d9-b0f6dc11c8c3  474G     0  474G   0% /var/lib/kubelet/pods/d9902fd6-5c52-4c5b-8853-7ad250c49cd2/volumes/kubernetes.io~cephfs/share-data

## 以node01这个app71-56bd47556b-q8zqc为例查看卷
参考上述的操作

## 删除deploy/app71对象
kubectl delete -f deploy_app71.yaml
```
