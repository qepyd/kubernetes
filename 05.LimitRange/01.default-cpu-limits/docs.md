# 1 创建limitRange/cpu-limit-range对象
```
## 注意：当前ns/lili对象中没有任何的LimitRange资源对象
root@master01:~# kubectl  -n lili get LimitRange
No resources found in lili namespace.
root@master01:~#

## 应用manifests
root@master01:~# kubectl apply -f 01.limitranges_cpu-limit-range.yaml  --dry-run=client
limitrange/cpu-limit-range created (dry run)
root@master01:~#
root@master01:~#
root@master01:~# kubectl apply -f 01.limitranges_cpu-limit-range.yaml 
limitrange/cpu-limit-range created

## 列出资源对象,并从在线manifests中获取关键信息
root@master01:~# kubectl  -n lili get limitrange/cpu-limit-range
NAME              CREATED AT
cpu-limit-range   2025-07-15T08:07:44Z
root@master01:~# 
root@master01:~# 
root@master01:~# kubectl  -n lili get limitrange/cpu-limit-range -o json | jq ".spec.limits"
[
  {
    "default": {
      "cpu": "800m"
    },
    "defaultRequest": {
      "cpu": "400m"
    },
    "type": "Container"
  }
]
```

# 2 验证1
Pod中容器没有定义resources字段,更没有requests和limits字段了。
```
## 应用manifests
root@master01:~# kubectl apply -f 02.pods_all-container-not-cpu-requests-limits.yaml  --dry-run=client
pod/all-container-not-cpu-requests-limits created (dry run)
root@master01:~#
root@master01:~#
root@master01:~# kubectl apply -f 02.pods_all-container-not-cpu-requests-limits.yaml
pod/all-container-not-cpu-requests-limits created

## 列出资源对象,并从在线manifests中获取关键信息
root@master01:~# kubectl  -n lili get pod/all-container-not-cpu-requests-limits
NAME                                    READY   STATUS    RESTARTS   AGE
all-container-not-cpu-requests-limits   2/2     Running   0          48s
root@master01:~#
root@master01:~#
root@master01:~# kubectl  -n lili get pod/all-container-not-cpu-requests-limits -o json | jq ".spec.containers[].name, .spec.containers[].resources"
"myapp01"
"busybox"
{
  "limits": {
    "cpu": "800m"
  },
  "requests": {
    "cpu": "400m"
  }
}
{
  "limits": {
    "cpu": "800m"
  },
  "requests": {
    "cpu": "400m"
  }
}
```

# 3 验证2
Pod中容器有定义resources字段,requests和limits字段下有定义cpu,其cpu的值超过了所在名称空间中其LimitRange的限制。
```
## 应用manifests
root@master01:~# kubectl apply -f 03.pods_container-resources-requests-limits-have-cpu-exceed.yaml  --dry-run=client
pod/container-resources-requests-limits-have-cpu-exceed created (dry run)
root@master01:~# 
root@master01:~# 
root@master01:~# kubectl apply -f 03.pods_container-resources-requests-limits-have-cpu-exceed.yaml
pod/container-resources-requests-limits-have-cpu-exceed created


## 列出资源对象,并从在线manifests中获取关键信息
root@master01:~# kubectl  -n lili get pod/container-resources-requests-limits-have-cpu-exceed
NAME                                                  READY   STATUS    RESTARTS   AGE
container-resources-requests-limits-have-cpu-exceed   1/1     Running   0          32s
root@master01:~# 
root@master01:~# 
root@master01:~# kubectl  -n lili get pod/container-resources-requests-limits-have-cpu-exceed -o json | jq ".spec.containers[].name, .spec.containers[].resources"
"myapp01"
{
  "limits": {
    "cpu": "1"
  },
  "requests": {
    "cpu": "1"
  }
}
```

# 4 验证3
Pod容器有定义resources字段,只有requests字段下定义有cpu，其cpu的值超过了所在名称空间中其LimitRange的限制。会直接报错，Pod不被kube-apiversion所接受。
```
root@master01:~# kubectl apply -f 04.pods_container-resources-requests-have-cpu-exceed.yaml  --dry-run=client
pod/container-resources-requests-have-cpu-exceed created (dry run)
root@master01:~#
root@master01:~#
root@master01:~# kubectl apply -f 04.pods_container-resources-requests-have-cpu-exceed.yaml 
The Pod "container-resources-requests-have-cpu-exceed" is invalid: spec.containers[0].resources.requests: Invalid value: "1": must be less than or equal to cpu limit
```

# 5 验证4
Pod中有的容器没有resources字段，有的容器有resources字段(requests和limits下有定义cpu,其值超过所在名称空间中LimitRange的限制)，有的容器有resources字段(只有requests字段下定义有cpu，其值
没有超过所在名称空间中其LimitRange的限制)
```
## 应用manifests
root@master01:~# kubectl apply -f 05.pods_cpu-comprehensive.yaml  --dry-run=client
pod/cpu-comprehensive created (dry run)
root@master01:~# 
root@master01:~# 
root@master01:~# kubectl apply -f 05.pods_cpu-comprehensive.yaml 
pod/cpu-comprehensive created

## 列出资源对象,并从在线manifests中获取关键信息
root@master01:~# kubectl  -n lili get pod/cpu-comprehensive
NAME                READY   STATUS    RESTARTS   AGE
cpu-comprehensive   0/3     Pending   0          46s
   #
   # Pod状态为Pendign，是因为我的k8s环境，没有任何的worker node能够满足Pod（各容器对cpu请求总和）对cpu的请求(requests)。
   # 
root@master01:~# kubectl  -n lili get pod/cpu-comprehensive -o json | jq ".spec.containers[].name, .spec.containers[].resources"
"busybox01"
"myapp01"
"youapp01"
{
  "limits": {
    "cpu": "800m"
  },
  "requests": {
    "cpu": "400m"
  }
}
{
  "limits": {
    "cpu": "1"
  },
  "requests": {
    "cpu": "1"
  }
}
{
  "limits": {
    "cpu": "800m"
  },
  "requests": {
    "cpu": "800m"
  }
}
```

# 6.清理环境
```
kubectl delete -f  01.limitranges_cpu-limit-range.yaml
kubectl delete -f  02.pods_all-container-not-cpu-requests-limits.yaml
kubectl delete -f  03.pods_container-resources-requests-limits-have-cpu-exceed.yaml
kubectl delete -f  04.pods_container-resources-requests-have-cpu-exceed.yaml    # 它根据就没有被kube-apiserver所收受。
kubectl delete -f  05.pods_cpu-comprehensive.yaml
```
