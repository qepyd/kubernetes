```
## 应用manifests
root@master01:~# kubectl apply -f deploy_app72.yaml --dry-run=client
deployment.apps/app72 created (dry run)
root@master01:~#
root@master01:~#
root@master01:~# kubectl apply -f deploy_app02.yaml 
deployment.apps/app72 created

## 列出相平面资源对象
root@master01:~# kubectl  -n lili get deploy/app72
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
app72   2/2     2            2           119s

## 列出deploy/app72其最新的rs资源对象
root@master01:~# kubectl  -n lili describe deploy/app72 | grep "NewReplicaSet:" | cut -d " " -f4 
app72-5bdfb54fbd
root@master01:~#
root@master01:~# kubectl -n lili get rs/app72-5bdfb54fbdNAME               DESIRED   CURRENT   READY   AGE
app72-5bdfb54fbd   2         2         2       3m10s

## 列出deploy/app72所编排的Pod
root@master01:~# kubectl  -n lili get pods -o wide | grep app72-5bdfb54fbd
app72-5bdfb54fbd-lshdl   1/1     Running   0          3m44s   10.0.4.7   node02   <none>           <none>
app72-5bdfb54fbd-ww7dt   1/1     Running   0          3m44s   10.0.3.8   node01   <none>           <none>


## 以node01上其pods/app72-5bdfb54fbd-ww7dt为例查看相关卷
root@master01:~# kubectl -n lili get pods/app72-5bdfb54fbd-ww7dt -o json | jq ".metadata.uid"
"996dd614-0a98-49fe-8a77-214ac8ae626a"

root@node01:~# df -h | grep 996dd614-0a98-49fe-8a77-214ac8ae626a
tmpfs                                                                                                           3.7G   12K  3.7G   1% /var/lib/kubelet/pods/996dd614-0a98-49fe-8a77-214ac8ae626a/volumes/kubernetes.io~projected/kube-api-access-h792k
172.31.8.201:6789,172.31.8.202:6789,172.31.8.203:6789:/volumes/app72/data/450d8c88-4bc6-4ed1-b369-4fddcf68ef35  474G     0  474G   0% /var/lib/kubelet/pods/996dd614-0a98-49fe-8a77-214ac8ae626a/volumes/kubernetes.io~cephfs/share-data


## 以node02上其pods/app72-5bdfb54fbd-lshdl为例查看相关卷
参考上述操作


## 删除deploy/app72对象
kubectl delete -f deploy_app72.yaml 
```
