## 1. 实践的目标
```
当工作负载其性能不饱合时,且hpa又没有设置spec.behavior字段中的相关字段时,
会让其工作负载的副本数与minRepolicas的值保持一致。
  01：当deploy/app01 最开始定义的副本数是 2
  02：而hpa/app01 中最小副本数是 1
  03: 最终deploy/app01的副本数为1
```

## 2. 验证
```
root@k8s-master01:~/tools/metrics-server/03.hpa-resources-practice/02.hpa-resources-practice/paractice01# kubectl apply -f 01.deploy_app01.yaml 
deployment.apps/app01 created

root@k8s-master01:~/tools/metrics-server/03.hpa-resources-practice/02.hpa-resources-practice/paractice01# kubectl get deploy/app01 -n wyc
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
app01   2/2     2            2           29s

root@k8s-master01:~/tools/metrics-server/03.hpa-resources-practice/02.hpa-resources-practice/paractice01# kubectl apply -f 02.hpa_app01.yaml 
horizontalpodautoscaler.autoscaling/app01 created

root@k8s-master01:~/tools/metrics-server/03.hpa-resources-practice/02.hpa-resources-practice/paractice01# kubectl get -f 02.hpa_app01.yaml 
NAME    REFERENCE          TARGETS                        MINPODS   MAXPODS   REPLICAS   AGE
app01   Deployment/app01   <unknown>/90%, <unknown>/80%   1         4         0          2s    # 在工作负载性能不饱合时，这里的REPLICAS会变成1, 要等300秒后


root@k8s-master01:~/tools/metrics-server/03.hpa-resources-practice/02.hpa-resources-practice/paractice01# kubectl get -f 02.hpa_app01.yaml 
NAME    REFERENCE          TARGETS          MINPODS   MAXPODS   REPLICAS   AGE
app01   Deployment/app01   3%/90%, 0%/80%   1         4         2          2m17s               # 期间,hpa知道当前工作负载有2个副本


root@k8s-master01:~/tools/metrics-server/03.hpa-resources-practice/02.hpa-resources-practice/paractice01# kubectl get -f 02.hpa_app01.yaml 
NAME    REFERENCE          TARGETS          MINPODS   MAXPODS   REPLICAS   AGE
app01   Deployment/app01   3%/90%, 0%/80%   1         4         1          5m39s               # 在工作负载性能不饱合时,其minpods与replicas的值会保持一致


root@k8s-master01:~/tools/metrics-server/03.hpa-resources-practice/02.hpa-resources-practice/paractice01# kubectl get deploy/app01 -n wyc
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
app01   1/1     1            1           7m23s                                                 # deploy/app01对象其Pod副本数为1了


kubectl describe deploy/app01 -n wyc   # 可看看deploy/app01的描述信息 
```

## 3. 清理环境
```
kubectl delete -f ./
```

