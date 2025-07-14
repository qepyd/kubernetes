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


## 2.2 only-limits


# 3 Pod的服务质量(QoS)

## 3.1 Guaranteed 

## 3.2 Bustable

## 3.3 BestEffort


# 4 限制(limits)的效果演示 

