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

## 2.3 startupprobe-non-periodic
**应用manifests**
```
root@master01:~#  kubectl apply -f 03.startupprobe-non-periodic.yaml  --dry-run=client
pod/startupprobe-non-periodic created (dry run)
service/startupprobe-non-periodic created (dry run)
root@master01:~# 
root@master01:~# kubectl apply -f 03.startupprobe-non-periodic.yaml 
pod/startupprobe-non-periodic created
service/startupprobe-non-periodic created
```

**Pod中各容器已就绪(watch到的pod、svc、ep)**
```
root@master01:~# kubectl -n lili get pods -o wide -w
NAME                        READY   STATUS              RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
startupprobe-non-periodic   0/1     Pending             0          0s    <none>      <none>   <none>           <none>
startupprobe-non-periodic   0/1     Pending             0          0s    <none>      node02   <none>           <none>
startupprobe-non-periodic   0/1     ContainerCreating   0          0s    <none>      node02   <none>           <none>
startupprobe-non-periodic   0/1     Running             0          2s    10.0.4.88   node02   <none>           <none>
startupprobe-non-periodic   0/1     Running             0          86s   10.0.4.88   node02   <none>           <none>
startupprobe-non-periodic   1/1     Running             0          86s   10.0.4.88   node02   <none>           <none>
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁
   #
   # Pod中各主容器均已就绪
   #

root@master01:~# kubectl -n lili get svc  -w
NAME                        TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
startupprobe-non-periodic   ClusterIP   11.0.60.16   <none>        80/TCP    0s
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁

root@master01:~# kubectl -n lili get ep  -w
NAME                        ENDPOINTS   AGE
startupprobe-non-periodic   <none>      0s
startupprobe-non-periodic               2s
startupprobe-non-periodic   10.0.4.88:80   86s
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁
```

**在线修改探测处结果的值(让其探测失败)**
```
root@master01:~# kubectl -n lili exec -it pod/startupprobe-non-periodic -c demoapp  -- curl 127.0.0.1/readyz
OK

root@master01:~# kubectl -n lili exec -it pod/startupprobe-non-periodic -c demoapp -- curl -XPOST -d "readyz=FAIL" 127.0.0.1/readyz
root@master01:~# 

root@master01:~# kubectl -n lili exec -it pod/startupprobe-non-periodic -c demoapp -- curl 127.0.0.1/readyz
FAIL
```

**watch到的pod、svc、ep**
```
root@master01:~# kubectl -n lili get pods -o wide -w
NAME                        READY   STATUS              RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
startupprobe-non-periodic   0/1     Pending             0          0s    <none>      <none>   <none>           <none>
startupprobe-non-periodic   0/1     Pending             0          0s    <none>      node02   <none>           <none>
startupprobe-non-periodic   0/1     ContainerCreating   0          0s    <none>      node02   <none>           <none>
startupprobe-non-periodic   0/1     Running             0          2s    10.0.4.88   node02   <none>           <none>
startupprobe-non-periodic   0/1     Running             0          86s   10.0.4.88   node02   <none>           <none>
startupprobe-non-periodic   1/1     Running             0          86s   10.0.4.88   node02   <none>           <none>
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁
	#
	# 不会重启(RESTARTS字段的值始终是0)
	# 也不会影响其加入svc的后端端点，READY字段的值始终是1/1
	# 

root@master01:~# kubectl -n lili get svc  -w
NAME                        TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
startupprobe-non-periodic   ClusterIP   11.0.60.16   <none>        80/TCP    0s
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁

root@master01:~# kubectl -n lili get ep  -w
NAME                        ENDPOINTS   AGE
startupprobe-non-periodic   <none>      0s
startupprobe-non-periodic               2s
startupprobe-non-periodic   10.0.4.88:80   86s
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁
```

**清理环境**
```
kubectl delete -f 03.startupprobe-non-periodic.yaml
```


# 3 readinessProbe
## 3.1 readinessprobe-failure
**应用manifests**
```
root@master01:~#  kubectl apply -f 04.readinessprobe-failure.yaml  --dry-run=client
pod/readinessprobe-failure created (dry run)
service/readinessprobe-failure created (dry run)
root@master01:~# 
root@master01:~#  kubectl apply -f 04.readinessprobe-failure.yaml 
pod/readinessprobe-failure created
service/readinessprobe-failure created
```

**watch到的pod、svc、ep**
```
root@master01:~# kubectl -n lili get pods -o wide -w
NAME                     READY   STATUS    RESTARTS   AGE   IP       NODE     NOMINATED NODE   READINESS GATES
readinessprobe-failure   0/1     Pending   0          0s    <none>   <none>   <none>           <none>
readinessprobe-failure   0/1     Pending   0          1s    <none>   node02   <none>           <none>
readinessprobe-failure   0/1     ContainerCreating   0          1s    <none>   node02   <none>           <none>
readinessprobe-failure   0/1     Running             0          2s    10.0.4.89   node02   <none>           <none>
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁
  #
  # 影响Pod加入到svc的后端端点。
  # 不会重启(RESTARTS字段的值始终是0)
  # 

root@master01:~# kubectl -n lili get svc  -w
NAME                     TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
readinessprobe-failure   ClusterIP   11.8.43.137   <none>        80/TCP    0s
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁

root@master01:~# kubectl -n lili get ep  -w
NAME                     ENDPOINTS   AGE
readinessprobe-failure   <none>      0s
readinessprobe-failure               1s
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁
```

**清理环境**
```
kubectl delete -f  04.readinessprobe-failure.yaml
```

