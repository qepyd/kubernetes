# 1 创建limitRange/mem-limit-range对象
```
## 注意：当前ns/lili对象中没有任何的LimitRange资源对象
root@master01:~# kubectl  -n lili get LimitRange
No resources found in lili namespace.
root@master01:~#

## 应用manifests
root@master01:~# kubectl apply -f 01.limitranges_cpu-limit-range.yaml  -f 02.limitranges_mem-limit-range.yaml  -f 03.limitranges_cpu-limitrange.yaml  -f 04.limitranges_mem-limitrange.yaml  --dry-run=client
limitrange/cpu-limit-range created (dry run)
limitrange/mem-limit-range created (dry run)
limitrange/cpu-limitrange created (dry run)
limitrange/mem-limitrange created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 01.limitranges_cpu-limit-range.yaml  -f 02.limitranges_mem-limit-range.yaml  -f 03.limitranges_cpu-limitrange.yaml  -f 04.limitranges_mem-limitrange.yaml
limitrange/cpu-limit-range created
limitrange/mem-limit-range created
limitrange/cpu-limitrange created
limitrange/mem-limitrange created

## 列出资源对象,并从在线manifests中获取关键信息
root@master01:~# kubectl -n lili get limitrange/cpu-limit-range  -o json | jq ".spec.limits"
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

root@master01:~# kubectl -n lili get limitrange/cpu-limitrange  -o json | jq ".spec.limits"
[
  {
    "default": {
      "cpu": "900m"
    },
    "defaultRequest": {
      "cpu": "500m"
    },
    "type": "Container"
  }
]


root@master01:~# kubectl -n lili get limitrange/mem-limit-range  -o json | jq ".spec.limits"
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

root@master01:~# kubectl -n lili get limitrange/mem-limitrange  -o json | jq ".spec.limits"
[
  {
    "default": {
      "memory": "612Mi"
    },
    "defaultRequest": {
      "memory": "356Mi"
    },
    "type": "Container"
  }
]

```

# 2 验证1
```
## 应用manifests
root@master01:~#  kubectl apply -f 05.pods_all-container-not-cpu-mem-requests-limits.yaml  --dry-run=client
pod/all-container-not-cpu-mem-requests-limits created (dry run)
root@master01:~# 
root@master01:~# kubectl apply -f 05.pods_all-container-not-cpu-mem-requests-limits.yaml 
pod/all-container-not-cpu-mem-requests-limits created

## 列出资源对象,并从在线manifests中获取关键信息
root@master01:~# kubectl  -n lili get pod/all-container-not-cpu-mem-requests-limits
NAME                                        READY   STATUS    RESTARTS   AGE
all-container-not-cpu-mem-requests-limits   2/2     Running   0          72s
root@master01:~#
root@master01:~#
root@master01:~# kubectl  -n lili get pod/all-container-not-cpu-mem-requests-limits -o json | jq ".spec.containers[].name, .spec.containers[].resources"
"myapp01"
"busybox"
{
  "limits": {
    "cpu": "800m",
    "memory": "512Mi"
  },
  "requests": {
    "cpu": "400m",
    "memory": "256Mi"
  }
}
{
  "limits": {
    "cpu": "800m",
    "memory": "512Mi"
  },
  "requests": {
    "cpu": "400m",
    "memory": "256Mi"
  }
}
```

# 3 验证2
```
## 应用manifests
root@master01:~# kubectl apply -f 06.pods_container-resources-requests-limits-cpu-mem-exceed-max-range.yaml  --dry-run=client
pod/container-resources-requests-limits-cpu-mem-exceed-max-range created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 06.pods_container-resources-requests-limits-cpu-mem-exceed-max-range.yaml 
pod/container-resources-requests-limits-cpu-mem-exceed-max-range created

## 列出资源对象,并从在线manifests中获取关键信息
root@master01:~# kubectl  -n lili get pod/container-resources-requests-limits-cpu-mem-exceed-max-range
NAME                                                           READY   STATUS    RESTARTS   AGE
container-resources-requests-limits-cpu-mem-exceed-max-range   1/1     Running   0          21s
root@master01:~#
root@master01:~# 
root@master01:~# kubectl  -n lili get pod/container-resources-requests-limits-cpu-mem-exceed-max-range -o json | jq ".spec.containers[].name, .spec.containers[].resources"
"myapp01"
{
  "limits": {
    "cpu": "1",
    "memory": "521Mi"
  },
  "requests": {
    "cpu": "1",
    "memory": "521Mi"
  }
}
```

# 4 验证3
```
root@master01:~# kubectl apply -f 07.pods_container-resources-requests-cpu-mem-exceed-max-range.yaml --dry-run=client
pod/container-resources-requests-cpu-mem-exceed-max-range created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 07.pods_container-resources-requests-cpu-mem-exceed-max-range.yaml
The Pod "container-resources-requests-cpu-mem-exceed-max-range" is invalid: 
* spec.containers[0].resources.requests: Invalid value: "850m": must be less than or equal to cpu limit
* spec.containers[0].resources.requests: Invalid value: "521Mi": must be less than or equal to memory limit
```

# 5 验证4
```
## 应用manifests
root@master01:~# kubectl apply -f 08.pods_cpu-memory-comprehensive.yaml  --dry-run=client
pod/cpu-memory-comprehensive created (dry run)
root@master01:~#
root@master01:~#  kubectl apply -f 08.pods_cpu-memory-comprehensive.yaml
pod/cpu-memory-comprehensive created

## 列出资源对象,并从在线manifests中获取关键信息
root@master01:~# kubectl  -n lili get pod/cpu-memory-comprehensive
NAME                       READY   STATUS    RESTARTS   AGE
cpu-memory-comprehensive   0/3     Pending   0          19s            # Pending状态是因为我k8s各worker node没有满足Pod其总(cpu或memory)的requests
root@master01:~#
root@master01:~#
root@master01:~# kubectl  -n lili get pod/cpu-memory-comprehensive -o json | jq ".spec.containers[].name, .spec.containers[].resources"
"busybox01"
"myapp01"
"youapp01"
{
  "limits": {
    "cpu": "800m",
    "memory": "512Mi"
  },
  "requests": {
    "cpu": "400m",
    "memory": "256Mi"
  }
}
{
  "limits": {
    "cpu": "1",
    "memory": "521Mi"
  },
  "requests": {
    "cpu": "1",
    "memory": "521Mi"
  }
}
{
  "limits": {
    "cpu": "800m",
    "memory": "512Mi"
  },
  "requests": {
    "cpu": "800m",
    "memory": "512Mi"
  }
}

```

# 6.清理环境
```
kubectl delete -f 01.limitranges_cpu-limit-range.yaml
kubectl delete -f 02.limitranges_mem-limit-range.yaml
kubectl delete -f 03.limitranges_cpu-limitrange.yaml
kubectl delete -f 04.limitranges_mem-limitrange.yaml
kubectl delete -f 05.pods_all-container-not-cpu-mem-requests-limits.yaml
kubectl delete -f 06.pods_container-resources-requests-limits-cpu-mem-exceed-max-range.yaml
kubectl delete -f 07.pods_container-resources-requests-cpu-mem-exceed-max-range.yaml
kubectl delete -f 08.pods_cpu-memory-comprehensive.yaml
```
