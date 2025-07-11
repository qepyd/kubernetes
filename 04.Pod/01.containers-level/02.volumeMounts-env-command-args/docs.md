# 1. volumemounts-env-command-args
**应用manifests**
```
root@master01:~# kubectl apply -f 01.pods_volumemounts-env-command-args.yaml --dry-run=client
pod/volumemounts-env-command-args created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 01.pods_volumemounts-env-command-args.yaml
pod/volumemounts-env-command-args created
```

**列出资源对象**
```
root@master01:~# kubectl -n lili get Pod/volumemounts-env-command-args
NAME                            READY   STATUS    RESTARTS   AGE
volumemounts-env-command-args   1/1     Running   0          26s
```

**查看Pod/volumemounts对象中其myapp01主容器里面的/data/lili.txt文件**
```
root@master01:~# kubectl -n lili exec -it Pod/volumemounts-env-command-args -c myapp01  -- ls -l /data/
total 4
-rw-r--r-- 1 root root 40 Jul 11 09:10 lili.txt
root@master01:~#
root@master01:~#
root@master01:~# kubectl -n lili exec -it Pod/volumemounts-env-command-args -c myapp01  -- cat /data/lili.txt
cl
binbin
volumemounts-env-command-args
```

**查看Pod/volumemounts对象中其myapp01主容器里面的所有环境变量**
```
root@master01:~# kubectl -n lili exec -it Pod/volumemounts-env-command-args -c myapp01  -- env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=volumemounts-env-command-args
NGINX_VERSION=1.16.1
NJS_VERSION=0.3.5
PKG_RELEASE=1~buster
MY_NAME=binbin
MY_SEX=girl
POD_NAME=volumemounts-env-command-args
POD_IP=10.0.4.22
NODE_NAME=node02
NODE_IP=172.31.7.207
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT=tcp://11.0.0.1:443
KUBERNETES_PORT_443_TCP=tcp://11.0.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_ADDR=11.0.0.1
KUBERNETES_SERVICE_HOST=11.0.0.1
KUBERNETES_SERVICE_PORT=443
TERM=xterm
HOME=/root
```

**清理环境**
```
kubectl delete -f  01.pods_volumemounts-env-command-args.yaml
```

# 2.nginx-daemon 


# 3.mysql-daemon

# 4.busybox-daemon
 
