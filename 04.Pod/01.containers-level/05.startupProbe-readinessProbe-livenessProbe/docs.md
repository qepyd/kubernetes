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
**非周期性**  
startupprobe-non-periodic
```
Pod级别定义容器的重启策略(restartPolicy)为Always(默认)。
容器的应用程序能够立即启动成功(10秒内)。
初始探测等待：10秒。
探测超时时长：1秒。
失败的次数为：3
成功的次数为：1
探测的间隔为：10秒。
探测命令(应用程序支持，且我写对了的)
startupProbe探测成功，各主容器均就绪，Pod可成为svc的后端端点(endpoints)。
在线改变主容器中应用其探测处的值。
观察Pod中的容器是否会重启，不会，说明startupProbe是非周期性的。
```

**一直失败会导致死循环重启**  
startupprobe-failure01 和 startupprobe-failure02
```
## 场景1(startupprobe-failure01)
Pod级别定义容器的重启策略(restartPolicy)为Always(默认)。
容器的应用程序能够立即启动成功(10秒内)。
初始探测等待：10秒。
探测超时时长：1秒。
失败的次数为：3
成功的次数为：1
探测的间隔为：10秒。
探测命令(我故意写错)
容器会不断的重启(陷入死循环)，各主容器未完全就绪，Pod不会成为svc的后端端点。
Pod的状态会在 Running 和 CrashLoopBackOff 间切换。

## 场景2(startupprobe-failure02)
Pod级别定义容器的重启策略(restartPolicy)默认为Always。
容器的应用程序300秒后才能够启动成功。
初始探测等待：10秒。
探测超时时长：1秒。
失败的次数为：3
成功的次数为：1
探测的间隔为：10秒。
探测命令(应用支持，且我写对了的)
容器会不断的重启(陷入死循环)，各主容器未就绪，Pod不会成为svc的后端端点。
Pod的状态会在 Running 和 CrashLoopBackOff 间切换。
```

**应该预估出启动时长,再进行首次探测**  
startupprobe-success
```
Pod级别定义容器的重启策略(restartPolicy)默认为Always。
容器的应用程序300秒后才能够启动成功。
初始探测等待：300秒。
探测超时时长：1秒。
失败的次数为：3
成功的次数为：1
探测的间隔为：10秒。
探测命令(应用支持，且我写对了的)
startupProbe探测成功，各主容器均就绪，Pod可成为svc的后端端点(endpoints)。
```

## 2.1 startupprobe-non-periodic
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
    # 可看到 Pod/startupprobe-non-periodic 中的所有主容器均已就绪(READY),各容器的探测(这里是startupProbe)均成功。
    # 只有Pod中所有主容器 READY 后，才会成为其svc资源对象的后端。
    # 
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
root@master01:~# kubectl -n lili exec -it pod/startupprobe-non-periodic -c demoapp -- curl 127.0.0.1/readyz
OK
root@master01:~# kubectl -n lili exec -it pod/startupprobe-non-periodic -c demoapp -- curl -XPOST -d "readyz=FAIL" 127.0.0.1/readyz
root@master01:~#
root@master01:~# kubectl -n lili exec -it pod/startupprobe-non-periodic -c demoapp -- curl 127.0.0.1/readyz 
FAIL
```

## 2.2 startupprobe-failure01
**应用manifests**
```
root@master01:~# kubectl apply -f 02.startupprobe-failure01.yaml  --dry-run=client
pod/startupprobe-failure01 created (dry run)
service/startupprobe-failure01 created (dry run)
root@master01:~#
root@master01:~#
root@master01:~# kubectl apply -f 02.startupprobe-failure01.yaml
pod/startupprobe-failure01 created
service/startupprobe-failure01 created
```

**观察Pod资源对象(不要停止观察)**
```
root@master01:~# kubectl -n lili get Pod/startupprobe-failure01 -o wide -w 
NAME                     READY   STATUS             RESTARTS      AGE     IP          NODE     NOMINATED NODE   READINESS GATES
startupprobe-failure01   0/1     Running            0             7s      10.0.4.59   node02   <none>           <none>
startupprobe-failure01   0/1     Running            1 (1s ago)    71s     10.0.4.59   node02   <none>           <none>
startupprobe-failure01   0/1     Running            2 (1s ago)    2m21s   10.0.4.59   node02   <none>           <none>
startupprobe-failure01   0/1     Running            3 (2s ago)    3m32s   10.0.4.59   node02   <none>           <none>
startupprobe-failure01   0/1     Running            4 (2s ago)    4m42s   10.0.4.59   node02   <none>           <none>
startupprobe-failure01   0/1     Running            5 (1s ago)    5m51s   10.0.4.59   node02   <none>           <none>
startupprobe-failure01   0/1     CrashLoopBackOff   5 (1s ago)    7m1s    10.0.4.59   node02   <none>           <none>
startupprobe-failure01   0/1     Running            6 (83s ago)   8m23s   10.0.4.59   node02   <none>           <none>
startupprobe-failure01   0/1     CrashLoopBackOff   6 (1s ago)    9m31s   10.0.4.59   node02   <none>           <none>
startupprobe-failure01   0/1     CrashLoopBackOff   6 (41s ago)   10m     10.0.4.59   node02   <none>           <none>
startupprobe-failure01   0/1     Running            7 (2m49s ago)   12m   10.0.4.59   node02   <none>           <none>
光标在闪烁
    #
    # Pod中的容器会一陷入重启死循环(因为startupProbe的探测命令我故障写错了)。
    # Pod的状态也会在 Running 和 CrashLoopBackOff 间切换。
    # 
