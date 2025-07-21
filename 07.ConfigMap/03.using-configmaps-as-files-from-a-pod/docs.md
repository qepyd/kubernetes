# 1 Pod级别挂载cm资源对象中所有键值对，容器级别再挂载到某个目录。
**创建cm/many-key-value-01对象**
```
root@master01:~# kubectl apply -f 01.cm_many-key-value-01-v1.yaml  --dry-run=client
configmap/many-key-value-01 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 01.cm_many-key-value-01-v1.yaml 
configmap/many-key-value-01 created
root@master01:~#
root@master01:~# kubectl -n lili describe configmap/many-key-value-01
Name:         many-key-value-01
Namespace:    lili
Labels:       <none>
Annotations:  <none>

Data
====
file01:
----
1111
1111

file02:
----
2222
2222


BinaryData
====

Events:  <none>
```

**创建pod/myapp01对象**
```
root@master01:~# kubectl apply -f 01.pods_myapp01.yaml --dry-run=client
pod/myapp01 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 01.pods_myapp01.yaml 
pod/myapp01 created
root@master01:~#
root@master01:~# kubectl -n lili get pod/myapp01
NAME      READY   STATUS    RESTARTS   AGE
myapp01   1/1     Running   0          51s
root@master01:~#
root@master01:~# kubectl -n lili exec -it  pod/myapp01 -c busybox -- ls -la /data/
total 12
drwxrwxrwx    3 root     root          4096 Jul 21 08:56 .
drwxr-xr-x    1 root     root          4096 Jul 21 08:56 ..
drwxr-xr-x    2 root     root          4096 Jul 21 08:56 ..2025_07_21_08_56_49.126668315
lrwxrwxrwx    1 root     root            31 Jul 21 08:56 ..data -> ..2025_07_21_08_56_49.126668315
lrwxrwxrwx    1 root     root            13 Jul 21 08:56 file01 -> ..data/file01
lrwxrwxrwx    1 root     root            13 Jul 21 08:56 file02 -> ..data/file02
root@master01:~#
root@master01:~# kubectl -n lili exec -it  pod/myapp01 -c busybox -- cat /data/file01
1111
1111
root@master01:~# 
root@master01:~# kubectl -n lili exec -it  pod/myapp01 -c busybox -- cat /data/file02
2222
2222 
root@master01:~# 
```

**更新cm/many-key-value-01对象**
```
root@master01:~# kubectl apply -f 01.cm_many-key-value-01-v2.yaml --dry-run=client
configmap/many-key-value-01 configured (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 01.cm_many-key-value-01-v2.yaml
configmap/many-key-value-01 configured
root@master01:~#
root@master01:~# kubectl -n lili describe configmap/many-key-value-01
Name:         many-key-value-01
Namespace:    lili
Labels:       <none>
Annotations:  <none>

Data
====
file02:
----
2222
2222
222222222222

file01:
----
1111
1111
111111111111


BinaryData
====

Events:  <none>
```

**观察pod/myapp01对象中某容器**
```
root@master01:~# kubectl -n lili exec -it  pod/myapp01 -c busybox -- ls -la /data/
total 12
drwxrwxrwx    3 root     root          4096 Jul 21 08:58 .
drwxr-xr-x    1 root     root          4096 Jul 21 08:56 ..
drwxr-xr-x    2 root     root          4096 Jul 21 08:58 ..2025_07_21_08_58_21.3468618440
lrwxrwxrwx    1 root     root            32 Jul 21 08:58 ..data -> ..2025_07_21_08_58_21.3468618440
lrwxrwxrwx    1 root     root            13 Jul 21 08:56 file01 -> ..data/file01
lrwxrwxrwx    1 root     root            13 Jul 21 08:56 file02 -> ..data/file02
root@master01:~#
root@master01:~# kubectl -n lili exec -it  pod/myapp01 -c busybox -- cat /data/file01
1111
1111
111111111111
root@master01:~#
root@master01:~# kubectl -n lili exec -it  pod/myapp01 -c busybox -- cat /data/file02
2222
2222
222222222222
```

# 2 Pod级别挂载cm资源对象中所有/部分键值对，容器级别再挂载到不同目录。
**创建cm/many-key-value-02对象**
```
root@master01:~# kubectl apply -f 02.cm_many-key-value-02-v1.yaml  --dry-run=client
configmap/many-key-value-02 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 02.cm_many-key-value-02-v1.yaml
configmap/many-key-value-02 created
root@master01:~#
root@master01:~# kubectl  -n lili get configmap/many-key-value-02
NAME                DATA   AGE
many-key-value-02   2      20s
root@master01:~#
root@master01:~# kubectl  -n lili describe configmap/many-key-value-02
Name:         many-key-value-02
Namespace:    lili
Labels:       <none>
Annotations:  <none>

Data
====
file01:
----
1111
1111

file02:
----
2222
2222


BinaryData
====

Events:  <none>
```

