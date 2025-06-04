# 1.当前k8s环境
```
## 当前k8s才部署好,只安装了CNI插件,所以各WokerNode的状态已是Ready
root@deploy:~# kubectl get nodes
NAME       STATUS                     ROLES    AGE   VERSION
master01   Ready,SchedulingDisabled   master   22h   v1.24.4
master02   Ready,SchedulingDisabled   master   22h   v1.24.4
master03   Ready,SchedulingDisabled   master   22h   v1.24.4
node01     Ready                      node     22h   v1.24.4
node02     Ready                      node     22h   v1.24.4
node03     Ready                      node     22h   v1.24.4

## 引入与集群内Dns相关的一些规划(在安装k8s前是有规划)
集群内部DNS的Domain为: cluster.local
集群三条网络之Service网络为：10.144.0.0/16

## 各worker node上其kubelet组件实例涉及的相关参数
--cluster-dns <strings>
   #
   # 用于指定k8s集群内DNS的连接地址(不是Service网络中的IP)
   # 当前的值为：169.254.20.10   # 注意哈,这是个私有地址
   # 

--cluster-domain <strings>
   #
   # 用于指定k8s集群内Dns中的Domain
   # 当前值为：cluster.local
   # 
```

# 2.下载coredns和nodelocaldns的manifests
到kubernetes官方的代码托管处就能找到
```
## 在线可读的地址
https://github.com/kubernetes/kubernetes/blob/v1.24.4/cluster/addons/dns/coredns/coredns.yaml.base
https://github.com/kubernetes/kubernetes/blob/v1.24.4/cluster/addons/dns/nodelocaldns/nodelocaldns.yaml

## 下载coredns的manifests
wget https://raw.githubusercontent.com/kubernetes/kubernetes/refs/tags/v1.24.4/cluster/addons/dns/coredns/coredns.yaml.base -O  ./01.coredns.yaml
ls -l ./01.coredns.yaml

## 下载nodelocaldns的manifests
wget https://raw.githubusercontent.com/kubernetes/kubernetes/refs/tags/v1.24.4/cluster/addons/dns/nodelocaldns/nodelocaldns.yaml -O ./02.nodelocaldns.yaml
ls -l ./02.nodelocaldns.yaml
```

# 3.修改coredns的manifests
```
## 检查所用namespace
grep "namespace:"  ./01.coredns.yaml  | sort | uniq
  #
  # 结果是：namespace: kube-system
  #

## 检查是否安装ns/kube-system对象的manifests，肯定是没有的
grep "^kind: Namespace" ./01.coredns.yaml 
  #
  # 肯定是不有的,因为ns/kube-system是k8s默认就存在的
  #

## 检查所用到的image
grep "image:" ./01.coredns.yaml
  #
  # 结果是 image: k8s.gcr.io/coredns/coredns:v1.8.6
  # 应该把镜像放在自己的镜像仓库中
  # 我这里将其镜像放在了我的镜像仓库中并公开(下载时不需要认证)
  # swr.cn-north-1.myhuaweicloud.com/qepyd/coredns:v1.8.6
  # 

## 替换image
sed    's#k8s.gcr.io/coredns/coredns:v1.8.6#swr.cn-north-1.myhuaweicloud.com/qepyd/coredns:v1.8.6#g'   ./01.coredns.yaml | grep coredns:v1.8.6
sed -i 's#k8s.gcr.io/coredns/coredns:v1.8.6#swr.cn-north-1.myhuaweicloud.com/qepyd/coredns:v1.8.6#g'   ./01.coredns.yaml

## 修改configmaps/coredns对象
将 __DNS__DOMAIN__ 替换成 所规划的Domain之cluster.local

sed    's#__DNS__DOMAIN__#cluster.local#g'  ./01.coredns.yaml  | grep cluster.local
sed -i 's#__DNS__DOMAIN__#cluster.local#g'  ./01.coredns.yaml 

## 修改deployments/coredns对象
可设置其副本数,默认没指定(默认为1)。
   spec字段下一级添加replicas: <副本数>

修改其Memory的limit,即替换 __DNS__MEMORY__LIMIT__，生产环境可设置大一些 
sed    's#__DNS__MEMORY__LIMIT__#512Mi#g'  ./01.coredns.yaml  | grep 512Mi
sed -i 's#__DNS__MEMORY__LIMIT__#512Mi#g'  ./01.coredns.yaml

## 修改service/kube-dns对象
注意：此对象的name可不要去修改

固定其clusterIP的地址,其固定的IP得来自于service网络,我这里就固定成10.144.0.2
sed    's#__DNS__SERVER__#10.144.0.2#g'  ./01.coredns.yaml  | grep 10.144.0.2
sed -i 's#__DNS__SERVER__#10.144.0.2#g'  ./01.coredns.yaml
```