```

**观察svc资源对象和ep资源对象(svc资源对象触发自动创建的)**
```
root@master01:~# kubectl -n lili get svc/startupprobe-failure01 
NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
startupprobe-failure01   ClusterIP   11.7.212.106   <none>        80/TCP    2m6s
root@master01:~#
root@master01:~#
root@master01:~# kubectl -n lili get ep/startupprobe-failure01  -w 
NAME                     ENDPOINTS   AGE
startupprobe-failure01               2m20s
    #
    # 其 ENDPOINTS 字段始终是没有值。因为所关联的Pod里面的主容器始终未就绪(READY)。
    #
```

## 2.3 startupprobe-failure02
**应用manifests**
```
root@master01:~# kubectl apply -f 03.startupprobe-failure02.yaml  --dry-run=client
pod/startupprobe-failure02 created (dry run)
service/startupprobe-failure02 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.startupprobe-failure02.yaml
pod/startupprobe-failure02 created
service/startupprobe-failure02 created
```

**观察Pod资源对象(不要停止观察)**
```
root@master01:~# kubectl -n lili get Pod/startupprobe-failure02 -o wide -w 
NAME                     READY   STATUS             RESTARTS      AGE     IP          NODE     NOMINATED NODE   READINESS GATES
startupprobe-failure02   0/1     Running            0             7s      10.0.4.65   node02   <none>           <none>
startupprobe-failure02   0/1     Running            1 (1s ago)    71s     10.0.4.65   node02   <none>           <none>
startupprobe-failure02   0/1     Running            2 (1s ago)    2m21s   10.0.4.65   node02   <none>           <none>
startupprobe-failure02   0/1     Running            3 (2s ago)    3m32s   10.0.4.65   node02   <none>           <none>
startupprobe-failure02   0/1     Running            4 (2s ago)    4m42s   10.0.4.65   node02   <none>           <none>
startupprobe-failure02   0/1     Running            5 (1s ago)    5m51s   10.0.4.65   node02   <none>           <none>
startupprobe-failure02   0/1     CrashLoopBackOff   5 (1s ago)    7m1s    10.0.4.65   node02   <none>           <none>
startupprobe-failure02   0/1     Running            6 (83s ago)   8m23s   10.0.4.65   node02   <none>           <none>
startupprobe-failure02   0/1     CrashLoopBackOff   6 (1s ago)    9m31s   10.0.4.65   node02   <none>           <none>
startupprobe-failure02   0/1     CrashLoopBackOff   6 (41s ago)   10m     10.0.4.65   node02   <none>           <none>
startupprobe-failure02   0/1     Running            7 (2m49s ago)   12m   10.0.4.65   node02   <none>           <none>
光标在闪烁
    #
    # Pod中的容器会一陷入重启死循环(因为startupProbe的探测命令我故障写错了)。
    # Pod的状态也会在 Running 和 CrashLoopBackOff 间切换。
    # 
```

**观察svc资源对象和ep资源对象(svc资源对象触发自动创建的)**
```
root@master01:~# kubectl -n lili get svc/startupprobe-failure02 
NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
startupprobe-failure02   ClusterIP   11.8.10.196   <none>        80/TCP    2m6s
root@master01:~#
root@master01:~#
root@master01:~# kubectl -n lili get ep/startupprobe-failure02  -w 
NAME                     ENDPOINTS   AGE
startupprobe-failure02               2m20s
    #
    # 其 ENDPOINTS 字段始终是没有值。因为所关联的Pod里面的主容器始终未就绪(READY)。
    #
```

## 2.4 startupprobe-success




# 3 readinessProbe
容器的就绪探测(readinessProbe)是周期性的，失败后是不会重启容器的(所以其初始探测的等待时长不用将应用程序的启动时长考滤进来)。
当就绪探测成功后，容器才算就绪，Pod才会加入配对的svc资源对象的后端端点。  
**应用manifests**
```
root@master01:~# kubectl apply -f 05.readinessprobe-is-periodic.yaml  --dry-run=client
pod/readinessprobe-is-periodic configured (dry run)
service/readinessprobe-is-periodic configured (dry run)