**创建cm/myapp02对象**
```
root@master01:~# kubectl apply -f 02.pods_myapp02.yaml  --dry-run=client
pod/myapp02 created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 02.pods_myapp02.yaml 
pod/myapp02 created
root@master01:~#
root@master01:~# kubectl  -n lili get pod/myapp02
NAME      READY   STATUS    RESTARTS   AGE
myapp02   1/1     Running   0          25s
root@master01:~#
root@master01:~#  kubectl  -n lili exec -it pods/myapp02 -c busybox01 -- ls -la /dir01/
total 12
drwxrwxrwx    3 root     root          4096 Jul 21 09:02 .
drwxr-xr-x    1 root     root          4096 Jul 21 09:02 ..
drwxr-xr-x    2 root     root          4096 Jul 21 09:02 ..2025_07_21_09_02_16.2352104950
lrwxrwxrwx    1 root     root            32 Jul 21 09:02 ..data -> ..2025_07_21_09_02_16.2352104950
lrwxrwxrwx    1 root     root            14 Jul 21 09:02 file011 -> ..data/file011
root@master01:~#
root@master01:~# kubectl  -n lili exec -it pods/myapp02 -c busybox01 -- ls -la /dir02/
total 12
drwxrwxrwx    3 root     root          4096 Jul 21 09:02 .
drwxr-xr-x    1 root     root          4096 Jul 21 09:02 ..
drwxr-xr-x    2 root     root          4096 Jul 21 09:02 ..2025_07_21_09_02_16.517501512
lrwxrwxrwx    1 root     root            31 Jul 21 09:02 ..data -> ..2025_07_21_09_02_16.517501512
lrwxrwxrwx    1 root     root            14 Jul 21 09:02 file022 -> ..data/file022
root@master01:~#
root@master01:~# kubectl  -n lili exec -it pods/myapp02 -c busybox01 -- cat /dir01/file011
1111
1111
root@master01:~#
root@master01:~# kubectl  -n lili exec -it pods/myapp02 -c busybox01 -- cat /dir02/file022
2222
2222
```

**更新cm/many-key-value-02对象**
```
root@master01:~# kubectl apply -f 02.cm_many-key-value-02-v2.yaml --dry-run=client
configmap/many-key-value-02 configured (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 02.cm_many-key-value-02-v2.yaml
configmap/many-key-value-02 configured
root@master01:~#
root@master01:~# kubectl  -n lili describe configmap/many-key-value-02
Name:         many-key-value-02
Namespace:    lili
Labels:       <none>
Annotations:  <none>

Data
====
file01:
----
1111
1111
111111111111

file02:
----
2222
2222
222222222222


BinaryData
====

Events:  <none>
```

**观察cm/myapp02对象中相关容器**
```
root@master01:~# kubectl  -n lili exec -it pods/myapp02 -c busybox01 -- ls -la /dir01/
total 12
drwxrwxrwx    3 root     root          4096 Jul 21 09:06 .
drwxr-xr-x    1 root     root          4096 Jul 21 09:02 ..
drwxr-xr-x    2 root     root          4096 Jul 21 09:06 ..2025_07_21_09_06_38.3666904900
lrwxrwxrwx    1 root     root            32 Jul 21 09:06 ..data -> ..2025_07_21_09_06_38.3666904900
lrwxrwxrwx    1 root     root            14 Jul 21 09:02 file011 -> ..data/file011
root@master01:~#
root@master01:~# kubectl  -n lili exec -it pods/myapp02 -c busybox01 -- ls -la /dir02/
total 12
drwxrwxrwx    3 root     root          4096 Jul 21 09:06 .
drwxr-xr-x    1 root     root          4096 Jul 21 09:02 ..
drwxr-xr-x    2 root     root          4096 Jul 21 09:06 ..2025_07_21_09_06_38.2777782440
lrwxrwxrwx    1 root     root            32 Jul 21 09:06 ..data -> ..2025_07_21_09_06_38.2777782440
lrwxrwxrwx    1 root     root            14 Jul 21 09:02 file022 -> ..data/file022
root@master01:~#
root@master01:~# kubectl  -n lili exec -it pods/myapp02 -c busybox01 -- cat /dir01/file011
1111
1111
111111111111
root@master01:~#
root@master01:~# kubectl  -n lili exec -it pods/myapp02 -c busybox01 -- cat /dir02/file022
2222
2222
222222222222
```
