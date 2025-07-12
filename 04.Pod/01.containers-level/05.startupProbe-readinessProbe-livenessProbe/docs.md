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
```
startupProbe
  探测失败
    影响Pod加入到svc的后端端点。
    会导致容器的重启。
    若：只有startupProbe,应该考滤到应用程序的启动时长
	即初始探测等待时长(initialDelaySeconds)久一点。
  非周期性
    不会再进行探测了

readinessProbe
  探测失败
    影响Pod加入到svc的后端端点。
    不会导致容器的重启。
    若：只有readinessProbe,应该考滤到应用程序的启动时长
	即初始探测等待时长(initialDelaySeconds)久一点。
  周期性
    探测失败
      影响Pod加入到svc的后端端点。
     不会导致容器的重启。

livenessProbe
  探测失败
    不影响Pod加入到svc的后端端点。
    会导致容器的重启。
    若：只有livenessProbe，应该考滤到应用程序的启动时长，
	即初始探测等待时长(initialDelaySeconds)久一点。
  周期性
    探测失败
      不影响Pod加入到svc的后端端点。
      会导致容器的重启。
```

# 2 startupProbe
## 2.1 startupprobe-failure01
**应用manifests**
```
root@master01:~# kubectl apply -f 01.startupprobe-failure01.yaml  --dry-run=client
pod/startupprobe-failure01 created (dry run)
service/startupprobe-failure01 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 01.startupprobe-failure01.yaml
pod/startupprobe-failure01 created
service/startupprobe-failure01 created
```

**watch到的pod、svc、ep**
```
root@master01:~# kubectl -n lili get pods -o wide -w
NAME                     READY   STATUS            RESTARTS       AGE     IP          NODE     NOMINATED NODE   READINESS GATES
startupprobe-failure01   0/1     Pending             0               0s     <none>      <none>   <none>           <none>
startupprobe-failure01   0/1     Pending             0               0s     <none>      node02   <none>           <none>
startupprobe-failure01   0/1     ContainerCreating   0               0s     <none>      node02   <none>           <none>
startupprobe-failure01   0/1     Running             0               2s     10.0.4.83   node02   <none>           <none>
startupprobe-failure01   0/1     Running             1 (1s ago)      62s    10.0.4.83   node02   <none>           <none>
startupprobe-failure01   0/1     Running             2 (1s ago)      2m2s   10.0.4.83   node02   <none>           <none>
startupprobe-failure01   0/1     Running             3 (1s ago)      3m2s   10.0.4.83   node02   <none>           <none>
startupprobe-failure01   0/1     Running             4 (1s ago)      4m2s   10.0.4.83   node02   <none>           <none>
startupprobe-failure01   0/1     Running             5 (0s ago)      5m1s   10.0.4.83   node02   <none>           <none>
startupprobe-failure01   0/1     CrashLoopBackOff    5 (1s ago)      6m2s   10.0.4.83   node02   <none>           <none>
startupprobe-failure01   0/1     Running             6 (90s ago)     7m31s  10.0.4.83   node02   <none>           <none>
startupprobe-failure01   0/1     CrashLoopBackOff    6 (0s ago)      8m31s  10.0.4.83   node02   <none>           <none>
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁

root@master01:~# kubectl -n lili get svc  -w
NAME                     TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
startupprobe-failure01   ClusterIP   11.1.244.96   <none>        80/TCP    0s
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁

root@master01:~# kubectl -n lili get ep  -w
NAME                     ENDPOINTS   AGE
startupprobe-failure01   <none>      0s
startupprobe-failure01               1s
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁
```

**清理环境**
```
kubectl delete -f 01.startupprobe-failure01.yaml
```

## 2.2 startupprobe-failure02
**应用manifests**
```
root@master01:~# kubectl apply -f 02.startupprobe-failure02.yaml  --dry-run=client
pod/startupprobe-failure02 created (dry run)
service/startupprobe-failure02 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 02.startupprobe-failure02.yaml
pod/startupprobe-failure02 created
service/startupprobe-failure02 created
```

**watch到的pod、svc、ep**
```
root@master01:~# kubectl -n lili get pods -o wide -w
NAME                     READY   STATUS              RESTARTS        AGE    IP          NODE     NOMINATED NODE   READINESS GATES
startupprobe-failure02   0/1     Pending             0               0s     <none>      <none>   <none>           <none>
startupprobe-failure02   0/1     Pending             0               0s     <none>      node02   <none>           <none>
startupprobe-failure02   0/1     ContainerCreating   0               0s     <none>      node02   <none>           <none>
startupprobe-failure02   0/1     Running             0               2s     10.0.4.86   node02   <none>           <none>
startupprobe-failure02   0/1     Running             1 (1s ago)      117s   10.0.4.86   node02   <none>           <none>
startupprobe-failure02   0/1     Running             2 (1s ago)      3m52s  10.0.4.86   node02   <none>           <none>
startupprobe-failure02   0/1     Running             3 (1s ago)      5m47s  10.0.4.86   node02   <none>           <none>
startupprobe-failure02   0/1     Running             4 (1s ago)      7m42s  10.0.4.86   node02   <none>           <none>
startupprobe-failure02   0/1     Running             5 (1s ago)      9m37s  10.0.4.86   node02   <none>           <none>
startupprobe-failure02   0/1     Running             6 (1s ago)      11m    10.0.4.86   node02   <none>           <none>
startupprobe-failure02   0/1     CrashLoopBackOff    6 (1s ago)      13m    10.0.4.86   node02   <none>           <none>
startupprobe-failure02   0/1     Running             7 (2m46s ago)   16m    10.0.4.86   node02   <none>           <none>
startupprobe-failure02   0/1     CrashLoopBackOff    7 (0s ago)      18m    10.0.4.86   node02   <none>           <none>
startupprobe-failure02   0/1     Running             8 (5m1s ago)    23m    10.0.4.86   node02   <none>           <none>
startupprobe-failure02   0/1     Running             9 (1s ago)      25m    10.0.4.86   node02   <none>           <none>
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁

root@master01:~# kubectl -n lili get svc  -w
NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
startupprobe-failure02   ClusterIP   11.5.192.156   <none>        80/TCP    0s
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁

root@master01:~# kubectl -n lili get ep  -w
NAME                     ENDPOINTS   AGE
startupprobe-failure02   <none>      0s
startupprobe-failure02               1s
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁
```

**清理环境**
```
kubectl delete -f 02.startupprobe-failure02.yaml
```
