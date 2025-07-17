# 1 Pod中容器级别的资源限制(limits)和请求(requests)说明
**相关字段**
```
## 相关字段
pods.spec.containers.resources.limtis   <map[string]string>
pods.spec.containers.resources.requests <map[string]string>

## 注意事项1
requests中相关资源(例如：memory)量不能大于limits中相关资源(例如：memory)量。

## 注意事项2
可以人为显示定义limits，requests。
可以人为显示定义limits，不定义requests，其requests会依据limits中的资源量进行配置。
可以人为显示定义requests，不定义limits，其requests不会依据requests中的配置而进行自动配置。
```

**限制(limits)**
```
01:Pod中的容器若没有对相关资源(例如：memory)的限制，那么容器中的应用程序是
   可以无节制的使用worker node上的资源，可能操作系统会干预(kill掉相关进程)。
02:若进行了限制(limits),容器中的应用程序还是可以超出限制，只不过因为有了限制，
   一但超过限制，容器就可能被kill掉，还能让其进行重启。
```

**请求(requests)**
```
Pod中可以有多个容器，得要有worker node能够满足各容器其资源请求(requests)中各资源的总和，不然
影响Pod的调度。例如：
  容器1:
    resources:
      requests:
        cpu: 1
        memory: 1Gi
  容器2：
    resources:
      requests:
        cpu: 1
        memory: 1Gi
  
  可用资源不满足2核CPU、2G内存的worker node将被排除。
  若你的k8s集群没有任何一个worker node满足,Pod将处于Pending状态。
  换言之,要想Pod被调度,其Pod中所有容器的资源请求(requests)得满足。
```

**支持的资源**
```
cpu
  https://kubernetes.io/zh-cn/docs/concepts/configuration/manage-resources-containers/#meaning-of-cpu
  单位可以是整核数、浮点核数、豪核(m)
  整  核：1=1核=100%(最大100%使用率)
  浮点核：0.5=0.5核=50%(最大50%使用率)
  豪  核：1核=1000m  0.5核=500m  1.2核=1200m

memory
  https://kubernetes.io/zh-cn/docs/concepts/configuration/manage-resources-containers/#meaning-of-memory
  以字节为单位进行限制，你可以使用普通的整数，或者配合相关单位，其相关单位为：k或Ki, M或Mi, G或Gi, T或Ti, P或Pi, E或Ei
```


