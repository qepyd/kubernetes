# 1.Pod的生命周期
Pod中可以有多个容器(多个initContainers、多个containers)，initContainers是串行启动完成工作
后退出，而containers是串行启动且不会退出。 initContainers、containers都会有如下hook和probe。
```
post start hook  # 启动后做什么操作，非周期性。
startup probe    # 启动性探测，非周期性。
livenessProbe    # 存活性探测，周期性的。
readinessProbe   # 就绪性探测，周期性的。
pre stop hook    # 停止前做什么操作，非周期性。
```
此图只展示了pods.spec.containers中各容器的hook和probe
<image src="./picture/pod-lifecycle.jpg" style="width: 100%; height: auto;">


# 2.startupProbe
```
非周期性
```
# 2.1 startupprobe-non-periodic
**应用manifests**
```
root@master01:~# kubectl apply -f 01.startupprobe-non-periodic.yaml  --dry-run=client
pod/startupprobe-non-periodic created (dry run)
service/startupprobe-non-periodic created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 01.startupprobe-non-periodic.yaml 
pod/startupprobe-non-periodic created
service/startupprobe-non-periodic created
```

**观察Pod资源对象**
```
root@master01:~# kubectl -n lili get pod/startupprobe-non-periodic -o wide -w
NAME                        READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
startupprobe-non-periodic   0/1     Running   0          13s   10.0.4.57   node02   <none>           <none>
startupprobe-non-periodic   0/1     Running   0          36s   10.0.4.57   node02   <none>           <none>
startupprobe-non-periodic   1/1     Running   0          36s   10.0.4.57   node02   <none>           <none>
     #
     # 可看到 Pod/startupprobe-non-periodic 中的所有主容器均已就绪(READY)
     # 只有Pod中所有主容器 READY 后，才会成为其svc资源对象的后端
```

**列出svc资源对象和ep资源对象(svc资源对象创建的)**
```
root@master01:~# kubectl -n lili get svc/startupprobe-non-periodic
NAME                        TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
startupprobe-non-periodic   ClusterIP   11.8.185.224   <none>        80/TCP    53s
root@master01:~#
root@master01:~# kubectl -n lili get ep/startupprobe-non-periodic
NAME                        ENDPOINTS      AGE
startupprobe-non-periodic   10.0.4.57:80   58s
```

**再观察Pod资源对象**
```
kubectl -n lili get pod/startupprobe-non-periodic -o wide -w
   #
   # 主要看到 RESTARTS 字段的值。
   # 当后面的操作后，其RESTARTS字段的值始终为0，说明startupProbe是非周期性的。
   #
```

**更改Pod资源对象中demoapp容器里面应用其/readyz的值为FAIL**
```
root@master01:~# kubectl -n lili exec -it pod/startupprobe -c demoapp -- curl 127.0.0.1/readyz
OK
root@master01:~# kubectl -n lili exec -it pod/startupprobe -c demoapp -- curl -XPOST -d "readyz=FAIL" 127.0.0.1/readyz
root@master01:~#
root@master01:~# kubectl -n lili exec -it pod/startupprobe -c demoapp -- curl 127.0.0.1/readyz 
FAIL
```



