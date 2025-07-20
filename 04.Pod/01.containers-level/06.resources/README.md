# 1 Pod中容器级别对计算资源的限制(limits)和请求(requests)
**相关字段**
```
pods.spec.containers.resources.limtis   <map[string]string>
pods.spec.containers.resources.requests <map[string]string>
```

**基本说明**  
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
   01.pods_basic-requests-greater-limits-error.yaml
   02.pods_basic-requests-not-greater-limtis-ok.yaml
   03.pods_basic-requestsnotexist-generate-based-on-limits.yaml
   04.pods_basic-limitsnotexist-not-generate-based-on-requests.yaml
```

**requests会影响Pod的调度**  
Pod中可以有多个主容器，那么Pod会有一个总量请求(requests)。当这个Pod被成功调度到某worker node后，kubernetes的
kubelet会将这个Pod的总请求（requests）计算到某worker node已分配请求(requests)中。kubectl describe nodes/<NodeName> 可看到。
```
kubernetes的kube-scheduler组件在调度Pod时会把不满足Pod总请求（requests）的worker node给排除掉，再择优选择。
  若你的kubernetes中所有worker node都被排除掉了，那么Pod将无法调度，处于Pending状态。
```

**limits的意义**
当Pod中的容器未做limits时，理论上它是可以使用所在worker node上所有的相关资源量。
```
当你为Container指定了资源限制（limit）时，kubelet就可以确保运行的容器不会使用超出所设限制的资源。
  即：会根据相关的资源采取相关的操作，而不是让应用不能超过（限制）
```

**相关的资源**
```
cpu
  https://kubernetes.io/zh-cn/docs/concepts/configuration/manage-resources-containers/#meaning-of-cpu
  单位可以是: 整核数、浮点核数、豪核(m)
  整  核: 1               # 1000m
  浮点核：0.5 或 1.5      # 500m 或 1500m
  豪  核: 500m 或 1500m   # 0.5  或 1.5
  补  充：1=100%利用率

memory
  https://kubernetes.io/zh-cn/docs/concepts/configuration/manage-resources-containers/#meaning-of-memory
  以字节为单位进行限制，你可以使用普通的整数，或者配合相关单位，其相关单位为：k或Ki, M或Mi, G或Gi, T或Ti, P或Pi, E或Ei

ephemeral-storage

hugepages-<size>

```


