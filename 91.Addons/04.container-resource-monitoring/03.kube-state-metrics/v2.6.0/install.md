# 1.我的k8s版本
```
root@master01:~# kubectl get nodes
NAME       STATUS   ROLES           AGE   VERSION
master01   Ready    control-plane   13d   v1.24.4
master02   Ready    control-plane   13d   v1.24.4
master03   Ready    control-plane   13d   v1.24.4
node01     Ready    <none>          13d   v1.24.4
node02     Ready    <none>          13d   v1.24.4
```

# 2.kube-state-metrics相关介绍
**代码托管**
```
https://github.com/kubernetes/kube-state-metrics
```

**版本的选择**
kube-state-metrics使用client-go与Kubernetes集群通信。支持的Kubernetes集群版本由client-go决定。
client-go和Kubernetes集群的兼容性矩阵可以从以下地址中查看到。
```
https://github.com/kubernetes/kube-state-metrics/tree/main?tab=readme-ov-file#versioning
   #
   # 最多只能看到5个版本对应的kubernetes版本
   # 可以切换tags后再查看
   # 
```
根据我的kubernetes版本,最终我选择kube-state-metrics版本为v2.6.0。
```
https://github.com/kubernetes/kube-state-metrics/tree/v2.6.0?tab=readme-ov-file#versioning
```

**基本介绍**
kube-state-metrics(简称KSM)，它关注的不是Kubernetes组件的健康状况，而是kubernetes中
各资源对象(例如:pods资源对象、deployments资源对象、services资源对象、等等)的健康状况。  
```
#### 默认的资源及可选的资源
# <== 默认的资源
https://github.com/kubernetes/kube-state-metrics/tree/main/docs#default-resources

# <== 可选的资源
https://github.com/kubernetes/kube-state-metrics/tree/main/docs#optional-resources

# <== 扩展说明
这些资源均是kubernetes版本的标准资源(k8s安装好以后就存在)。
可从安装时的相关角色定义中看到"默认的资源"、"可选的资源"均有被定义
   https://github.com/kubernetes/kube-state-metrics/blob/main/examples/standard/cluster-role.yaml
   只需要只读的权限即可。
kubernetes中的资源还会有"非标准资源",若想让kube-state-metrics收集其健康状况,可加上
  例如在安装时的 cluster-role.yaml 中进行定义。
```




# 3.kube-state-metrics的安装
**manifests所处位置**
```
https://github.com/kubernetes/kube-state-metrics/tree/main/examples/standard
```
