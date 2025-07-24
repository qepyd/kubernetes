# 1 可变secrets资源对象(immutable字段不存在)
**创建secrets/immutable-not-exist对象**
```
## 创建secrets/immutable-not-exist对象
root@master01:~# kubectl apply -f 01.secrets_immutable-not-exist-v1.yaml  --dry-run=client
secret/immutable-not-exist created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 01.secrets_immutable-not-exist-v1.yaml 
secret/immutable-not-exist created

## 列出资源对象
root@master01:~# kubectl -n lili get secret/immutable-not-exist
NAME                  TYPE     DATA   AGE
immutable-not-exist   Opaque   0      69s   # 类型、键值对数量为0

## 查看资源对象的描述信息(只会存在data字段)
root@master01:~# kubectl -n lili describe secret/immutable-not-exist
Name:         immutable-not-exist
Namespace:    lili
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data                            
====

## 查看资源对象的在线manifests(要么存在data字段，要么只存在data字段)
root@master01:~# kubectl -n lili get secret/immutable-not-exist -o yaml
apiVersion: v1
kind: Secret
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Secret","metadata":{"annotations":{},"name":"immutable-not-exist","namespace":"lili"},"type":"Opaque"}
  creationTimestamp: "2025-07-24T09:48:41Z"
  name: immutable-not-exist
  namespace: lili
  resourceVersion: "2193327"
  uid: 24d80747-e9b8-4c6d-ae71-f9fc7c8a6ed1
type: Opaque
root@master01:~#
root@master01:~# kubectl -n lili get secret/immutable-not-exist -o yaml | grep "^[a-z]"
apiVersion: v1
kind: Secret
metadata:
type: Opaque
```

**更新secrets/immutable-not-exist对象**
```
## 查看secrets/immutable-not-exist对象是否可变
kubectl -n lili get secret/immutable-not-exist -o yaml | grep "^[a-z]"
  # 
  # 可  变：不存在immutable字段 或 存在immutable字段且值为false
  # 不可变：存在immutable字段且值为true
  #

## 更新
root@master01:~# kubectl apply -f 01.secrets_immutable-not-exist-v2.yaml --dry-run=client
secret/immutable-not-exist configured (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 01.secrets_immutable-not-exist-v2.yaml
secret/immutable-not-exist configured

## 列出资源对象
root@master01:~# kubectl -n lili get secret/immutable-not-exist
NAME                  TYPE     DATA   AGE
immutable-not-exist   Opaque   1      9m51s

## 查看资源对象的描述信息
root@master01:~# kubectl -n lili describe secret/immutable-not-exist
Name:         immutable-not-exist
Namespace:    lili
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
myname:  10 bytes

## 查看资源对象的在线manifests（要么存在data字段，要么只存在data字段）
root@master01:~# kubectl -n lili get secret/immutable-not-exist -o yaml | grep "^[a-z]"
apiVersion: v1
data:
kind: Secret
metadata:
type: Opaque

## 从资源对象的在线manifests中查看data字段中所有的键值对（value得人为base64编码解码）
root@master01:~# kubectl -n lili get secret/immutable-not-exist -o json | jq ".data"
{
  "myname": "Y2hlbmxpYW5nCg=="
}
```

# 2 可变secrets资源对象(immutable字段的值为false)
**创建secrets/immutable-false对象**
```
## 创建secrets/immutable-false对象
root@master01:~# kubectl apply -f 02.secrets_immutable-false-v1.yaml --dry-run=client
secret/immutable-false created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 02.secrets_immutable-false-v1.yaml 
secret/immutable-false created

## 列出资源对象
root@master01:~# kubectl  -n lili get secret/immutable-false
NAME              TYPE     DATA   AGE
immutable-false   Opaque   0      2m8s

## 查看资源对象的描述信息(只会存在data字段)
root@master01:~# kubectl  -n lili describe secret/immutable-false
Name:         immutable-false
Namespace:    lili
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====

## 查看资源对象的在线manifests(要么存在data字段，要么只存在data字段)
root@master01:~# kubectl  -n lili get secret/immutable-false -o yaml 
apiVersion: v1
immutable: false
kind: Secret
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","immutable":false,"kind":"Secret","metadata":{"annotations":{},"name":"immutable-false","namespace":"lili"},"type":"Opaque"}
  creationTimestamp: "2025-07-24T10:05:41Z"
  name: immutable-false
  namespace: lili
  resourceVersion: "2195168"
  uid: 0791c731-be66-46b4-856b-9f2f765bc466
type: Opaque
root@master01:~#
root@master01:~# kubectl  -n lili get secret/immutable-false -o yaml  | grep "^[a-z]"
apiVersion: v1
immutable: false
kind: Secret
metadata:
type: Opaque
```

