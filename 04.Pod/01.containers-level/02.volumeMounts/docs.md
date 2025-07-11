**应用manifests**
```
root@master01:~# kubectl apply -f pods_volumemounts.yaml --dry-run=client
pod/volumemounts created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f pods_volumemounts.yaml
pod/volumemounts created
```

**列出资源对象**
```
root@master01:~# kubectl -n lili get Pod/volumemounts
NAME           READY   STATUS    RESTARTS   AGE
volumemounts   1/1     Running   0          81s
```

**查看Pod/volumemounts对象中其myapp01主容器里面的/data/lili.txt文件**
```
root@master01:~# kubectl -n lili exec -it Pod/volumemounts -c myapp01 -- ls -l /data/
total 4
-rw-r--r-- 1 root root 3 Jul 11 08:39 lili.txt
root@master01:~#
root@master01:~# kubectl -n lili exec -it Pod/volumemounts -c myapp01 -- cat /data/lili.txt
cl
```

**清理环境**
```
kubectl delete -f  pods_volumemounts.yaml
```
