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

# 2.nginx-daemon 
**应用manifests**
```
root@master01:~# kubectl apply -f 02.pods_nginx-daemon.yaml --dry-run=client
pod/nginx-daemon created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 02.pods_nginx-daemon.yaml
pod/nginx-daemon created
```

**列出资源对象**
```
root@master01:~#
root@master01:~# kubectl -n lili get Pod/nginx-daemon  -o wide
NAME           READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
nginx-daemon   1/1     Running   0          23s   10.0.4.24   node02   <none>           <none>
```

**访问Pod中的应用程序**
```
root@master01:~# curl 10.0.4.24:80
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

# 3.mysql-daemon
**应用manifests**
```
root@master01:~# kubectl apply -f 03.pods_mysql-daemon.yaml  --dry-run=client
pod/mysql-daemon configured (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.pods_mysql-daemon.yaml 
pod/mysql-daemon created
```

**列了资源对象**
```
root@master01:~# kubectl -n lili get Pod/mysql-daemon -o wide
NAME           READY   STATUS    RESTARTS   AGE     IP          NODE     NOMINATED NODE   READINESS GATES
mysql-daemon   1/1     Running   0          5m21s   10.0.4.25   node02   <none>           <none>
```

**容器内部访问mysql**
```
kubectl -n lili exec -it Pod/mysql-daemon -c myapp01 /bin/bash 
  mysql -uroot -p123456  -S /run/mysqld/mysqld.sock
    show databases;
    exit;
  exit
```


# 4.ubuntu-daemon
**应用manifests**
```
root@master01:~# kubectl apply -f 04.pods_ubuntu-daemon.yaml  --dry-run=client
pod/ubuntu-daemon created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 04.pods_ubuntu-daemon.yaml
pod/ubuntu-daemon created
```

**列出资源对象**
```
root@master01:~# kubectl -n lili get Pod/ubuntu-daemon
NAME            READY   STATUS    RESTARTS   AGE
ubuntu-daemon   1/1     Running   0          18s
``` 

# 5.清理环境
```
kubectl delete -f  01.pods_volumemounts-env-command-args.yaml
kubectl delete -f  02.pods_nginx-daemon.yaml
kubectl delete -f  03.pods_mysql-daemon.yaml
kubectl delete -f  04.pods_ubuntu-daemon.yaml
```
