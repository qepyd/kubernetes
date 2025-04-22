## 1. 实践的目标
```
当工作负载其性能不饱合时,且hpa又没有设置spec.behavior字段中的相关字段时,
会让其工作负载的副本数与minRepolicas的值保持一致。
  01：当deploy/app01 最开始定义的副本数是 1
  02：而hpa/app01 中最小副本数是 2
  03: 最终deploy/app01的副本数为 2
```

## 2. 验证
```
root@k8s-master01:~/tools/metrics-server/03.hpa-resources-practice/02.hpa-resources-practice/paractice02# kubectl apply -f 01.deploy_app02.yaml 
deployment.apps/app02 created

root@k8s-master01:~/tools/metrics-server/03.hpa-resources-practice/02.hpa-resources-practice/paractice02# kubectl get deploy -n wyc
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
app02   1/1     1            1           29s


root@k8s-master01:~/tools/metrics-server/03.hpa-resources-practice/02.hpa-resources-practice/paractice02# kubectl apply -f 02.hpa_app02.yaml 
horizontalpodautoscaler.autoscaling/app02 created

root@k8s-master01:~/tools/metrics-server/03.hpa-resources-practice/02.hpa-resources-practice/paractice02# kubectl get hpa/app02 -n wyc
NAME    REFERENCE          TARGETS                        MINPODS   MAXPODS   REPLICAS   AGE
app02   Deployment/app02   <unknown>/90%, <unknown>/80%   2         4         0          6s    # 最小副本2,最大副本4,已知的副本数为0,不会大于4


root@k8s-master01:~/tools/metrics-server/03.hpa-resources-practice/02.hpa-resources-practice/paractice02# kubectl describe -f 02.hpa_app02.yaml 
Warning: autoscaling/v2beta2 HorizontalPodAutoscaler is deprecated in v1.23+, unavailable in v1.26+; use autoscaling/v2 HorizontalPodAutoscaler
Name:                                                     app02
Namespace:                                                wyc
Labels:                                                   <none>
Annotations:                                              <none>
CreationTimestamp:                                        Wed, 19 Jun 2024 03:11:32 +0800
Reference:                                                Deployment/app02
Metrics:                                                  ( current / target )
  resource memory on pods  (as a percentage of request):  <unknown> / 90%
  resource cpu on pods  (as a percentage of request):     <unknown> / 80%
Min replicas:                                             2
Max replicas:                                             4
Deployment pods:                                          1 current / 2 desired                       # 现在的,渴望的
Conditions:
  Type         Status  Reason            Message
  ----         ------  ------            -------
  AbleToScale  True    SucceededRescale  the HPA controller was able to update the target scale to 2
Events:
  Type    Reason             Age   From                       Message
  ----    ------             ----  ----                       -------
  Normal  SuccessfulRescale  7s    horizontal-pod-autoscaler  New size: 2; reason: Current number of replicas below Spec.MinReplicas



root@k8s-master01:~/tools/metrics-server/03.hpa-resources-practice/02.hpa-resources-practice/paractice02# kubectl describe -f 02.hpa_app02.yaml 
Warning: autoscaling/v2beta2 HorizontalPodAutoscaler is deprecated in v1.23+, unavailable in v1.26+; use autoscaling/v2 HorizontalPodAutoscaler
Name:                                                     app02
Namespace:                                                wyc
Labels:                                                   <none>
Annotations:                                              <none>
CreationTimestamp:                                        Wed, 19 Jun 2024 03:11:32 +0800
Reference:                                                Deployment/app02
Metrics:                                                  ( current / target )
  resource memory on pods  (as a percentage of request):  3% (3987456) / 90%
  resource cpu on pods  (as a percentage of request):     0% (0) / 80%
Min replicas:                                             2
Max replicas:                                             4
Deployment pods:                                          2 current / 2 desired             # 当前的/渴望的
Conditions:
  Type            Status  Reason            Message
  ----            ------  ------            -------
  AbleToScale     True    ReadyForNewScale  recommended size matches current size
  ScalingActive   True    ValidMetricFound  the HPA was able to successfully calculate a replica count from memory resource utilization (percentage of request)
  ScalingLimited  True    TooFewReplicas    the desired replica count is less than the minimum replica count
Events:
  Type     Reason                        Age   From                       Message
  ----     ------                        ----  ----                       -------
  Normal   SuccessfulRescale             96s   horizontal-pod-autoscaler  New size: 2; reason: Current number of replicas below Spec.MinReplicas
  Warning  FailedGetResourceMetric       81s   horizontal-pod-autoscaler  failed to get cpu utilization: did not receive metrics for any ready pods
  Warning  FailedComputeMetricsReplicas  81s   horizontal-pod-autoscaler  invalid metrics (1 invalid out of 2), first error is: failed to get cpu utilization: did not receive metrics for any ready pods





root@k8s-master01:~/tools/metrics-server/03.hpa-resources-practice/02.hpa-resources-practice/paractice02# kubectl get deploy/app02 -n wyc
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
app02   2/2     2            2           4m56s          # 已变成2,就绪了2



kubectl describe pods/app02 -n wyc   # 可看看deploy/app02对象的描述信息
```


## 3. 清理环境
```
kubectl delete -f ./
```
