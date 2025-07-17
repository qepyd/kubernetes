# 1. 基本介绍及实践索引
limitranges资源（简写limits，kind为LimitRange）是kubernetes中的标准资源，是namespace级别的资源。  
官方参考：https://kubernetes.io/zh-cn/docs/concepts/policy/limit-range/  
```
对所在namespace中各Pod中的Containers设置默认的资源requests和limtis
  ./01.containers-default-cpu-mem/

对所在namespace中各Pod中的Container设置其计算资源范围限制
  ./02.containers-max-min-cpu-mem-not-have-Ratio-1/
  ./03.containers-max-min-cpu-mem-not-have-Ratio-2/

对所在namespace中各Pod中的Container设置其计算资源范围限制、最大比值限制
  ./04.containers-max-min-cpu-mem-have-Ratio/

对所在namespace中各Pod总计算资源的限制
  ./05.pod-max-cpu-mem/ 

对所在namesapce中各pvc（PersistentVolumeClaim）能申请的最大最小存储空间限制
  ./06.pvc-max-min/
```

# 2. 综合的配合示例
建议在namespace中只配置一个LimitRange资源对象,其相关资源量的配置是可以在线修改的。
```
apiVersion: v1
kind: LimitRange
metadata:
  namespace: lili
  name: limitranges
spec:
  limits:
  ## Pod中的各主容器其相关计算资源的限制
  - type: Container
    # <== Pod中各主容器未人为配置resources时,让其根据此处的定义。
    #     Pod中不能超过2个主容器，因为得符合 "- type: Pod" 处。
    default: 
      cpu: "2"     
      memory: "2Gi"
    defaultRequest:  
      cpu: "2"
      memory: "2Gi"
    # <== Pod中各主容器若人为配置resources时，是有最大、最小区间。
    #     另外还得符合 "- type: Pod" 处。
    max:
      cpu: "4"
      memory: "4Gi"
    min:
      cpu: "500m"
      memory: "512Mi"
    # <== 最大比值
    maxLimitRequestRatio:
      cpu: "8"           # max 4000m  / min 500m
      memory: "8"        # max 4096Mi / min 512Mi 
  ## Pod中所有主容器其相关计算资源总和的限制
  - type: Pod
    max:
      cpu: "4"
      memory: "8Gi"
  - type: PersistentVolumeClaim
    max:
      storage: 50Gi
    #min:
    #  storage: 30Gi
```
