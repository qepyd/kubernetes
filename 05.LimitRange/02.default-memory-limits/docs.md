# 1 创建limitRange/mem-limit-range对象
```
## 注意：当前ns/lili对象中没有任何的LimitRange资源对象
root@master01:~# kubectl  -n lili get LimitRange
No resources found in lili namespace.
root@master01:~#

## 应用manifests
root@master01:~# kubectl apply -f 01.limitranges_mem-limit-range.yaml  --dry-run=client
limitrange/mem-limit-range created (dry run)
root@master01:~#
root@master01:~#
root@master01:~# kubectl apply -f 01.limitranges_mem-limit-range.yaml
limitrange/mem-limit-range created

## 列出资源对象,并从在线manifests中获取关键信息
root@master01:~# kubectl  -n lili get limitrange/mem-limit-range
NAME              CREATED AT
mem-limit-range   2025-07-15T08:45:47Z
root@master01:~#
root@master01:~#  kubectl  -n lili get limitrange/mem-limit-range -o json  | jq ".spec.limits"
[
  {
    "default": {
      "memory": "512Mi"
    },
    "defaultRequest": {
      "memory": "256Mi"
    },
    "type": "Container"
  }
]
```

# 2 验证1
Pod中容器没有定义resources字段,更没有requests和limits字段了。
```
## 应用manifests
root@master01:~# kubectl apply -f 02.pods_all-container-not-memory-requests-limits.yaml  --dry-run=client
pod/all-container-not-memory-requests-limits created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 02.pods_all-container-not-memory-requests-limits.yaml 
pod/all-container-not-memory-requests-limits created

## 列出资源对象,并从在线manifests中获取关键信息
root@master01:~# kubectl  -n lili get pod/all-container-not-memory-requests-limits 
NAME                                       READY   STATUS    RESTARTS   AGE
all-container-not-memory-requests-limits   2/2     Running   0          46s
root@master01:~#
root@master01:~# kubectl  -n lili get pod/all-container-not-memory-requests-limits  -o json  | jq ".spec.containers[].name, .spec.containers[].resources"
"myapp01"
"busybox"
{
  "limits": {
    "memory": "512Mi"
  },
  "requests": {
    "memory": "256Mi"
  }
}
{
  "limits": {
    "memory": "512Mi"
  },
  "requests": {
    "memory": "256Mi"
  }
}
```

# 3 验证2
Pod中容器有定义resources字段,requests和limits字段下有定义memory,其memory的值超过了所在名称空间中其LimitRange的限制。
```
## 应用manifests
root@master01:~# kubectl apply -f 03.pods_container-resources-requests-limits-have-memory-exceed.yaml  --dry-run=client 
pod/container-resources-requests-limits-have-memory-exceed created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 03.pods_container-resources-requests-limits-have-memory-exceed.yaml 
pod/container-resources-requests-limits-have-memory-exceed created

## 列出资源对象,并从在线manifests中获取关键信息
root@master01:~# kubectl  -n lili get pod/container-resources-requests-limits-have-memory-exceed
NAME                                                     READY   STATUS    RESTARTS   AGE
container-resources-requests-limits-have-memory-exceed   1/1     Running   0          25s
root@master01:~#
root@master01:~#
root@master01:~# kubectl  -n lili get pod/container-resources-requests-limits-have-memory-exceed -o json | jq ".spec.containers[].name, .spec.containers[].resources"
"myapp01"
{
  "limits": {
    "memory": "600Mi"
  },
  "requests": {
    "memory": "600Mi"
  }
}
```

# 4 验证3
Pod容器有定义resources字段,只有requests字段下定义有memory，其memory的值超过了所在名称空间中其LimitRange的限制。会直接报错，Pod不被kube-apiversion所接受。
```
root@master01:~# kubectl apply -f 04.pods_container-resources-requests-have-memory-exceed.yaml --dry-run=client
pod/container-resources-requests-have-memory-exceed created (dry run)
root@master01:~# 
root@master01:~# kubectl apply -f 04.pods_container-resources-requests-have-memory-exceed.yaml
The Pod "container-resources-requests-have-memory-exceed" is invalid: spec.containers[0].resources.requests: Invalid value: "600Mi": must be less than or equal to memory limit
```

# 5 验证4
Pod中有的容器没有resources字段，有的容器有resources字段(requests和limits下有定义memory,其值超过所在名称空间中LimitRange的限制)，有的容器有resources字段(只有requests字段下定义有memory，其值
没有超过所在名称空间中其LimitRange的限制)
```
## 应用manifests
root@master01:~# kubectl apply -f 05.pods_memory-comprehensive.yaml  --dry-run=client
pod/memory-comprehensive created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 05.pods_memory-comprehensive.yaml 
pod/memory-comprehensive created


## 列出资源对象,并从在线manifests中获取关键信息
root@master01:~# kubectl  -n lili get pod/memory-comprehensive
NAME                   READY   STATUS    RESTARTS   AGE
memory-comprehensive   3/3     Running   0          23s
root@master01:~#
root@master01:~# kubectl  -n lili get pod/memory-comprehensive -o json | jq ".spec.containers[].name, .spec.containers[].resources"
"busybox01"
"myapp01"
"youapp01"
{
  "limits": {
    "memory": "512Mi"
  },
  "requests": {
    "memory": "256Mi"
  }
}
{
  "limits": {
    "memory": "600Mi"
  },
  "requests": {
    "memory": "600Mi"
  }
}
{
  "limits": {
    "memory": "512Mi"
  },
  "requests": {
    "memory": "512Mi"
  }
}
```

# 6.清理环境
```
kubectl delete -f  01.limitranges_mem-limit-range.yaml
kubectl delete -f  02.pods_all-container-not-memory-requests-limits.yaml
kubectl delete -f  03.pods_container-resources-requests-limits-have-memory-exceed.yaml
kubectl delete -f  04.pods_container-resources-requests-have-memory-exceed.yaml  # 它根据就没有被kube-apiserver所收受。
kubectl delete -f  05.pods_memory-comprehensive.yaml
```
