## 1.下载manifests
```
wget https://raw.githubusercontent.com/projectcalico/calico/refs/tags/v3.26.5/manifests/calico-vxlan.yaml  
```

## 2.修改manifests
```
# <== configmap/calico-config

	sed    's#__CNI_MTU__#1450#g' calico-vxlan.yaml  
	sed -i 's#__CNI_MTU__#1450#g' calico-vxlan.yaml  

# <== daemonset/calico-node

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

# <== 修改image 

	docker image pull docker.io/calico/cni:v3.26.5
	docker image tag  docker.io/calico/cni:v3.26.5 swr.cn-north-1.myhuaweicloud.com/qepyd/calico-cni:v3.26.5
	docker image push  swr.cn-north-1.myhuaweicloud.com/qepyd/calico-cni:v3.26.5

	docker image pull docker.io/calico/node:v3.26.5   
	docker image tag  docker.io/calico/node:v3.26.5   swr.cn-north-1.myhuaweicloud.com/qepyd/calico-node:v3.26.5
	docker image push  swr.cn-north-1.myhuaweicloud.com/qepyd/calico-node:v3.26.5

	docker image pull docker.io/calico/kube-controllers:v3.26.5
	docker image tag docker.io/calico/kube-controllers:v3.26.5  swr.cn-north-1.myhuaweicloud.com/qepyd/calico-kube-controllers:v3.26.5
	docker image push  swr.cn-north-1.myhuaweicloud.com/qepyd/calico-kube-controllers:v3.26.5

	sed  -i 's#docker.io/calico/cni:v3.26.5#swr.cn-north-1.myhuaweicloud.com/qepyd/calico-cni:v3.26.5#g'  calico-vxlan.yaml  
	sed -i 's#docker.io/calico/node:v3.26.5#swr.cn-north-1.myhuaweicloud.com/qepyd/calico-node:v3.26.5#g'  calico-vxlan.yaml  
	sed -i 's#docker.io/calico/kube-controllers:v3.26.5#swr.cn-north-1.myhuaweicloud.com/qepyd/calico-kube-controllers:v3.26.5#g'  calico-vxlan.yaml  
```


# 3.应用manifests
```
kubectl apply -f calico-vxlan.yaml

```

# 4.验证
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










