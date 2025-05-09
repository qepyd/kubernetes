# 1 我的k8s版本（kubeadm工具部署的）
```
NAME                  STATUS   ROLES           AGE    VERSION
master01.magedu.com   Ready    control-plane   271d   v1.24.3
master02.magedu.com   Ready    control-plane   271d   v1.24.3
master03.magedu.com   Ready    control-plane   271d   v1.24.3
node01.magedu.com     Ready    <none>          271d   v1.24.3
node02.magedu.com     Ready    <none>          271d   v1.24.3
node03.magedu.com     Ready    <none>          271d   v1.24.3
```

# 2 metrics-server 项目地址
```
https://github.com/kubernetes-sigs/metrics-server/
```

# 3 metrics-server 的版本选择
```
0.7.X
```

# 4.kubectl使用的manifests
```
wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.0/components.yaml
```

# 5.manifests相关说明及修改
```
## 所用ns资源对象为kube-system(kubernetes安装好默认就存在)
root@master01:/qepyd/kubernetes/90.Addons/04.container-resource-monitoring/metrics-server/v0.7.0# grep "namespace:" components.yaml  | uniq
  namespace: kube-system
    namespace: kube-system

## 不包含ns/kube-system对象的manifests
不包含ns/kube-system对象的manifests，若有的话得将其注释掉（为了安全）。
root@master01:/qepyd/kubernetes/90.Addons/04.container-resource-monitoring/metrics-server/v0.7.0# grep "^kind: Namespace" components.yaml 
root@master01:/qepyd/kubernetes/90.Addons/04.container-resource-monitoring/metrics-server/v0.7.0# 

## 所用image
root@master01:/qepyd/kubernetes/90.Addons/04.container-resource-monitoring/metrics-server/v0.7.0# 
root@master01:/qepyd/kubernetes/90.Addons/04.container-resource-monitoring/metrics-server/v0.7.0# grep image: components.yaml 
        image: registry.k8s.io/metrics-server/metrics-server:v0.7.0
root@master01:/qepyd/kubernetes/90.Addons/04.container-resource-monitoring/metrics-server/v0.7.0# 
root@master01:/qepyd/kubernetes/90.Addons/04.container-resource-monitoring/metrics-server/v0.7.0# grep "registry.k8s.io" components.yaml 
        image: registry.k8s.io/metrics-server/metrics-server:v0.7.0
root@master01:/qepyd/kubernetes/90.Addons/04.container-resource-monitoring/metrics-server/v0.7.0# 

## pull-->tag-->push
我已将相关镜像push到我个人仓库并且公开(pull时不需要认证)
swr.cn-north-1.myhuaweicloud.com/qepyd/metrics-server:v0.7.0

## 修改image
sed    's#registry.k8s.io/metrics-server/metrics-server:v0.7.0#swr.cn-north-1.myhuaweicloud.com/qepyd/metrics-server:v0.7.0#g' components.yaml
sed -i 's#registry.k8s.io/metrics-server/metrics-server:v0.7.0#swr.cn-north-1.myhuaweicloud.com/qepyd/metrics-server:v0.7.0#g' components.yaml
grep "image:"   components.yaml


## 让Deployment/metrics-server对象容忍kubernetes上各master上的污点 
在其spec.template.spec字段中添加如下信息
      tolerations:
      - operator: Exists
        effect: NoSchedule

## 让Deployment/metrics-server对象中Pod模板仅有的一个容器添加启动参数
在其spec.template.spec.containers.args字段中添加
   --kubelet-insecure-tls
```

# 6.应用manifests
```
kubectl apply -f ./components.yaml --dry-run=client 
kubectl apply -f ./components.yaml 
kubectl get -f components.yaml    
```

# 7.验证
```
## 查看各nodes资源对象其资源(cpu、memory)使用情况
root@k8s-master01:~/tools# kubectl top nodes
NAME                      CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
master01.magedu.com   264m         13%    2041Mi          53%       
master02.magedu.com   227m         11%    2000Mi          52%       
master03.magedu.com   279m         13%    2003Mi          52%       
node01.magedu.com     135m         6%     1698Mi          44%       
node02.magedu.com     132m         6%     1497Mi          39%       
node03.magedu.com     147m         7%     1585Mi          41%      

## 查看某namespace中各pods其资源(cpu、memory)的使用情况，pod得定义资源限制
root@master01:/qepyd/kubernetes/90.Addons/04.container-resource-monitoring/metrics-server/v0.7.0# kubectl -n kube-system top pods
NAME                               CPU(cores)   MEMORY(bytes)   
coredns-74586cf9b6-4nj57           2m           12Mi            
coredns-74586cf9b6-8ljcg           2m           12Mi            
etcd-master01                      12m          73Mi            
kube-apiserver-master01            40m          365Mi           
kube-controller-manager-master01   11m          43Mi            
kube-proxy-pztd9                   1m           55Mi            
kube-scheduler-master01            3m           17Mi            
metrics-server-f74496889-ddfbh     2m           14Mi      

## kubernetes多了一个kind为PodMerics的pods资源(非crd)
root@master01:/qepyd/kubernetes/90.Addons/04.container-resource-monitoring/metrics-server/v0.7.0# kubectl api-resources | grep PodMetrics
pods                                           metrics.k8s.io/v1beta1                 true         PodMetrics
```