## 3.2 readinessprobe-is-periodic
**应用manifests**
```
root@master01:~# kubectl apply -f 05.readinessprobe-is-periodic.yaml --dry-run=client
pod/readinessprobe-is-periodic created (dry run)
service/readinessprobe-is-periodic created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 05.readinessprobe-is-periodic.yaml 
pod/readinessprobe-is-periodic created
service/readinessprobe-is-periodic created
```

**Pod中的主容器已就绪(watch到的pod、svc、ep)**
```
root@master01:~# kubectl -n lili get pods -o wide -w
NAME                         READY   STATUS              RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
readinessprobe-is-periodic   0/1     Pending             0          0s    <none>      <none>   <none>           <none>
readinessprobe-is-periodic   0/1     Pending             0          0s    <none>      node02   <none>           <none>
readinessprobe-is-periodic   0/1     ContainerCreating   0          0s    <none>      node02   <none>           <none>
readinessprobe-is-periodic   0/1     Running             0          1s    10.0.4.90   node02   <none>           <none>
readinessprobe-is-periodic   1/1     Running             0          85s   10.0.4.90   node02   <none>           <none>
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁
	#
	# pod中的主容器已就绪
	#

root@master01:~# kubectl -n lili get svc  -w
NAME                         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
readinessprobe-is-periodic   ClusterIP   11.9.98.93   <none>        80/TCP    0s
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁

root@master01:~# kubectl -n lili get ep  -w
NAME                         ENDPOINTS   AGE
readinessprobe-is-periodic   <none>      0s
readinessprobe-is-periodic               1s
readinessprobe-is-periodic   10.0.4.90:80   85s
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁
```


**在线修改探测处结果的值(让其探测失败)**
```
root@master01:~# kubectl -n lili exec -it pod/readinessprobe-is-periodic -c demoapp  -- curl 127.0.0.1/readyz
OK

root@master01:~# kubectl -n lili exec -it pod/readinessprobe-is-periodic -c demoapp -- curl -XPOST -d "readyz=FAIL" 127.0.0.1/readyz
root@master01:~# 

root@master01:~# kubectl -n lili exec -it pod/readinessprobe-is-periodic -c demoapp -- curl 127.0.0.1/readyz
FAIL
```

**watch到的pod、svc、ep**
```
root@master01:~# kubectl -n lili get pods -o wide -w
NAME                         READY   STATUS              RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
readinessprobe-is-periodic   0/1     Pending             0          0s    <none>      <none>   <none>           <none>
readinessprobe-is-periodic   0/1     Pending             0          0s    <none>      node02   <none>           <none>
readinessprobe-is-periodic   0/1     ContainerCreating   0          0s    <none>      node02   <none>           <none>
readinessprobe-is-periodic   0/1     Running             0          1s    10.0.4.90   node02   <none>           <none>
readinessprobe-is-periodic   1/1     Running             0          85s   10.0.4.90   node02   <none>           <none>
readinessprobe-is-periodic   0/1     Running             0          4m    10.0.4.90   node02   <none>           <none>
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁
	#
	# pod中的主容器未就绪(即READY字段的值为0/1)
	# Pod中的主容器是不会重启的
	# 

root@master01:~# kubectl -n lili get svc  -w
NAME                         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
readinessprobe-is-periodic   ClusterIP   11.9.98.93   <none>        80/TCP    0s
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁

root@master01:~# kubectl -n lili get ep  -w
NAME                         ENDPOINTS   AGE
readinessprobe-is-periodic   <none>      0s
readinessprobe-is-periodic               1s
readinessprobe-is-periodic   10.0.4.90:80   85s
readinessprobe-is-periodic                  4m
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁
```

**在线修改探测处结果的值(让其探测成功)**
```
root@master01:~# kubectl -n lili exec -it pod/readinessprobe-is-periodic -c demoapp -- curl -XPOST -d "readyz=OK" 127.0.0.1/readyz
root@master01:~# 
```

**watch到的pod、svc、ep**
```
root@master01:~# kubectl -n lili get pods -o wide -w
NAME                         READY   STATUS    RESTARTS   AGE   IP       NODE     NOMINATED NODE   READINESS GATES
readinessprobe-is-periodic   0/1     Pending   0          0s    <none>   <none>   <none>           <none>
readinessprobe-is-periodic   0/1     Pending   0          0s    <none>   node02   <none>           <none>
readinessprobe-is-periodic   0/1     ContainerCreating   0          0s    <none>   node02   <none>           <none>
readinessprobe-is-periodic   0/1     Running             0          1s    10.0.4.90   node02   <none>           <none>
readinessprobe-is-periodic   1/1     Running             0          85s   10.0.4.90   node02   <none>           <none>
readinessprobe-is-periodic   0/1     Running             0          4m    10.0.4.90   node02   <none>           <none>
readinessprobe-is-periodic   1/1     Running             0          6m    10.0.4.90   node02   <none>           <none>
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁
  #
  # Pod中的主容器又就绪了(即READY字段的值为1/1)
  # Pod中的主容器是不会重启的
  
root@master01:~# kubectl -n lili get svc  -w
NAME                         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
readinessprobe-is-periodic   ClusterIP   11.9.98.93   <none>        80/TCP    0s
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁

root@master01:~# kubectl -n lili get ep  -w
NAME                         ENDPOINTS   AGE
readinessprobe-is-periodic   <none>      0s
readinessprobe-is-periodic               1s
readinessprobe-is-periodic   10.0.4.90:80   85s
readinessprobe-is-periodic                  4m
readinessprobe-is-periodic   10.0.4.90:80   6m
光标在闪烁,光标在闪烁,光标在闪烁,光标在闪烁
```

**清理环境**
```
kubectl delete -f  05.readinessprobe-is-periodic.yaml
```

