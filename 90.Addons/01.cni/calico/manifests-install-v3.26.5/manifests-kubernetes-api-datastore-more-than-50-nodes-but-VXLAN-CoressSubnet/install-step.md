## 1.下载manifests
```
wget https://raw.githubusercontent.com/projectcalico/calico/v3.26.5/manifests/calico-typha.yaml
ls -l calico-typha.yaml
```

## 2.样式
```
Policy   IPAM    CNI      Cross-Subnet  Routing   Database
calico   calico  calico   vxlan         calico    kubernetes
```

## 3.修改manifests
configmap/calico-config对象会被DaemonSet/calico-node对象引用
```
# 设置calico后端
calico_backend: "vxlan"  # 可修改为vxlan
```

daemonset/calico-node对象
```
# Enable IPIP
- name: CALICO_IPV4POOL_IPIP
  value: "Never"
	  
# Enable or Disable VXLAN on the default IP pool.
- name: CALICO_IPV4POOL_VXLAN
  value: "CrossSubnet" 
# Enable or Disable VXLAN on the default IPv6 IP pool.
- name: CALICO_IPV6POOL_VXLAN
  value: "Never"

- name: CALICO_IPV4POOL_CIDR
  value: "10.244.0.0/16"
- name: CALICO_IPV4POOL_BLOCK_SIZE
  value: "24"
```

deployment/calico-typha
```
其副本数默认为1，关于副本数的设置官方的建议为：
01：官方建议每200个worker node至少设置一个副本，最多不超过20个副本。
02：在生产环境中，我们建议至少设置三个副本，以减少滚动升级和故障的影响。
03：副本数量应始终小于节点数量，否则滚动升级将会停滞。
04：此外，只有当Typha实例数量少于节点数量时，Typha 才能帮助实现扩展。
```

替换相关image
```
docker image pull  docker.io/calico/cni:v3.26.5
docker image tag   docker.io/calico/cni:v3.26.5    swr.cn-north-1.myhuaweicloud.com/qepyd/calico-cni:v3.26.5
docker image push                                  swr.cn-north-1.myhuaweicloud.com/qepyd/calico-cni:v3.26.5

docker image pull  docker.io/calico/node:v3.26.5   
docker image tag   docker.io/calico/node:v3.26.5   swr.cn-north-1.myhuaweicloud.com/qepyd/calico-node:v3.26.5
docker image push                                  swr.cn-north-1.myhuaweicloud.com/qepyd/calico-node:v3.26.5

docker image pull  docker.io/calico/kube-controllers:v3.26.5
docker image tag   docker.io/calico/kube-controllers:v3.26.5  swr.cn-north-1.myhuaweicloud.com/qepyd/calico-kube-controllers:v3.26.5
docker image push                                             swr.cn-north-1.myhuaweicloud.com/qepyd/calico-kube-controllers:v3.26.5

docker image pull  docker.io/calico/typha:v3.26.5
docker image tag   docker.io/calico/typha:v3.26.5             swr.cn-north-1.myhuaweicloud.com/qepyd/calico-typha:v3.26.5
docker image push                                             swr.cn-north-1.myhuaweicloud.com/qepyd/calico-typha:v3.26.5



sed  -i 's#docker.io/calico/cni:v3.26.5#swr.cn-north-1.myhuaweicloud.com/qepyd/calico-cni:v3.26.5#g'  calico-typha.yaml  
sed  -i 's#docker.io/calico/node:v3.26.5#swr.cn-north-1.myhuaweicloud.com/qepyd/calico-node:v3.26.5#g'  calico-typha.yaml  
sed  -i 's#docker.io/calico/kube-controllers:v3.26.5#swr.cn-north-1.myhuaweicloud.com/qepyd/calico-kube-controllers:v3.26.5#g'  calico-typha.yaml  
sed  -i "s#docker.io/calico/typha:v3.26.5#swr.cn-north-1.myhuaweicloud.com/qepyd/calico-typha:v3.26.5#g"   calico-typha.yaml  
```

# 4.应用manifests
```
kubectl apply -f calico-typha.yaml
```

# 5.验证
```
## 拥有相关的crd
kubectl get crd | grep calicio 

## 观察Pod
kubectl -n kube-system get pods -o wide -w

## 观察worker node状态
kubectl get nodes

## 查看有哪些subnet
kubectl get ipamblocks

## 查看给各worker node分配的subnet
kubectl get blockaffinities

## 各worker node上有一个vxlan.calico网卡
ifconfig 

## 运行Pod进行测试
看Pod能否分配到Pod网络中的IP
在Pod中的容器里面云ping互联网ipv4
```
