# 1 Pod中容器的资源限制(limits)和请求(requests)
## 1.1 相关字段
```
## 容器级别之初始容器(先于主容器启动，串行启动且完成工作后退出)
pods.spec.initContainers.resources.limits   <map[string]string>   
pods.spec.initContainers.resources.requests <map[string]string>

## 容器级别之主容器
pods.spec.containers.resources.limits   <map[string]string>
pods.spec.containers.resources.requests <map[string]string>
```

## 1.2 相关资源
```
cpu
  https://kubernetes.io/zh-cn/docs/concepts/configuration/manage-resources-containers/#meaning-of-cpu
  单  位: 整核数、浮点核数、豪核(m)
  整  核: 1                        # 1000m 
  浮点核：1.0   或 1.5   或 0.5    # 1000m 或 1500m 或 500m
  豪  核: 1000m 或 1500m 或 500m  
  补  充：1=1.0=1000m(100%利用率)、1.5=1500m(150%利用率)、0.5=500m(50%利用率)

memory
  https://kubernetes.io/zh-cn/docs/concepts/configuration/manage-resources-containers/#meaning-of-memory
  以字节为单位进行限制，你可以使用普通的整数，或者配合相关单位，其相关单位为：k或Ki, M或Mi, G或Gi, T或Ti, P或Pi, E或Ei

ephemeral-storage

hugepages-<size>
```

## 1.3 基本要点
以下的说明不涉及相关外力（例如：LimitRange资源对象），在实践时也不会存在外力（例如：LimitRange资源对象）。
```
01.requests中相关计算资源（例如：memory）量不能大于limits中相关计算资源（例如：memory）量。
   若不成立：Pod将不会被kube-apiserver所接受(准入控制处不通过)，没有后续的创建、调度。
   我在编写manifests时习惯将limits写在requests前面。

02.当只存在limits时，requests会根据limits中的定义来生成。

03.当只存在requests时，limits不会根据requests中的定义来生成。

04.当为Pod中的各主容器在定义limits和requests时，建议limits和requests保持一致。
   例如：主容器1的limits和requests保持一致。
   例如：主容器2的limits和requests保持一致。
   注意：应该为Pod中的各主容器均定义limits和requests，详见"limits的意义"。

05.相关实践的manifests为
   ./01.pods_basic-requests-greater-limits-error.yaml
   ./02.pods_basic-requests-not-greater-limtis-ok.yaml
   ./03.pods_basic-requestsnotexist-generate-based-on-limits.yaml
   ./04.pods_basic-limitsnotexist-not-generate-based-on-requests.yaml
```

## 1.4 requests会影响Pod调度
Pod中可以有多个容器(实始容器、主容器)，那么Pod会有一个总请求(requests)量（各容器的requests之和）。当这个Pod被成功调度到
某worker node后，kubernetes的kubelet会将这个Pod的总请求（requests）计算到某worker node已分配请求(requests)中。  
kubectl describe nodes/<NodeName> 可看到。
```
01.kubernetes的kube-scheduler组件在调度Pod时会把不满足Pod总请求（requests）的worker node给排除掉，再择优选择。
   若你的kubernetes中所有worker node都被排除掉了，那么Pod将无法调度，处于Pending状态。

02.相关实践的manifests为
   ./05.pods_requests-effect-pod-dispatch-but-memory.yaml
   ./06.pods_requests-effect-pod-dispatch-but-cpu.yaml
```

## 1.5 limits的意义
当Pod中的容器未设置limits时，里面的应用程序可以使用所在worker node上所有可用相关资源量。
```
01.当你为Container指定了资源限制（limit）时，kubelet就可以确保运行的容器不会使用超出所设限制的资源。
   即：一量超过limits，会对容器（就是进程）采取相关的操作
   memory超过limits，会触发内核的OOM，会直接终止容器的进程，默认会重启容器(pods.spec.restartPolicy默认为Always)
   cpu超过limits，Kubernetes通过Linux内核的CFS（Completely Fair Scheduler）机制限制容器CPU使用率，使其运行速度降低至限制值以下。例如，若限制为1核CPU，实际使用可能被压缩至0.5核或更低。

02.相平面实践的manifests为
   ./07.pods_app-exceed-requests-but-not-execeed-limits-memory.yaml
   ./08.pods_app-exceed-limits-memory.yaml
   ./09.pods_app-exceed-requests-but-not-execeed-limits-cpu.yaml
   ./10.pods_app-exceed-limits-cpu.yaml
```

## 1.6 Pod的Qos 
优   先   级：Guaranteed > Bustable > BestEffort  
查看Pod的Qos： kubectl -n <Namespace> get Pod/<PodName> -o json | jq ".status.qosClass"  
```
Guaranteed
  https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/quality-service-pod/#create-a-pod-that-gets-assigned-a-qos-class-of-guaranteed
  Pod中所有主容器均得配置cpu、memory的limits和requests，
  且requests中资源量得等于limits中的资源量

Burstable
  https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/quality-service-pod/#create-a-pod-that-gets-assigned-a-qos-class-of-burstable
  Pod中至少一个主容器有进行cpu或memory的limits或requests
  不要求requests中资源量得等于limits中的资源量

BestEffort
  https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/quality-service-pod/#create-a-pod-that-gets-assigned-a-qos-class-of-besteffort
  Pod中所有主容器均没有配置cpu、memory的limits、requests。

相关实践的manifests为
  ./11.pods_pod-qos-to-guaranteed.yaml
  ./12.pods_pod-qos-to-burstable.yaml
  ./13.pods_pod-qos-to-besteffort.yaml
```

# 2 趁热打铁到LimitRange资源
https://github.com/qepyd/kubernetes/tree/main/05.LimitRange

