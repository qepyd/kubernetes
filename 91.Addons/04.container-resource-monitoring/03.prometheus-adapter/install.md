# 1.prometheus-adapter相关的说明
**prometheus-adapter代码托管仓库**
```
https://github.com/kubernetes-sigs/prometheus-adapter
```

**prometheus-adapter与prometheus**
```
01:prometheus-adapter依赖prometheus
   只用prometheus的指标收集功能，告警功能这些都不用。
   通过kubernetes_sd_configs发现机制中只使用pod这个role,配置其发现k8s集群中所有的Pod,

02:prometheus收集Pod的指标(metrics),而prometheus-adapter将prometheus收集的指标转换成k8s能够识别
   的指标。从而为k8s中的标准资源hpa(horizontalpodautoscalers  hpa autoscaling/v2 true   HorizontalPodAutoscaler)所使用,
   (例如：根据Pod的连接数进行水平扩展)。

03:prometheus-adapter安装后的APIService为
   v0.11.0 开始：v1beta1.metrics.k8s.io           
      #
      # metrics.k8s.io是Group，v1betal是version
      # 其Group和metrics-server项目的是一样的了
      # 
   v0.11.0 之前：v1beta1.external.metrics.k8s.io  
      #
      # external.metrics.k8s.io是Group，v1betal是version，
      #
```


# 2.创建ns/prometheus-adapter对象
```
kubectl apply -f ns_prometheus-adapter.yaml  --dry-run=client
kubectl apply -f ns_prometheus-adapter.yaml

kubectl get   -f ns_prometheus-adapter.yaml
```

# 3.部署prometheus server
```
kubectl apply -f ./prometheus/
```

