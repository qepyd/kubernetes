# 1.下载Calico的manifests
```
wget https://raw.githubusercontent.com/projectcalico/calico/v3.26.5/manifests/calico-typha.yaml
ls -l calico-typha.yaml
```

# 2.Manifests的相关修改
configmap/calico-config对象
```
sed    's#__CNI_MTU__#1450#g' calico-typha.yaml
sed -i 's#__CNI_MTU__#1450#g' calico-typha.yaml
```

daemonsets/calico-node对象的Manifests做修改
```
## 配置BGP（指定各Node上IPV4的业务网卡.有多种配置方法）
- name: IP_AUTODETECTION_METHOD
  value: "kubernetes-internal-ip"  # 即使用各node的INTERNAL-IP

# Enable IPIP
- name: CALICO_IPV4POOL_IPIP
  value: "Always"
	  
# Enable or Disable VXLAN on the default IP pool.
- name: CALICO_IPV4POOL_VXLAN
  value: "Never" 
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

修改相关的image
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
