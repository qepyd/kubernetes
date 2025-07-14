# 1 Pod中容器的资源请求(requests)和限制(limits)
**相关字段**
```
pods.spec.containers.resources.requests
pods.spec.containers.resources.limtis
```
**requests和limits常见资源及其单位**  
https://kubernetes.io/zh-cn/docs/concepts/configuration/manage-resources-containers/#resource-requests-and-limits-of-pod-and-container  
```
cpu
  https://kubernetes.io/zh-cn/docs/concepts/configuration/manage-resources-containers/#meaning-of-cpu
  单位可以是整核数、浮点核数、豪核(m)
  整  核：1=1核=100%(最大100%使用率)
  浮点核：0.5=0.5核=50%(最大50%使用率)
  豪  核：1核=1000m  0.5核=500m  1.2核=1200m

memory
  https://kubernetes.io/zh-cn/docs/concepts/configuration/manage-resources-containers/#meaning-of-memory
  以字节为单位进行限制，你可以使用普通的整数，或者配合相关单位，其相关单位为：k或Ki, M或Mi, G或Gi, T或Ti, P或Pi, E或Ei
```

**requests**
```
请求
Pod中各容器其requests下的相关资源量在Pod调度时就得要能够被满足。
会影响Pod的调度。
```

**limits**
```
限制
Pod中各容器其limits下的相关资源量用于限制容器中应用程序最大能够使用的资源量。
```


# 2 请求(requests)会影响Pod调度
## 2.1 only-requests
**无法满足Pod中各容器其请求(requests)**
```
## 应用manifests
kubectl apply -f 01.only-requests-but-requests-effect-pod-dispatch-01.yaml \
              -f 02.only-requests-but-requests-effect-pod-dispatch-02.yaml \
              -f 03.only-requests-but-requests-effect-pod-dispatch-03.yaml --dry-run=client

kubectl apply -f 01.only-requests-but-requests-effect-pod-dispatch-01.yaml \
              -f 02.only-requests-but-requests-effect-pod-dispatch-02.yaml \
              -f 03.only-requests-but-requests-effect-pod-dispatch-03.yaml 

## 列出相关资源对象
root@master01:~# kubectl get -f 01.only-requests-but-requests-effect-pod-dispatch-01.yaml  -f 02.only-requests-but-requests-effect-pod-dispatch-02.yaml   -f 03.only-requests-but-requests-effect-pod-dispatch-03.yaml  -o wide
NAME                                                READY   STATUS    RESTARTS   AGE     IP       NODE     NOMINATED NODE   READINESS GATES
only-requests-but-requests-effect-pod-dispatch-01   0/1     Pending   0          4m55s   <none>   <none>   <none>           <none>
only-requests-but-requests-effect-pod-dispatch-02   0/1     Pending   0          4m54s   <none>   <none>   <none>           <none>
only-requests-but-requests-effect-pod-dispatch-03   0/1     Pending   0          4m54s   <none>   <none>   <none>           <none>
  #
  # 其Pod的状态为 Pending(等待)
  # 等待被调度，因为当前没有任何的worker node能够满足Pod中各容器的请求(requests)
  #

## 可以看看其Pod的描述信息
kubectl -n lili describe Pod/only-requests-but-requests-effect-pod-dispatch-01
kubectl -n lili describe Pod/only-requests-but-requests-effect-pod-dispatch-02
kubectl -n lili describe Pod/only-requests-but-requests-effect-pod-dispatch-03


## 查看Pod其资源请求(requests)和限制(limits)
root@master01:~# kubectl get -f 01.only-requests-but-requests-effect-pod-dispatch-01.yaml -o json | jq ".spec.containers[].name, .spec.containers[].resources.requests, .spec.containers[].resources.limits"
"myapp01"
{
  "cpu": "100",
  "memory": "100Gi"
}
null
root@master01:~#
root@master01:~#
root@master01:~# kubectl get -f 02.only-requests-but-requests-effect-pod-dispatch-02.yaml -o json | jq ".spec.containers[].name, .spec.containers[].resources.requests, .spec.containers[].resources.limits"
"myapp01"
{
  "cpu": "100m",
  "memory": "100Gi"
}
null
root@master01:~#
root@master01:~#
root@master01:~# kubectl get -f 03.only-requests-but-requests-effect-pod-dispatch-03.yaml -o json | jq ".spec.containers[].name, .spec.containers[].resources.requests, .spec.containers[].resources.limits"
"myapp01"
{
  "cpu": "100",
  "memory": "100Mi"
}
null
```

