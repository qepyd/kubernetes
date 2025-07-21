# 1 可变configmaps资源对象(未定义immutable字段)
**创建cm/immutable-not-exist对象**
```
## 应用manifests
root@master01:~#
root@master01:~# kubectl apply -f 01.cm_immutable-not-exist-v1.yaml --dry-run=client
configmap/immutable-not-exist created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 01.cm_immutable-not-exist-v1.yaml 
configmap/immutable-not-exist created

## 列出cm/immutable-not-exist对象
root@master01:~# kubectl -n lili get configmap/immutable-not-exist
NAME                  DATA   AGE
immutable-not-exist   0      36s
   # 
   # 其DATA字段的值为0，表示没有任何的key value对
   #

## 查看cm/immutable-not-exists对象的描述信息
root@master01:~# kubectl -n lili describe configmap/immutable-not-exist
Name:         immutable-not-exist
Namespace:    lili
Labels:       <none>
Annotations:  <none>

Data
====

BinaryData
====

Events:  <none>
```

**改变cm/immutable-not-exists对象**
```
## 查看cm/immutable-not-exists对象是否在线更改
kubectl -n lili get configmap/immutable-not-exist -o yaml 
   # 
   # 通过在线manifests查看immutable字段
   #   不存在时，configmaps资源对象是可变的。
   #   存在且值为false，configmaps资源对象是可变的。 
   #   存在且值为true，configmaps资源对象是不可变的。
   #

## 应用manifests
root@master01:~# kubectl apply -f 01.cm_immutable-not-exist-v2.yaml  --dry-run=client
configmap/immutable-not-exist configured (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 01.cm_immutable-not-exist-v2.yaml
configmap/immutable-not-exist configured

## 观察cm/immutable-not-exists对象
root@master01:~# kubectl -n lili get configmap/immutable-not-exist
NAME                  DATA   AGE
immutable-not-exist   2      7m24s       # 其DATA字段的值为2，表示有2个key value对
root@master01:~#
root@master01:~#
root@master01:~# kubectl -n lili describe configmap/immutable-not-exist
Name:         immutable-not-exist
Namespace:    lili
Labels:       <none>
Annotations:  <none>

Data                 # === 这是data字段
====
my01.conf:           # 这是key
----
chenliang
my02.conf:           # 这是key
----
binbin
lili 


BinaryData           # == 这是binaryData字段
====
```
# 2 可变configmaps资源对象(immutable字段的值为false)

**创建cm/immutable-false-cm对象**
```
## 应用manifests
root@master01:~# kubectl apply -f 02.cm_immutable-false-cm-v1.yaml --dry-run=client
configmap/immutable-false-cm created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 02.cm_immutable-false-cm-v1.yaml
configmap/immutable-false-cm created

## 列出cm/immutable-false-cm对象
root@master01:~# kubectl  -n lili get configmap/immutable-false-cm
NAME                 DATA   AGE
immutable-false-cm   0      29s
   # 
   # 其DATA字段的值为0，表示没有任何的key value对
   #

## 查看cm/immutable-false-cm对象的描述信息
root@master01:~# kubectl  -n lili describe configmap/immutable-false-cm
Name:         immutable-false-cm
Namespace:    lili
Labels:       <none>
Annotations:  <none>

Data
====

BinaryData
====

Events:  <none>
```

**改变cm/immutable-false-cm对象**
```
## 查看cm/immutable-false-cm对象是否在线更改
kubectl -n lili get configmap/immutable-false-cm -o yaml
   #
   # 通过在线manifests查看immutable字段
   #   不存在时，configmaps资源对象是可变的。
   #   存在且值为false，configmaps资源对象是可变的。
   #   存在且值为true，configmaps资源对象是不可变的。
   #

## 应用manifests
root@master01:~# kubectl apply -f 02.cm_immutable-false-cm-v2.yaml 
configmap/immutable-false-cm configured

## 观察cm/immutable-false-cm对象
root@master01:~# kubectl  -n lili get configmap/immutable-false-cm
NAME                 DATA   AGE
immutable-false-cm   2      2m14s
root@master01:~#
root@master01:~# kubectl  -n lili describe configmap/immutable-false-cm
Name:         immutable-false-cm
Namespace:    lili
Labels:       <none>
Annotations:  <none>

Data
====
my01.conf:
----
chenliang
my02.conf:
----
binbin
lili 


BinaryData
====

Events:  <none>
```

# 3 不可变configmaps资源对象(immutable字段的值为true)




# 4 binaryData和data字段同时存在,data中key不能与binaryData中key冲突
会影响configmaps资源对象的创建

# 5 binaryData和data字段不同时存在,key冲突,以最后一个key为准。
不会景程configmaps资源对象的创建，以最后一个key为准

