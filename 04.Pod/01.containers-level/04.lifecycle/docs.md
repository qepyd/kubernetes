# 1.Pod的生命周期


# 2.lifecycle-poststart
**应用manifests**
```
root@master01:~# kubectl apply -f 01.pods_lifecycle-poststart.yaml  --dry-run=client
pod/lifecycle-poststart created (dry run)
root@master01:~# 
root@master01:~# kubectl apply -f 01.pods_lifecycle-poststart.yaml
pod/lifecycle-poststart created
```

**列出资源对象**
```
root@master01:~# kubectl -n lili get Pod/lifecycle-poststart  -o wide
NAME                  READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
lifecycle-poststart   1/1     Running   0          36s   10.0.4.35   node02   <none>           <none>
```

**worker node上访问PodIP:port**
```
root@master01:~# curl 10.0.4.35:80
haha
```

# 3.lifecycle-prestop
**应用manifests**
```
root@master01:~# kubectl apply -f 02.pods_lifecycle-prestop.yaml --dry-run=client
pod/lifecycle-prestop created (dry run)
root@master01:~# 
root@master01:~# kubectl apply -f 02.pods_lifecycle-prestop.yaml
pod/lifecycle-prestop created
```

**列出资源对象**
```
root@master01:~# kubectl -n lili get Pod/lifecycle-prestop -o wide
NAME                READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
lifecycle-prestop   1/1     Running   0          30s   10.0.4.38   node02   <none>           <none>
```

**worker node上访问PodIP:Port**
```
root@master01:~# curl 10.0.4.38:80
iKubernetes demoapp v1.1 !! ClientIP: 10.0.0.0, ServerName: lifecycle-prestop, ServerIP: 10.0.4.38!
```

**删除Pod/lifecycle-prestop对象**
```
root@master01:~# kubectl -n lili delete Pod/lifecycle-prestop
pod "lifecycle-prestop" deleted
光标在闪烁(等待Pod中容器终止前操作完成)
```

**另外一个shell窗口,查看Pod/lifecycle-prestop对象的日志**
```
root@master01:~# kubectl -n lili logs -f Pod/lifecycle-prestop
10.0.0.0 - - [11/Jul/2025 14:51:53] "GET / HTTP/1.1" 200 -
127.0.0.1 - - [11/Jul/2025 14:53:26] "HEAD / HTTP/1.1" 200 -
127.0.0.1 - - [11/Jul/2025 14:53:30] "HEAD / HTTP/1.1" 200 -
127.0.0.1 - - [11/Jul/2025 14:53:34] "HEAD / HTTP/1.1" 200 -
127.0.0.1 - - [11/Jul/2025 14:53:38] "HEAD / HTTP/1.1" 200 -
127.0.0.1 - - [11/Jul/2025 14:53:42] "HEAD / HTTP/1.1" 200 -
127.0.0.1 - - [11/Jul/2025 14:53:46] "HEAD / HTTP/1.1" 200 -
.............................................................
.............................................................
```