**可以满足Pod中各容器其请求(requests)**
```
## 应用manifests
root@master01:~# kubectl apply -f 04.only-requests-but-requests-effect-pod-dispatch-04.yaml  -f 05.only-requests-but-requests-effect-pod-dispatch-05.yaml --dry-run=client
pod/only-requests-but-requests-effect-pod-dispatch-04 created (dry run)
pod/only-requests-but-requests-effect-pod-dispatch-05 created (dry run)
root@master01:~#
root@master01:~#
root@master01:~# kubectl apply -f 04.only-requests-but-requests-effect-pod-dispatch-04.yaml  -f 05.only-requests-but-requests-effect-pod-dispatch-05.yaml
pod/only-requests-but-requests-effect-pod-dispatch-04 created
pod/only-requests-but-requests-effect-pod-dispatch-05 created

## 列出相关Pod
root@master01:~# kubectl get -f 04.only-requests-but-requests-effect-pod-dispatch-04.yaml  -f 05.only-requests-but-requests-effect-pod-dispatch-05.yaml  -o wide
NAME                                                READY   STATUS    RESTARTS   AGE   IP           NODE     NOMINATED NODE   READINESS GATES
only-requests-but-requests-effect-pod-dispatch-04   1/1     Running   0          37s   10.0.4.117   node02   <none>           <none>
only-requests-but-requests-effect-pod-dispatch-05   2/2     Running   0          37s   10.0.4.118   node02   <none>           <none>

## 查看Pod其资源请求(requests)和限制(limits)
root@master01:~# kubectl get -f 04.only-requests-but-requests-effect-pod-dispatch-04.yaml  -o json | jq ".spec.containers[].name, .spec.containers[].resources.requests, .spec.containers[].resources.limits"
"myapp01"
{
  "cpu": "100m",
  "memory": "100Mi"
}
null
root@master01:~#
root@master01:~#
root@master01:~# kubectl get -f 05.only-requests-but-requests-effect-pod-dispatch-05.yaml  -o json | jq ".spec.containers[].name, .spec.containers[].resources.requests, .spec.containers[].resources.limits"
"myapp01"
"busybox"
{
  "cpu": "100m",
  "memory": "100Mi"
}
{
  "cpu": "50m",
  "memory": "50Mi"
}
null
null
```

## 2.2 only-limits
**无法满足Pod中各容器其请求(requests)**
```
## 应用manifests
root@master01:~# kubectl apply -f 06.only-limits-but-requests-effect-pod-dispatch-01.yaml  -f 07.only-limits-but-requests-effect-pod-dispatch-02.yaml  -f 08.only-limits-but-requests-effect-pod-dispatch-03.yaml  --dry-run=client
pod/only-limits-effect-pod-dispatch-01 created (dry run)
pod/only-limits-effect-pod-dispatch-02 created (dry run)
pod/only-limits-effect-pod-dispatch-03 created (dry run)
root@master01:~#
root@master01:~#
root@master01:~# kubectl apply -f 06.only-limits-but-requests-effect-pod-dispatch-01.yaml  -f 07.only-limits-but-requests-effect-pod-dispatch-02.yaml  -f 08.only-limits-but-requests-effect-pod-dispatch-03.yaml 
pod/only-limits-effect-pod-dispatch-01 created
pod/only-limits-effect-pod-dispatch-02 created
pod/only-limits-effect-pod-dispatch-03 created

## 列出Pod资源对象
root@master01:~# kubectl get -f 06.only-limits-but-requests-effect-pod-dispatch-01.yaml  -f 07.only-limits-but-requests-effect-pod-dispatch-02.yaml  -f 08.only-limits-but-requests-effect-pod-dispatch-03.yaml -o wide
NAME                                 READY   STATUS    RESTARTS   AGE   IP       NODE     NOMINATED NODE   READINESS GATES
only-limits-effect-pod-dispatch-01   0/1     Pending   0          48s   <none>   <none>   <none>           <none>
only-limits-effect-pod-dispatch-02   0/1     Pending   0          48s   <none>   <none>   <none>           <none>
only-limits-effect-pod-dispatch-03   0/1     Pending   0          48s   <none>   <none>   <none>           <none>

## 可以看看其Pod的描述信息
kubectl -n lili describe Pod/only-limits-effect-pod-dispatch-01
kubectl -n lili describe Pod/only-limits-effect-pod-dispatch-02
kubectl -n lili describe Pod/only-limits-effect-pod-dispatch-03


## 查看Pod其资源请求(requests)和限制(limits)
root@master01:~# kubectl get Pod/only-limits-effect-pod-dispatch-01 -o json | jq ".spec.containers[].name, .spec.containers[].resources.requests, .spec.containers[].resources.limits"
"myapp01"
{
  "cpu": "100",
  "memory": "100Gi"
}
{
  "cpu": "100",
  "memory": "100Gi"
}
root@master01:~#
root@master01:~#
root@master01:~# kubectl get Pod/only-limits-effect-pod-dispatch-02 -o json | jq ".spec.containers[].name, .spec.containers[].resources.requests, .spec.containers[].resources.limits"
"myapp01"
{
  "cpu": "100m",
  "memory": "100Gi"
}
{
  "cpu": "100m",
  "memory": "100Gi"
}
root@master01:~#
root@master01:~#
root@master01:~# kubectl get Pod/only-limits-effect-pod-dispatch-03 -o json | jq ".spec.containers[].name, .spec.containers[].resources.requests, .spec.containers[].resources.limits"
"myapp01"
{
  "cpu": "100",
  "memory": "100Mi"
}
{
  "cpu": "100",
  "memory": "100Mi"
}
```


