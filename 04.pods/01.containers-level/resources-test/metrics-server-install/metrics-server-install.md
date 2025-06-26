## 1 kubectl使用的manifests
```
wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.4/components.yaml
```

## 2 关于manifests的修改
```
## 关于其namespace
  默认是kube-system,kube-system是k8s自带的namespace,我这就不修改了。

## 关于deployment/metrics-server对象manifests的修改
  修改image：
     现有image为
       root@master01:~/tools/pods/containers-level/resources/metrics-server-install# grep image: components.yaml 
          image: registry.k8s.io/metrics-server/metrics-server:v0.6.4
     修改image为(我提供的image在国内,公开)
       sed -i 's#registry.k8s.io/metrics-server/metrics-server:v0.6.4#swr.cn-north-1.myhuaweicloud.com/k8s-base/metrics-server:v0.6.4#g' components.yaml

  修改deploy/metrics-server对象的启动参数:
     对其主容器之metrics-server的args参数加上--kubelet-insecure-tls 参数
```

## 3 应用manifests
```
kubectl apply -f ./components.yaml --dry-run=client 
kubectl apply -f ./components.yaml   # 默认会部署到kube-system名称空间
kubectl get -f components.yaml       # 其deploy对象要完全准备好
```


## 4 验证
```
root@master01:~/tools/pods/containers-level/resources/metrics-server-install# kubectl top nodes
NAME       CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
master01   180m         9%     1720Mi          45%       
master02   194m         9%     1981Mi          52%       
master03   185m         9%     2013Mi          52%       
node01     63m          3%     1711Mi          45%       
node02     76m          3%     1672Mi          43%       
node03     82m          4%     1770Mi          46%   
```
