# 1.我的k8s版本（kubeadm工具部署）
```
root@master01:~# kubectl get nodes
NAME       STATUS   ROLES           AGE   VERSION
master01   Ready    control-plane   12d   v1.24.4
master02   Ready    control-plane   12d   v1.24.4
master03   Ready    control-plane   12d   v1.24.4
node01     Ready    <none>          12d   v1.24.4
node02     Ready    <none>          12d   v1.24.4
```

# 2.metrics-server 项目地址
**代码托管仓库**
```
https://github.com/kubernetes-sigs/metrics-server/
```

**版本选择**  
https://github.com/kubernetes-sigs/metrics-server/tree/v0.7.0?tab=readme-ov-file#compatibility-matrix
```
0.7.X
```

# 3.kubectl使用的manifests
```
wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.0/components.yaml
```

# 4.manifests相关说明及修改
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
   # 本身就有
   --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
   # 本身没有，加上。
   --kubelet-insecure-tls
```

# 5.应用manifests
```
kubectl apply -f ./components.yaml --dry-run=client 
kubectl apply -f ./components.yaml 
kubectl get -f components.yaml    
```

# 6.验证
```
## 相关资源(不是CRD)
root@master01:~# kubectl api-resources --api-group="metrics.k8s.io"
NAME    SHORTNAMES   APIVERSION               NAMESPACED   KIND
nodes                metrics.k8s.io/v1beta1   false        NodeMetrics
pods                 metrics.k8s.io/v1beta1   true         PodMetrics

## metrics.k8s.io是由APIService/v1beta1.metrics.k8s.io资源对象定义的
root@master01:~# kubectl get APIService | grep metrics.k8s.io
v1beta1.metrics.k8s.io                 kube-system/metrics-server   True        3m45s

## 查看各nodes资源对象其资源(cpu、memory)使用情况
root@master01:~# kubectl top node
NAME       CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
master01   136m         6%     1528Mi          40%       
master02   151m         7%     953Mi           25%       
master03   126m         6%     969Mi           25%       
node01     40m          2%     628Mi           16%       
node02     42m          2%     671Mi           17%  

## 查看所有namespace中各pods其资源(cpu、memory)的使用情况，pod得定义资源限制
root@master01:~# kubectl top pods -A
NAMESPACE      NAME                               CPU(cores)   MEMORY(bytes)   
kube-flannel   kube-flannel-ds-8sqrx              8m           14Mi            
kube-flannel   kube-flannel-ds-jhzjb              9m           13Mi            
kube-flannel   kube-flannel-ds-k2wgp              8m           13Mi            
kube-flannel   kube-flannel-ds-kk857              9m           13Mi            
kube-flannel   kube-flannel-ds-rt8fg              8m           13Mi            
kube-system    coredns-868b88dccc-p2lxd           2m           13Mi            
kube-system    etcd-master01                      41m          77Mi            
kube-system    etcd-master02                      33m          72Mi            
kube-system    etcd-master03                      31m          73Mi            
kube-system    kube-apiserver-master01            41m          306Mi           
kube-system    kube-apiserver-master02            35m          259Mi           
kube-system    kube-apiserver-master03            40m          246Mi           
kube-system    kube-controller-manager-master01   2m           19Mi            
kube-system    kube-controller-manager-master02   12m          49Mi            
kube-system    kube-controller-manager-master03   2m           19Mi            
kube-system    kube-proxy-dfch7                   1m           20Mi            
kube-system    kube-proxy-h7xsl                   9m           20Mi            
kube-system    kube-proxy-hkmb9                   6m           20Mi            
kube-system    kube-proxy-kx2g4                   7m           20Mi            
kube-system    kube-proxy-pqtd7                   7m           20Mi            
kube-system    kube-scheduler-master01            3m           18Mi            
kube-system    kube-scheduler-master02            3m           16Mi            
kube-system    kube-scheduler-master03            2m           16Mi            
kube-system    metrics-server-f74496889-n2xmm     4m           19Mi 
```
