# 1 configmaps资源介绍
官方： https://kubernetes.io/zh-cn/docs/concepts/configuration/configmap/  
configmaps资源（简写cm，类型为ConfigMap）是kubernetes中的标准资源，属于namespace级别的资源。  
configmaps资源属于"配置"类的资源。我们在安装软件时会经过三步（安装、配置、启动），利用configmaps
资源对象可以将配置数据和应用程序代码分开，即Pod中容器所用image只关注程序代码和基本程序配置（启动所需）。


# 2 将configmaps用作pod中的文件
./02.using-configmaps-as-files-from-a-pod/
```

```

# 3 使用configmaps作为环境变量
./03.using-configmaps-as-environment-variables/
```

```




