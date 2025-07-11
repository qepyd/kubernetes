# 1.human-read
**应用manifests**
```
root@master01:~# kubectl apply -f 01.human-read.yaml  --dry-run=client
pod/human-read created (dry run)
service/human-read created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 01.human-read.yaml
pod/human-read created
service/human-read created
```

**列出资源对象**
```
root@master01:~# kubectl -n lili get Pod/human-read -o wide
NAME         READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
human-read   1/1     Running   0          20s   10.0.4.32   node02   <none>           <none>
root@master01:~#
root@master01:~# kubectl -n lili get svc/human-read -o wide
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE   SELECTOR
human-read   ClusterIP   11.5.202.181   <none>        80/TCP    25s   app=human-read
root@master01:~#
root@master01:~# kubectl -n lili get Endpoints/human-read
NAME         ENDPOINTS      AGE
human-read   10.0.4.32:80   4m19s
```

**worker node上访问Pod/human-read对象的PodIP:Port**
```
root@master01:~# curl -I 10.0.4.32:80
HTTP/1.1 200 OK
Server: nginx/1.16.1
Date: Fri, 11 Jul 2025 13:47:53 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 13 Aug 2019 10:05:00 GMT
Connection: keep-alive
ETag: "5d528b4c-264"
Accept-Ranges: bytes
```

**worker node上访问svc/human-read对象的ClusterIP:SvcPort**
```
root@master01:~# curl -I 11.5.202.181:80
HTTP/1.1 200 OK
Server: nginx/1.16.1
Date: Fri, 11 Jul 2025 13:48:17 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 13 Aug 2019 10:05:00 GMT
Connection: keep-alive
ETag: "5d528b4c-264"
Accept-Ranges: bytes
```

# 2.expose
**应用manifests**
```
root@master01:~# kubectl apply -f 02.expose.yaml --dry-run=client
pod/expose created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 02.expose.yaml
pod/expose created
```

**列出资源对象**
```
root@master01:~# kubectl -n lili get Pod/expose -o wide
NAME     READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
expose   1/1     Running   0          23s   10.0.4.33   node02   <none>           <none>
```


**worker node访问Pod的PodIP:Port**
```
root@master01:~# curl -I 10.0.4.33:80
HTTP/1.1 200 OK
Server: nginx/1.16.1
Date: Fri, 11 Jul 2025 13:58:36 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 13 Aug 2019 10:05:00 GMT
Connection: keep-alive
ETag: "5d528b4c-264"
Accept-Ranges: bytes
```

**与worker node能够通信的节点访问NodeInternalIP:PodExposePort**
```
root@master01:~# kubectl get nodes -o wide | grep node02
node02     Ready    <none>          14d   v1.24.4   172.31.7.207   <none>        Ubuntu 20.04.4 LTS   5.4.0-216-generic   containerd://1.7.27
root@master01:~#
root@master01:~# curl -I 172.31.7.207:8080
HTTP/1.1 200 OK
Server: nginx/1.16.1
Date: Fri, 11 Jul 2025 13:58:14 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 13 Aug 2019 10:05:00 GMT
Connection: keep-alive
ETag: "5d528b4c-264"
Accept-Ranges: bytes
```

**到Pod所在worker node上查看其暴露的Port**
```
root@node02:~# ss -lntup | grep 8080
root@node02:~# 
root@node02:~# iptables -t nat -S  | grep 8080 | grep 10.0.4.33
-A CNI-DN-d3b86cab88931d3abd954 -p tcp -m tcp --dport 8080 -j DNAT --to-destination 10.0.4.33:80
```

# 3.清理环境
```
kubectl delete -f  01.human-read.yaml 
kubectl delete -f  02.expose.yaml 
```

