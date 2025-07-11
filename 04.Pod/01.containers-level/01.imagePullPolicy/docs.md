# 1.Image的拉取策略
**官方参考连接**
```
https://kubernetes.io/zh-cn/docs/concepts/containers/images/#imagepullpolicy-defaulting
```

**镜像的格式**
```
RegistoryName/RepositoryName/ImageName:VersionName
```

**相关策略及含义**  
不可在线修改
```
IfNotPresent
    # 
    # 如果省略了pods.spec.containers/initContainers.imagePullPolicy字段,则会根据image的VersionName。
    #
    # 当image的VersionName有指定且不为latest时，则默认为IfNotPresent。
    #
    # 本地若有则使用本地镜像，本地若没有则去镜像仓库中拉取。
    #   若本地有镜像，镜像其"版本名称"是标签(Tag)形式，用到的镜像可能是旧版本。
    #   若本地有镜像，镜像其"版本名称"是摘要(Digest)形式，用到的镜像始终是想要的版本。
    # 
Always
    # 
    # 如果省略了pods.spec.containers/initContainers.imagePullPolicy字段,则会根据image的VersionName。
    # 
    # 当image的VersionName未指定或指定为latest时，则默认为Always。
    #
    # 总是拉取镜像，即使本地有镜像也从仓库拉取。
    #    每当kubelet启动一个容器时，kubelet会查询容器的镜像仓库,将名称解析为一个镜像摘要。 
    #    如果kubelet有一个容器镜像，并且对应的摘要已在本地缓存，kubelet就会使用其缓存的镜像；
    #    否则，kubelet就会使用解析后的摘要拉取镜像，并使用该镜像来启动容器。 
    #    
Never
    # 
    # 不管其image的VersionName是否指定、指定的是什么，只要其imagePullPolicy为Never时。
    # 
    # 从不执行拉取操作，只使用本地镜像，本地或没有就会报错。
    #   当然你也可以事先在各worker node上把镜像拉取好。
    #   k8s的worker node可能有很多(你怎么知道Pod会被调度至哪个worker node呢？若镜像未公开，得登录Registory吧！)
    # 
```

# 2.镜像拉取策略(默认IfNotPresent）
**应用manifests**
```
root@master01:~# kubectl apply -f 01.pods_default-ifnotpresent.yaml  --dry-run=client
pod/default-ifnotpresent created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f 01.pods_default-ifnotpresent.yaml
pod/default-ifnotpresent created
```

**列出Pod资源对象,并查看所有主容器其image的imagePullPolicy**
```
## 列出ns/lili对象中的Pod/default-ifnotpresent对象
root@master01:~# kubectl -n lili get Pod/default-ifnotpresent
NAME                   READY   STATUS    RESTARTS   AGE
default-ifnotpresent   1/1     Running   0          96s

## 查看ns/lili对象中其Pod/default-ifnotpresent对象中所有主容器其image的imagePullPolicy
root@master01:~# kubectl -n lili get Pod/default-ifnotpresent -o json | jq ".spec.containers[].name, .spec.containers[].image, .spec.containers[].imagePullPolicy"
"myapp01"
"swr.cn-north-1.myhuaweicloud.com/library/nginx:1.16"
"IfNotPresent"
```



# 3.镜像拉取策略(默认Always)
**应用manifests**
```
root@master01:~# kubectl apply -f 02.pods_default-always.yaml  --dry-run=client
pod/default-always created (dry run)
root@master01:~# 
root@master01:~# kubectl apply -f 02.pods_default-always.yaml
pod/default-always created
```

**列出Pod资源对象,并查看所有主容器其image的imagePullPolicy**
```
## 列出ns/lili对象中的Pod/default-always对象
root@master01:~# kubectl -n lili get Pod/default-always
NAME             READY   STATUS    RESTARTS   AGE
default-always   1/1     Running   0          92s

## 查看ns/lili对象中其Pod/default-always对象中所有主容器其image的imagePullPolicy
root@master01:~# kubectl -n lili get Pod/default-always -o json | jq ".spec.containers[].name, .spec.containers[].image, .spec.containers[].imagePullPolicy"
"myapp01"
"swr.cn-north-1.myhuaweicloud.com/library/nginx:latest"
"Always"
```


# 4.镜像拉取策略(Never)
```
```

# 5.建议(image的VersionName指定且不为latest,拉取策略为Always)
```
```

