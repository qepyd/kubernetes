## 1.基本说明
```
k8s的基本架构部署好以后:  
  第一个要部署的插件就是cni网络插件   
  第二个要部署的插件就是dns插件  
一套k8s中的dsn插件部署一个即可:  
  选择某一种软件产品来实现,且只部署一套.  
```

## 2.相关引入

kubernetes在部署前要规划的项包含
```
Dns的Domain：默认是cluster.local
Service网络：例如：10.144.0.0/16,不用划分subnet
```

各woker node上的kubelet组件实例
```
--cluster-dns参数指所谓Dns应用对外提供服务的IP地址
  没有默认值,你得指定一个地址
    本地为k8s集群内部dns应用充当dnsCache的应用所绑定的地址(例如:169.254.20.10，这是个私有地址)
    或
    k8s集群内dns应用的连接地址(得来自于Service网络)
  若不指定
    被调用过来的Pod,里面的container其/etc/resolv.conf文件中的内容完成以以宿主机的/etc/resolv.conf为准

--cluster-domain参数指定Dns的Domain
  默认是cluster.local
```

   
  

