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

02:prometheus收集Pod(应用程序自身暴露的指标兼容prometheus格式)所暴露的指标(metrics)。

03:prometheus-adapter定期从Prometheus收集可用指标的名称。

04:prometheus-adapter安装后的APIService资源对象为
   v0.11.0 开始：
      # 
      # 只有 APIService/v1beta1.metrics.k8s.io 对象 
      # APIGroup例如：metrics.k8s.io
      # APIVersion例如：v1beta1
      #
      # 其APIGroup、APIVersion和metrics-server项目的是一样的了
      #  
   v0.11.0 之前：
      #
      # 拥有 APIService/v1beta1.external.metrics.k8s.io、APIService/v1beta2.custom.metrics.k8s.io、APIService/v1beta1.external.metrics.k8s.io 对象
      # APIGroup例如：external.metrics.k8s.io、custom.metrics.k8s.io、external.metrics.k8s.io
      # APIVersion例如：v1beta1、v1beta2
      #

05:为k8s中的标准资源hpa(horizontalpodautoscalers  hpa autoscaling/v2 true   HorizontalPodAutoscaler)就可以根据
   prometheus-adapter所收集到的指标进行水平扩展。 
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

