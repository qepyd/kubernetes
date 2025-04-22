## 1 kubectl使用的manifests
```
wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.4/components.yaml
```

## 2 关于manifests的修改
```
## 关于其namespace
默认是kube-system,kube-system是k8s自带的namespace,我这就不修改了。

## 关于deployment/metrics-server对象manifests的修改
我将deployment/metrics-server所用image推送到了我个人的私有仓库(国内),镜像已公开。
deploy/metrics-server对象中其主容器之metrics-server的args参数加上--kubelet-insecure-tls 参数
原本使用的是emptydir之使用disk,它是用来存放证书的,我这没有修改。
```

## 3 应用manifests
```
kubectl apply -f ./components.yaml --dry-run=client 
kubectl apply -f ./components.yaml   # 默认会部署到kube-system名称空间
kubectl get -f components.yaml       # 其deploy对象要完全准备好
```


## 4 验证
```
root@k8s-master01:~/tools# kubectl top nodes
NAME                      CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
k8s-master01.magedu.com   264m         13%    2041Mi          53%       
k8s-master02.magedu.com   227m         11%    2000Mi          52%       
k8s-master03.magedu.com   279m         13%    2003Mi          52%       
k8s-node01.magedu.com     135m         6%     1698Mi          44%       
k8s-node02.magedu.com     132m         6%     1497Mi          39%       
k8s-node03.magedu.com     147m         7%     1585Mi          41%      
```
