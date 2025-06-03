# 1.下载Calico的manifests
```
wget https://raw.githubusercontent.com/projectcalico/calico/v3.26.5/manifests/calico.yaml
ls -l calico.yaml
```

# 2.Manifests的相关修改
configmap/calico-config对象
```
sed    's#__CNI_MTU__#1450#g' calico.yaml
sed -i 's#__CNI_MTU__#1450#g' calico.yaml
```

daemonsets/calico-node对象的Manifests做修改
```
## 修改 Pod CIDR，默认为192.168.0.0/16 
- name: CALICO_IPV4POOL_CIDR
  value: "10.244.0.0/16"

## 修改子网大小(新增,就在CALICO_IPV4POOL_CIDR下面新增)
- name: CALICO_IPV4POOL_BLOCK_SIZE
  value: "24"

## 指定网络模式(IPIP且可跨子网)
- name: CALICO_IPV4POOL_IPIP
  value: "Cross-Subnet"

## 配置BGP（指定各Node上IPV4的业务网卡.有多种配置方法）
- name: IP_AUTODETECTION_METHOD
  value: "kubernetes-internal-ip"  # 即使用各node的INTERNAL-IP
```

修改相关的image
```
sed  -i 's#docker.io/calico/cni:v3.26.5#swr.cn-north-1.myhuaweicloud.com/qepyd/calico-cni:v3.26.5#g'  calico.yaml
sed  -i 's#docker.io/calico/node:v3.26.5#swr.cn-north-1.myhuaweicloud.com/qepyd/calico-node:v3.26.5#g'  calico.yaml
sed  -i 's#docker.io/calico/kube-controllers:v3.26.5#swr.cn-north-1.myhuaweicloud.com/qepyd/calico-kube-controllers:v3.26.5#g'  calico.yaml
```
