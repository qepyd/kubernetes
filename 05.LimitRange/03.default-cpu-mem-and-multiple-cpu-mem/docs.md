# 1 创建limitRange/mem-limit-range对象
```
## 注意：当前ns/lili对象中没有任何的LimitRange资源对象
root@master01:~# kubectl  -n lili get LimitRange
No resources found in lili namespace.
root@master01:~#

## 应用manifests


## 列出资源对象,并从在线manifests中获取关键信息


```

# 2 验证1
Pod中容器没有定义resources字段,更没有requests和limits字段了。
```
## 应用manifests

## 列出资源对象,并从在线manifests中获取关键信息



```

# 3 验证2
Pod中容器有定义resources字段,requests和limits字段下有定义memory,其memory的值超过了所在名称空间中其LimitRange的限制。
```



```

# 4 验证3
Pod容器有定义resources字段,只有requests字段下定义有memory，其memory的值超过了所在名称空间中其LimitRange的限制。会直接报错，Pod不被kube-apiversion所接受。
```


```

# 5 验证4
Pod中有的容器没有resources字段，有的容器有resources字段(requests和limits下有定义memory,其值超过所在名称空间中LimitRange的限制)，有的容器有resources字段(只有requests字段下定义有memory，其值
没有超过所在名称空间中其LimitRange的限制)
```
## 应用manifests


## 列出资源对象,并从在线manifests中获取关键信息

```

# 6.清理环境
```

```