root@master01:~# kubectl apply -f 05.readinessprobe-is-periodic.yaml 
pod/readinessprobe-is-periodic created
service/readinessprobe-is-periodic created
```

**就绪探测还未成功(已失败多次)**
期间肯定是有失败的(应用程序启动需要120秒后才启动，初始探测前等待10秒，失败次数3，成功次数1，间隔10秒，探测命令是写对了的)。  
可看出容器是没有重启的，Pod中的容器还未就绪，Pod未加被加入到svc的后端端点列表中。
```
root@master01:~# kubectl  -n lili get Pod/readinessprobe-is-periodic -o wide -w
NAME                         READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
readinessprobe-is-periodic   0/1     Running   0          8s    10.0.4.71   node02   <none>           <none>
光标在闪烁

root@master01:~# kubectl -n lili get svc/readinessprobe-is-periodic 
NAME                         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
readinessprobe-is-periodic   ClusterIP   11.7.190.13   <none>        80/TCP    17s

root@master01:~# kubectl -n lili get ep/readinessprobe-is-periodic -w
NAME                         ENDPOINTS   AGE
readinessprobe-is-periodic               26s
光标在闪烁
```

**就绪探测已成功**
```
root@master01:~# kubectl  -n lili get Pod/readinessprobe-is-periodic -o wide -w
NAME                         READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
readinessprobe-is-periodic   0/1     Running   0          8s    10.0.4.71   node02   <none>           <none>
readinessprobe-is-periodic   1/1     Running   0          2m25s   10.0.4.71   node02   <none>           <none>
光标在闪烁

root@master01:~# kubectl -n lili get svc/readinessprobe-is-periodic 
NAME                         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
readinessprobe-is-periodic   ClusterIP   11.7.190.13   <none>        80/TCP    17s

root@master01:~# kubectl -n lili get ep/readinessprobe-is-periodic -w
NAME                         ENDPOINTS   AGE
readinessprobe-is-periodic               26s
readinessprobe-is-periodic   10.0.4.71:80   2m25s
光标在闪烁

root@master01:~# curl 11.7.190.13:80        # worker node上访问svcClusterIP:svcPort
iKubernetes demoapp v1.1 !! ClientIP: 10.0.0.0, ServerName: readinessprobe-is-periodic, ServerIP: 10.0.4.71!

root@master01:~# curl 10.0.4.71:80          # worker node上访问podIP:appPort
iKubernetes demoapp v1.1 !! ClientIP: 10.0.0.0, ServerName: readinessprobe-is-periodic, ServerIP: 10.0.4.71!
```

**在线修改探测处的值(让其探测失败)**
```
root@master01:~# kubectl -n lili exec -it pod/readinessprobe-is-periodic -c demoapp -- curl 127.0.0.1/readyz
OK

root@master01:~# kubectl -n lili exec -it pod/readinessprobe-is-periodic -c demoapp -- curl -XPOST -d "readyz=FAIL" 127.0.0.1/readyz
root@master01:~# 

root@master01:~# kubectl -n lili exec -it pod/readinessprobe-is-periodic -c demoapp -- curl 127.0.0.1/readyz 
FAIL
```


**就绪探测已失败**
```
root@master01:~# kubectl  -n lili get Pod/readinessprobe-is-periodic -o wide -w
NAME                         READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
readinessprobe-is-periodic   0/1     Running   0          8s    10.0.4.71   node02   <none>           <none>
readinessprobe-is-periodic   1/1     Running   0          2m25s   10.0.4.71   node02   <none>           <none>
readinessprobe-is-periodic   0/1     Running   0          11m     10.0.4.71   node02   <none>           <none>
   # 
   # Pod中的容器又未完全就绪
   #

root@master01:~# kubectl -n lili get svc/readinessprobe-is-periodic 
NAME                         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
readinessprobe-is-periodic   ClusterIP   11.7.190.13   <none>        80/TCP    11m

root@master01:~# kubectl -n lili get ep/readinessprobe-is-periodic -w
NAME                         ENDPOINTS   AGE
readinessprobe-is-periodic               26s
readinessprobe-is-periodic   10.0.4.71:80   2m25s
readinessprobe-is-periodic                  11m
   #
   # svc的后端端点列表中又将Pod给移除了
   #

root@master01:~# curl 11.7.190.13:80     # worker node上访问svcClusterIP:svcPort，已无法访问，因为svc的后端端点列表是空的。
curl: (7) Failed to connect to 11.7.190.13 port 80: Connection refused
```

**让就绪探测成功**
```
销毁Pod后重建
或
kubectl -n lili exec -it pod/readinessprobe-is-periodic -c demoapp -- curl -XPOST -d "readyz=OK" 127.0.0.1/readyz
还得等待就绪探测成功
```