**可以满足Pod中各容器其请求(requests)**
```
## 应用manifests
root@master01:~# kubectl apply -f 09.only-limits-but-requests-effect-pod-dispatch-04.yaml  -f 10.only-limits-but-requests-effect-pod-dispatch-05.yaml  --dry-run=client
pod/only-limits-effect-pod-dispatch-04 created (dry run)
pod/only-limits-effect-pod-dispatch-05 created (dry run)
root@master01:~#
root@master01:~#
root@master01:~# kubectl apply -f 09.only-limits-but-requests-effect-pod-dispatch-04.yaml  -f 10.only-limits-but-requests-effect-pod-dispatch-05.yaml
pod/only-limits-effect-pod-dispatch-04 created
pod/only-limits-effect-pod-dispatch-05 created

## 列出Pod资源对象
root@master01:~# kubectl get -f 09.only-limits-but-requests-effect-pod-dispatch-04.yaml  -f 10.only-limits-but-requests-effect-pod-dispatch-05.yaml -o wide
NAME                                 READY   STATUS    RESTARTS   AGE   IP           NODE     NOMINATED NODE   READINESS GATES
only-limits-effect-pod-dispatch-04   1/1     Running   0          35s   10.0.4.120   node02   <none>           <none>
only-limits-effect-pod-dispatch-05   2/2     Running   0          35s   10.0.4.119   node02   <none>           <none>

## 可以看看其Pod的描述信息
kubectl -n lili describe Pod/only-limits-effect-pod-dispatch-04
kubectl -n lili describe Pod/only-limits-effect-pod-dispatch-05

## 查看Pod其资源请求(requests)和限制(limits)
root@master01:~# kubectl -n lili get Pod/only-limits-effect-pod-dispatch-04  -o json | jq ".spec.containers[].name, .spec.containers[].resources.requests, .spec.containers[].resources.limits"
"myapp01"
{
  "cpu": "100m",
  "memory": "100Mi"
}
{
  "cpu": "100m",
  "memory": "100Mi"
}
root@master01:~#
root@master01:~#
root@master01:~# kubectl -n lili get Pod/only-limits-effect-pod-dispatch-05 -o json | jq ".spec.containers[].name, .spec.containers[].resources.requests, .spec.containers[].resources.limits"
"myapp01"
"busybox"
{
  "cpu": "100m",
  "memory": "100Mi"
}
{
  "cpu": "50m",
  "memory": "50Mi"
}
{
  "cpu": "100m",
  "memory": "100Mi"
}
{
  "cpu": "50m",
  "memory": "50Mi"
}
```