# 4.修改nodelocaldns的manifests
```
## 检查所用namespace
grep "namespace:"  ./02.nodelocaldns.yaml  | sort | uniq
  #
  # 结果是：namespace: kube-system
  #

## 检查是否安装ns/kube-system对象的manifests，肯定是没有的
grep "^kind: Namespace" ./02.nodelocaldns.yaml
  #
  # 肯定是不有的,因为ns/kube-system是k8s默认就存在的
  #

## 检查所用到的image
grep "image:" ./02.nodelocaldns.yaml
  #
  # 结果是 image: k8s.gcr.io/dns/k8s-dns-node-cache:1.21.1 
  # 应该把镜像放在自己的镜像仓库中
  # 我这里将其镜像放在了我的镜像仓库中并公开(下载时不需要认证)
  # swr.cn-north-1.myhuaweicloud.com/qepyd/k8s-dns-node-cache:1.21.1 
  #

## 替换image
sed    's#k8s.gcr.io/dns/k8s-dns-node-cache:1.21.1#swr.cn-north-1.myhuaweicloud.com/qepyd/k8s-dns-node-cache:1.21.1#g'  ./02.nodelocaldns.yaml | grep image:
sed -i 's#k8s.gcr.io/dns/k8s-dns-node-cache:1.21.1#swr.cn-north-1.myhuaweicloud.com/qepyd/k8s-dns-node-cache:1.21.1#g'  ./02.nodelocaldns.yaml

## 替换__PILLAR__DNS__SERVER__变量,即设置所要连接dns之coredns服务地址(前面设置的是10.144.0.2)
sed    's#__PILLAR__DNS__SERVER__#10.144.0.2#g'   ./02.nodelocaldns.yaml  | grep "10.144.0.2"
sed -i 's#__PILLAR__DNS__SERVER__#10.144.0.2#g'   ./02.nodelocaldns.yaml 

## 替换__PILLAR__DNS__DOMAIN__,即设置k8s集群内dns的domain之cluster.local
sed    's#__PILLAR__DNS__DOMAIN__#cluster.local#g'  ./02.nodelocaldns.yaml  | grep cluster.local
sed -i 's#__PILLAR__DNS__DOMAIN__#cluster.local#g'  ./02.nodelocaldns.yaml

## 替换__PILLAR__LOCAL__DNS__变更,即自身所监听的地址,默认为169.254.20.10(所以我的k8s各worker node上其kubelet组件实例的--cluster-dns参数指定就是它)
sed    's#__PILLAR__LOCAL__DNS__#169.254.20.10#g'   ./02.nodelocaldns.yaml  | grep 169.254.20.10
sed -i 's#__PILLAR__LOCAL__DNS__#169.254.20.10#g'   ./02.nodelocaldns.yaml
```

# 5.应用coredns的manifests并检查
应用manifests
```
kubectl apply -f ./01.coredns.yaml --dry-run=client
kubectl apply -f ./01.coredns.yaml
```

列出相关资源对象
```
kubectl -n kube-system get deploy/coredns 
   # 
   # 观察其READY是否所有副本就绪
   #

NewReplica=$(kubectl -n kube-system describe deploy/coredns |grep "NewReplicaSet:" | cut -d " " -f 4)
   #
   # 定义变量，即当前所用的replicas资源对象的name
   # 

OnePod=$(kubectl -n kube-system get pods | grep $NewReplica  | tail -1 | cut -d " " -f1)
   #
   # 定义变量,某个Pod副本的name
   # 

kubectl -n kube-system logs -f pods/$OnePod
   #
   # 查看日志，看是否有报错
   # 

kubectl -n kube-system get svc/kube-dns
   #
   # 列出其svc资源对象,检查其clusterIP是否是前面指定的10.144.0.2
   #
```

# 6.应用nodelocaldns的manifests并检查
应用manifests
```
kubectl apply -f ./02.nodelocaldns.yaml --dry-run=client
kubectl apply -f ./02.nodelocaldns.yaml
```
列出相关资源对象
```
kubectl get -f ./02.nodelocaldns.yaml
  #
  # 观察daemonsets资源对象其READY是否所有副本就绪
  #
```

# 7.测试
应用上一级目录中的ds_pod-in-container-visit-fqdn.yaml这个manifests
```
ls -l ../ds_pod-in-container-visit-fqdn.yaml

kubectl apply -f  ../ds_pod-in-container-visit-fqdn.yaml --dry-run=client
kubectl apply -f  ../ds_pod-in-container-visit-fqdn.yaml 

kubectl get   -f  ../ds_pod-in-container-visit-fqdn.yaml 
   #
   # 观察其READY是否所有副本就绪
   # 

kubectl delete -f  ../ds_pod-in-container-visit-fqdn.yaml
```
