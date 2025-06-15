# 1.安装的相关步骤
## 1.1 下载manifests
```
## 在线可读
https://github.com/flannel-io/flannel/blob/v0.22.3/Documentation/kube-flannel.yml

## 下载
wget https://raw.githubusercontent.com/flannel-io/flannel/refs/tags/v0.22.3/Documentation/kube-flannel.yml
ls -l kube-flannel.yml
```

## 1.2 修改manifests
**是否有所用ns/kube-flannel对象的manifests**
```
grep "^kind: Namespace" kube-flannel.yml
  #
  # 是有的
  # 这里就不剥离了
  #
```

**替换镜像**
```
## 所用的image
root@deploy:~# grep "image:" kube-flannel.yml
        image: docker.io/flannel/flannel-cni-plugin:v1.2.0
        image: docker.io/flannel/flannel:v0.22.3
        image: docker.io/flannel/flannel:v0.22.3
root@deploy:~#
root@deploy:~# grep "docker.io" kube-flannel.yml
        image: docker.io/flannel/flannel-cni-plugin:v1.2.0
        image: docker.io/flannel/flannel:v0.22.3
        image: docker.io/flannel/flannel:v0.22.3


## 把镜像放在自己的镜像仓库中
我已将相关镜像放在我个人的镜像仓库中并公开（pull时不用认证）。
swr.cn-north-1.myhuaweicloud.com/qepyd/flannel-cni-plugin:v1.2.0
swr.cn-north-1.myhuaweicloud.com/qepyd/flannel:v0.22.3
swr.cn-north-1.myhuaweicloud.com/qepyd/flannel:v0.22.3

## 替换镜像的相关命令
sed    's#docker.io/flannel/flannel-cni-plugin:v1.2.0#swr.cn-north-1.myhuaweicloud.com/qepyd/flannel-cni-plugin:v1.2.0#g'   kube-flannel.yml  | grep "image:"
sed -i 's#docker.io/flannel/flannel-cni-plugin:v1.2.0#swr.cn-north-1.myhuaweicloud.com/qepyd/flannel-cni-plugin:v1.2.0#g'   kube-flannel.yml

sed    's#docker.io/flannel/flannel:v0.22.3#swr.cn-north-1.myhuaweicloud.com/qepyd/flannel:v0.22.3#g'   kube-flannel.yml  | grep "image:"
sed -i 's#docker.io/flannel/flannel:v0.22.3#swr.cn-north-1.myhuaweicloud.com/qepyd/flannel:v0.22.3#g'   kube-flannel.yml
```

**configmaps/kube-flannel-cfg**
```
## data字段中的 net-conf.json 键相关值的更改
将 "Network": "10.244.0.0/16"  修改成  "Network": "<你k8s所规划的Pod网络>"
将 "Type": "vxlan"             修改成  "Type": "host-gw"
```

## 1.3 应用manifests
```
## 应用manifests
kubectl apply -f kube-flannel.yml  --dry-run=client
kubectl apply -f kube-flannel.yml

## 列出相关资源对象
kubectl get -f kube-flannel.yml

## 检查k8s现有worker node是否处于Ready状态
kubectl get nodes -o wide
```

## 1.4 测试Pod访问互联网IPv4
当然k8s的worker node得要能够访问互联网。  
```
https://github.com/qepyd/kubernetes/blob/main/90.Addons/01.cni/ds_client.yaml
```

## 1.5 测试Pod访问互联网FQDN
**安装coredns**
```
参考 https://github.com/qepyd/kubernetes/tree/main/90.Addons/02.dns
```

**测试Pod访问互联网FQDN**
```
https://github.com/qepyd/kubernetes/blob/main/90.Addons/02.dns/ds_pod-in-container-visit-fqdn.yaml
```

## 1.6 Pod间的通信测试(必要的)
**创建ServerPod**
```
https://github.com/qepyd/kubernetes/blob/main/90.Addons/01.cni/ds_server.yaml
```
**宿主机上Pod的通信**
```
........是能够通信的。
```

**跨宿主机(Node网络下相同subnet)上Pod的通信**
```
........是能够通信的。
```

**跨宿主机(Node网络下相同subnet)上Pod的通信**
```
........无法通信的。
```
<br>
<br>


# 2.Flannel之host-gw后端的相关说明
## 2.1 网络平面图
<image src="./picture/flannel-host-gw-plan.jpg" style="width: 100%; height: auto;">


## 2.2 k8s上各Worker Node上的路由
**node01上的路由**
```
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.0.0.0        0.0.0.0         255.255.255.0   U     0      0        0 cni0
10.0.1.0        172.31.0.2      255.255.255.0   UG    0      0        0 eth0
10.0.2.0        172.31.0.3      255.255.255.0   UG    0      0        0 eth0
............    ..............  255.255.255.0   UG    0      0        0 eth0
............    ..............  255.255.255.0   UG    0      0        0 eth0
10.255.254.0    172.31.255.254  255.255.255.0   UG    0      0        0 eth0

0.0.0.0         172.31.255.255  0.0.0.0         UG    0      0        0 eth0
172.31.0.0      0.0.0.0         255.255.0.0     U     0      0        0 eth0
```

**node02上的路由**
```
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.0.2.0        0.0.0.0         255.255.255.0   UG    0      0        0 cni0
10.0.1.0        172.31.0.1      255.255.255.0   UG    0      0        0 eth0
10.0.3.0        172.31.0.3      255.255.255.0   UG    0      0        0 eth0
............    ..............  255.255.255.0   UG    0      0        0 eth0
............    ..............  255.255.255.0   UG    0      0        0 eth0
10.255.254.0    172.31.255.254  255.255.255.0   UG    0      0        0 eth0

0.0.0.0         172.31.255.255  0.0.0.0         UG    0      0        0 eth0
172.31.0.0      0.0.0.0         255.255.0.0     U     0      0        0 eth0
```

## 2.3 同宿主机上Pod间的通信
注意：直接通过cni0网关就进行转发了
<image src="./picture/SameHost-Pod-to-Pod-Communication.jpg" style="width: 100%; height: auto;">

## 2.4 跨宿主机(处于同一网关,L2网络)间Pod的通信
注意：通过主机间的路由。另外，Flannel host-gw后端，各worker node上不存在隧道设备flannel.1。  
**ClientPod**
<image src="./picture/CoressHost-Pod-to-Pod-Communication.jpg-1.jpg" style="width: 100%; height: auto;">

**ServerPod**
<image src="./picture/CoressHost-Pod-to-Pod-Communication.jpg-2.jpg" style="width: 100%; height: auto;">

## 2.5 跨宿主机(处于不同网关,L3网络)间Pod的通信
注意：不能通信
<br>
<br>


