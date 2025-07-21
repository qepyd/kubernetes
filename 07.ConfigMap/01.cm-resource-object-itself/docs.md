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
**创建cm/immutable-true-cm对象**
```
## 应用manifests
root@master01:~# kubectl apply -f 03.cm_immutable-true-cm-v1.yaml --dry-run=client
configmap/immutable-true-cm created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.cm_immutable-true-cm-v1.yaml 
configmap/immutable-true-cm created

## 列出cm/immutable-true-cm对象
root@master01:~# kubectl  -n lili get configmap/immutable-true-cm
NAME                DATA   AGE
immutable-true-cm   0      21s

## 查看cm/immutable-true-cm对象的描述信息
root@master01:~# kubectl  -n lili describe configmap/immutable-true-cm
Name:         immutable-true-cm
Namespace:    lili
Labels:       <none>
Annotations:  <none>

Data
====

BinaryData
====

Events:  <none>
```

**改变cm/immutable-true-cm对象**
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
root@master01:~# kubectl apply -f 03.cm_immutable-true-cm-v2.yaml --dry-run=client
configmap/immutable-true-cm configured (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.cm_immutable-true-cm-v2.yaml
The ConfigMap "immutable-true-cm" is invalid: 
* immutable: Forbidden: field is immutable when `immutable` is set
* data: Forbidden: field is immutable when `immutable` is set
```


# 4 binaryData字段中各key的value得加密后填写
binaryData字段中各key的value得加密后填写，不然影响configmaps资源对象的创建
```
root@master01:~# kubectl apply -f 04.cm_binarydata-not-base64-error.yaml --dry-run=client
configmap/binarydata-not-base64-error created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 04.cm_binarydata-not-base64-error.yaml
Error from server (BadRequest): error when creating "04.cm_binarydata-not-base64-error.yaml": ConfigMap in version "v1" cannot be handled as a ConfigMap: illegal base64 data at input byte 8
```

# 5 data字段中key不能与binaryData中的key冲突
```
root@master01:~# kubectl apply -f 05.cm_data-binarydata-key-conflict-error.yaml --dry-run=client
configmap/data-binarydata-key-conflict-error created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 05.cm_data-binarydata-key-conflict-error.yaml 
The ConfigMap "data-binarydata-key-conflict-error" is invalid: data[myname]: Invalid value: "myname": duplicate of key present in binaryData
```

# 6 只用data字段定义key value对即可
因为configmaps资源对象用于将非机密性的数据保存到键值对中
```
root@master01:~# kubectl apply -f 06.cm_just-use-the-data-field.yaml  --dry-run=client
configmap/just-use-the-data-field created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 06.cm_just-use-the-data-field.yaml
configmap/just-use-the-data-field created
root@master01:~#
root@master01:~# kubectl  -n lili get configmap/just-use-the-data-field
NAME                      DATA   AGE
just-use-the-data-field   2      18s
root@master01:~# 
root@master01:~# kubectl  -n lili describe configmap/just-use-the-data-field
Name:         just-use-the-data-field
Namespace:    lili
Labels:       <none>
Annotations:  <none>

Data
====
my.conf:
----
[mysqld]
server_id=110
data=/data/mysql3306/data/

myname:
----
chenliang

BinaryData
====

Events:  <none>

```

# 7 清理环境
```
kubectl delete -f .
```
