# 1 使用configmaps作为环境变量的相关说明
Pod中的容器直接调用所在名称空间中的configmaps资源对象中的数据（键值对）来作为环境变量，这种场景下，
即使configmaps资源对象在线更改后，容器中操作系统下的环境变量是不会随之变化的，只能重启Pod。  

关于容器中操作系统的环境变量
```
https://github.com/qepyd/kubernetes/blob/main/04.Pod/01.containers-level/02.volumeMounts-env-command-args/01.pods_volumemounts-env-command-args.yaml
有涉及到一些
```

自定义环境变量的name，其value来自configmaps中某key的value
```
pods.spec.containers.env.name  <string>
pods.spec.containers.env.valueFrom.configMapKeyRef <Object>
  name: <string>
  key: <string> -required-
  optional: <boolean>
这种比较灵活，建议使用。
```

直接将所引用configmaps中所有键值对映射成环境变量
```
pods.spec.containers.envFrom.configMapRef <object>
这种不灵活，不建议使用。
```

# 2 pods.spec.containers.env.valueFrom.configMapKeyRef
**创建cm/many-key-value-01对象**
```
root@master01:~# kubectl apply -f 01.cm_many-key-value-01.yaml --dry-run=client
configmap/many-key-value-01 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 01.cm_many-key-value-01.yaml
configmap/many-key-value-01 created
root@master01:~#
root@master01:~# kubectl  -n lili get configmap/many-key-value-01
NAME                DATA   AGE
many-key-value-01   2      28s
root@master01:~#
root@master01:~# kubectl  -n lili describe configmap/many-key-value-01
Name:         many-key-value-01
Namespace:    lili
Labels:       <none>
Annotations:  <none>

Data
====
port:
----
8080
host:
----
127.0.0.1

BinaryData
====

Events:  <none>
```

**创建pods/containers-env-valuefrom-configmaps对象,观察某容器中系统下的环境变量**
```
root@master01:~# kubectl apply -f 01.pods_containers-env-valuefrom-configmaps.yaml --dry-run=client
pod/containers-env-valuefrom-configmaps created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 01.pods_containers-env-valuefrom-configmaps.yaml
pod/containers-env-valuefrom-configmaps created
root@master01:~#
root@master01:~# root@master01:~# kubectl  -n lili get pod/containers-env-valuefrom-configmaps
NAME                                  READY   STATUS    RESTARTS   AGE
containers-env-valuefrom-configmaps   1/1     Running   0          23s
root@master01:~#
root@master01:~# kubectl  -n lili exec -it  pod/containers-env-valuefrom-configmaps -c busybox -- env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=containers-env-valuefrom-configmaps
MY_HOST=127.0.0.1          # <== 是它
MY_PORT=8080               # <== 是它
KUBERNETES_PORT=tcp://11.0.0.1:443
KUBERNETES_PORT_443_TCP=tcp://11.0.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_ADDR=11.0.0.1
KUBERNETES_SERVICE_HOST=11.0.0.1
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_PORT_HTTPS=443
TERM=xterm
HOME=/root
```

# 3 pods.spec.containers.envFrom.configMapRef
**创建cm/many-key-value-02对象**
```
root@master01:~# kubectl apply -f 02.cm_many-key-value-02.yaml --dry-run=client
configmap/many-key-value-02 configured (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 02.cm_many-key-value-02.yaml 
configmap/many-key-value-02 created
root@master01:~#
root@master01:~# kubectl -n lili get configmap/many-key-value-02
NAME                DATA   AGE
many-key-value-02   2      40s
root@master01:~#
root@master01:~# kubectl -n lili describe configmap/many-key-value-02
Name:         many-key-value-02
Namespace:    lili
Labels:       <none>
Annotations:  <none>

Data
====
host:
----
127.0.0.1
port:
----
8080

BinaryData
====

Events:  <none>
```

**创建pods/containers-envfrom-configmaps对象,观察某容器中系统下的环境变量**
```
root@master01:~# kubectl apply -f 02.pods_containers-envfrom-configmaps.yaml --dry-run=client
pod/containers-envfrom-configmaps created (dry run
root@master01:~#
root@master01:~# kubectl apply -f 02.pods_containers-envfrom-configmaps.yaml
pod/containers-envfrom-configmaps created
root@master01:~#
root@master01:~# kubectl -n lili get pod/containers-envfrom-configmaps
NAME                            READY   STATUS    RESTARTS   AGE
containers-envfrom-configmaps   1/1     Running   0          26s
root@master01:~#
root@master01:~#  kubectl -n lili exec -it pod/containers-envfrom-configmaps -c busybox -- env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=containers-envfrom-configmaps
host=127.0.0.1        # <== 就是它
port=8080             # <== 就是它
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_ADDR=11.0.0.1
KUBERNETES_SERVICE_HOST=11.0.0.1
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT=tcp://11.0.0.1:443
KUBERNETES_PORT_443_TCP=tcp://11.0.0.1:443
TERM=xterm
HOME=/root
```

# 4 清理环境
```
kubectl delete -f ./
``` 