# 3 Pod的服务质量(QoS)
## 3.1 Guaranteed 
**说明**
```
## Pod的服务质量(Qos)之Guaranteed(保证)
# 
#  Guaranteed > Bustable > BestEffort
# 
#  官方：https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/quality-service-pod/#create-a-pod-that-gets-assigned-a-qos-class-of-guaranteed
#   
#  Pod中每个容器必须指定cpu、memory的requests和limits。 
#  requests中的cpu、memory和limits中的cpu、memory的值得相等。
```
**实践**
```
## 应用manifests
root@master01:~# kubectl apply -f 11.pod-qos-to-guaranteed.yaml  --dry-run=client
pod/pod-qos-to-guaranteed created (dry run)
root@master01:~#
root@master01:~#
root@master01:~# kubectl apply -f 11.pod-qos-to-guaranteed.yaml
pod/pod-qos-to-guaranteed created

## 列出资源对象
root@master01:~# kubectl -n lili get pod/pod-qos-to-guaranteed  -o wide
NAME                    READY   STATUS    RESTARTS   AGE   IP           NODE     NOMINATED NODE   READINESS GATES
pod-qos-to-guaranteed   2/2     Running   0          38s   10.0.4.121   node02   <none>           <none>

## 列出资源对象的资源请求(requests)和限制(limits)
root@master01:~# kubectl -n lili get pod/pod-qos-to-guaranteed  -o json | jq ".spec.containers[].name, .spec.containers[].resources.requests, .spec.containers[].resources.limits"
"myapp01"
"busybox"
{
  "cpu": "100m",
  "memory": "100Mi"
}
{
  "cpu": "50m",
  "memory": "50Mi"
}
{
  "cpu": "100m",
  "memory": "100Mi"
}
{
  "cpu": "50m",
  "memory": "50Mi"
}

## 查看Pod的QoS
root@master01:~# kubectl -n lili get pod/pod-qos-to-guaranteed  -o json | jq ".status.qosClass"
"Guaranteed"
```

## 3.2 Bustable
**说明**
```
## Pod的服务质量(Qos)之Bustable(满足)
#
#  Guaranteed > Bustable > BestEffort
# 
#  官方：https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/quality-service-pod/#create-a-pod-that-gets-assigned-a-qos-class-of-burstable
#   
#  Pod中至少得有一个容器具备cpu或memory的requests或limits。 
#
```
**实践**
```
## 应用manifests
root@master01:~# kubectl apply -f 12.pod-qos-to-bustable.yaml  --dry-run=client
pod/pod-qos-to-bustable created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 12.pod-qos-to-bustable.yaml
pod/pod-qos-to-bustable created

## 列出资源对象
root@master01:~# kubectl -n lili get pod/pod-qos-to-bustable  -o wide
NAME                  READY   STATUS    RESTARTS   AGE   IP           NODE     NOMINATED NODE   READINESS GATES
pod-qos-to-bustable   2/2     Running   0          36s   10.0.4.122   node02   <none>           <none>

## 列出资源对象的资源请求(requests)和限制(limits)
root@master01:~# kubectl -n lili get pod/pod-qos-to-bustable  -o json | jq ".spec.containers[].name, .spec.containers[].resources.requests, .spec.containers[].resources.limits"
"myapp01"
"busybox"
{
  "memory": "100Mi"
}
null
{
  "memory": "100Mi"
}
null


## 查看Pod的QoS
root@master01:/qepyd/kubernetes/04.Pod/01.containers-level/06.resources# kubectl -n lili get pod/pod-qos-to-bustable  -o json | jq ".status.qosClass"
"Burstable"
```


## 3.3 BestEffort
**说明**
```
## Pod的服务质量(Qos)之BestEffort(满足)
#
#  Guaranteed > Bustable > BestEffort
#
#  官方：https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/quality-service-pod/#create-a-pod-that-gets-assigned-a-qos-class-of-besteffort
#  
#  Pod中必须任何容器均没有 resources(pods.spec.containers.resources)
```

**实践**
```
## 应用manifests
root@master01:~# kubectl apply -f 13.pod-qos-to-besteffort.yaml  --dry-run=client
pod/pod-qos-to-besteffort created (dry run)
root@master01:~# 
root@master01:~# kubectl apply -f 13.pod-qos-to-besteffort.yaml 
pod/pod-qos-to-besteffort created

## 列出资源对象
root@master01:~# kubectl -n lili get pod/pod-qos-to-besteffort -o wide
NAME                    READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
pod-qos-to-besteffort   2/2     Running   0          31s   10.0.3.15   node01   <none>           <none>

## 列出资源对象的资源请求(requests)和限制(limits)
root@master01:~#  kubectl -n lili get pod/pod-qos-to-besteffort -o json | jq ".spec.containers[].name, .spec.containers[].resources.requests, .spec.containers[].resources.limits"
"myapp01"
"busybox"
null
null
null
null


## 查看Pod的QoS
root@master01:~# kubectl -n lili get pod/pod-qos-to-besteffort  -o json | jq ".status.qosClass"
"BestEffort"
```




# 4 限制(limits)的效果演示 