**更新secrets/immutable-false对象**
```
## 查看secrets/immutable-false对象是否可变
kubectl -n lili get secret/immutable-false -o yaml | grep "^[a-z]"
  # 
  # 可  变：不存在immutable字段 或 存在immutable字段且值为false
  # 不可变：存在immutable字段且值为true
  #

## 更新
root@master01:~# kubectl apply -f 02.secrets_immutable-false-v2.yaml --dry-run=client
secret/immutable-false configured (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 02.secrets_immutable-false-v2.yaml 
secret/immutable-false configured

## 列出资源对象
root@master01:~# kubectl  -n lili get secret/immutable-false
NAME              TYPE     DATA   AGE
immutable-false   Opaque   1      5m11s

## 查看资源对象的描述信息
root@master01:~# kubectl  -n lili describe secret/immutable-false
Name:         immutable-false
Namespace:    lili
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
myname:  10 bytes

## 查看资源对象的在线manifests（要么存在data字段，要么只存在data字段）
root@master01:~# kubectl  -n lili get secret/immutable-false -o yaml
apiVersion: v1
data:
  myname: Y2hlbmxpYW5nCg==
immutable: false
kind: Secret
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"myname":"Y2hlbmxpYW5nCg=="},"immutable":false,"kind":"Secret","metadata":{"annotations":{},"name":"immutable-false","namespace":"lili"},"type":"Opaque"}
  creationTimestamp: "2025-07-24T10:05:41Z"
  name: immutable-false
  namespace: lili
  resourceVersion: "2195666"
  uid: 0791c731-be66-46b4-856b-9f2f765bc466
type: Opaque
root@master01:~#
root@master01:~# kubectl  -n lili get secret/immutable-false -o yaml | grep "^[a-z]"
apiVersion: v1
data:
immutable: false
kind: Secret
metadata:
type: Opaque
```

# 3 不可变secrets资源对象(immutable字段的值为true)
**创建secrets/immutable-true对象**
```
## 创建secrets/immutable-true对象
root@master01:~# kubectl apply -f 03.secrets_immutable-true-v1.yaml --dry-run=client
secret/immutable-true created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.secrets_immutable-true-v1.yaml
secret/immutable-true created

## 列出资源对象
root@master01:~# kubectl  -n lili get secret/immutable-true
NAME             TYPE     DATA   AGE
immutable-true   Opaque   0      26s

## 查看资源对象的描述信息(只会存在data字段)
root@master01:~# kubectl  -n lili describe secret/immutable-true
Name:         immutable-true
Namespace:    lili
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====

## 查看资源对象的在线manifests(要么存在data字段，要么只存在data字段)
root@master01:~# kubectl  -n lili get secret/immutable-true  -o yaml
apiVersion: v1
immutable: true
kind: Secret
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","immutable":true,"kind":"Secret","metadata":{"annotations":{},"name":"immutable-true","namespace":"lili"},"type":"Opaque"}
  creationTimestamp: "2025-07-24T10:13:31Z"
  name: immutable-true
  namespace: lili
  resourceVersion: "2196013"
  uid: c9a85a4a-b670-447f-8107-1a2d3a5031df
type: Opaque
root@master01:~#
root@master01:~# kubectl  -n lili get secret/immutable-true  -o yaml | grep "^[a-z]"
apiVersion: v1
immutable: true
kind: Secret
metadata:
type: Opaque
```

**更新secrets/immutable-true对象**
```
## 查看secrets/immutable-true对象是否可变
kubectl -n lili get secret/immutable-true -o yaml | grep "^[a-z]"
  #
  # 可  变：不存在immutable字段 或 存在immutable字段且值为false
  # 不可变：存在immutable字段且值为true
  #

## 更新
root@master01:~# kubectl apply -f 03.secrets_immutable-true-v2.yaml --dry-run=client
secret/immutable-true configured (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.secrets_immutable-true-v2.yaml
The Secret "immutable-true" is invalid: 
* immutable: Forbidden: field is immutable when `immutable` is set
* data: Forbidden: field is immutable when `immutable` is set
```

# 4 data字段得base64编码后填写
```
root@master01:~# kubectl apply -f 04.secrets_data-not-base64-error.yaml --dry-run=client
secret/data-not-base64-error created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 04.secrets_data-not-base64-error.yaml
Error from server (BadRequest): error when creating "04.secrets_data-not-base64-error.yaml": Secret in version "v1" cannot be handled as a Secret: illegal base64 data at input byte 
```

# 5 data和stringData字段中的key冲突,以stringData中的为准
```
root@master01:~# kubectl apply -f 05.secrets_data-stringdata-key-conflic-based-on-stringdata.yaml  --dry-run=client
secret/data-stringdata-key-conflic-based-on-stringdata created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 05.secrets_data-stringdata-key-conflic-based-on-stringdata.yaml 
secret/data-stringdata-key-conflic-based-on-stringdata created
root@master01:~#
root@master01:~# kubectl  -n lili get secret/data-stringdata-key-conflic-based-on-stringdata
NAME                                              TYPE     DATA   AGE
data-stringdata-key-conflic-based-on-stringdata   Opaque   1      37s
root@master01:~#
root@master01:~# kubectl  -n lili describe secret/data-stringdata-key-conflic-based-on-stringdata
Name:         data-stringdata-key-conflic-based-on-stringdata
Namespace:    lili
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
myname:  4 bytes
root@master01:~# kubectl  -n lili get secret/data-stringdata-key-conflic-based-on-stringdata -o json | jq ".data"
{
  "myname": "bGlsaQ=="
}
```



# 6 data和stringData中的键值对归档于data字段中

# 7 只使用data字段定义键值对即可 
