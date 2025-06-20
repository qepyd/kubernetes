# 1.Flannel之vxlan(DirectRouting为false)的相关说明
## 1.1 网络平面图
<image src="./picture/flannel-vxlan-DirectRoute-false-plan.jpg" style="width: 100%; height: auto;">

## 1.2 各宿主机上的路由
**Node网络下Subnet(172.31.0.0/24)下的节点(k8s node01)**
```
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.0.0.0        0.0.0.0         255.255.255.0   U     0      0        0 cni0

10.0.1.0        10.0.1.0        255.255.255.0   UG    0      0        0 flannel.1
10.0.2.0        10.0.2.0        255.255.255.0   UG    0      0        0 flannel.1
10.0.3.0        10.0.3.0        255.255.255.0   UG    0      0        0 flannel.1
..........      ..........      255.255.255.0   UG    0      0        0 flannel.1
..........      ..........      255.255.255.0   UG    0      0        0 flannel.1
10.0.251.0      10.0.251.0      255.255.255.0   UG    0      0        0 flannel.1   # node01宿主机所在Node网络下其Sbunet中其它宿主机从Pod网分得subnet的路由

0.0.0.0         172.31.0.253    0.0.0.0         UG    0      0        0 eth0        # node01到所处Node网络下Subnet其网关的路由
172.31.0.0      0.0.0.0         255.255.255.0   U     0      0        0 eth0        # node01到所处Node网络下Subnet其网关的路由

10.0.252.0      10.0.252.0      255.255.255.0   UG    0      0        0 flannel.1
10.0.253.0      10.0.253.0      255.255.255.0   UG    0      0        0 flannel.1
10.0.254.0      10.0.254.0      255.255.255.0   UG    0      0        0 flannel.1
10.0.255.0      10.0.255.0      255.255.255.0   UG    0      0        0 flannel.1
10.1.0.0        10.1.0.0        255.255.255.0   UG    0      0        0 flannel.1
10.1.1.0        10.1.1.0        255.255.255.0   UG    0      0        0 flannel.1
............    ............    255.255.255.0   UG    0      0        0 flannel.1
............    ............    255.255.255.0   UG    0      0        0 flannel.1
10.1.247.0      10.1.247.0      255.255.255.0   UG    0      0        0 flannel.1   # node01宿主机所在Node网绺下其Subnet之外Subnet中相关宿主机从Pod网络分得subnet的路由
```

**Node网络下Subnet(172.31.0.0/24)下的节点(k8s node02)**
```
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.0.1.0        0.0.0.0         255.255.255.0   U     0      0        0 cni0

10.0.0.0        10.0.0.0        255.255.255.0   UG    0      0        0 flannel.1
10.0.2.0        10.0.2.0        255.255.255.0   UG    0      0        0 flannel.1
10.0.3.0        10.0.3.0        255.255.255.0   UG    0      0        0 flannel.1
..........      ..........      255.255.255.0   UG    0      0        0 flannel.1
..........      ..........      255.255.255.0   UG    0      0        0 flannel.1
10.0.251.0      10.0.251.0      255.255.255.0   UG    0      0        0 flannel.1   # node02宿主机所在Node网络下其Sbunet中其它宿主机从Pod网分得subnet的路由     

0.0.0.0         172.31.0.253    0.0.0.0         UG    0      0        0 eth0        # node02到所处Node网络下Subnet其网关的路由
172.31.0.0      0.0.0.0         255.255.255.0   U     0      0        0 eth0        # node02到所处Node网络下Subnet其网关的路由

10.0.252.0      10.0.252.0      255.255.255.0   UG    0      0        0 flannel.1
10.0.253.0      10.0.253.0      255.255.255.0   UG    0      0        0 flannel.1
10.0.254.0      10.0.254.0      255.255.255.0   UG    0      0        0 flannel.1
10.0.255.0      10.0.255.0      255.255.255.0   UG    0      0        0 flannel.1
10.1.0.0        10.1.0.0        255.255.255.0   UG    0      0        0 flannel.1
10.1.1.0        10.1.1.0        255.255.255.0   UG    0      0        0 flannel.1
............    ............    255.255.255.0   UG    0      0        0 flannel.1
............    ............    255.255.255.0   UG    0      0        0 flannel.1
10.1.247.0      10.1.247.0      255.255.255.0   UG    0      0        0 flannel.1   # node02宿主机所在Node网绺下其Subnet之外Subnet中相关宿主机从Pod网络分得subnet的路由
```

**Node网络下Subnet(172.31.1.0/24)下的节点(k8s node253)**
```
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.0.252.0      0.0.0.0         255.255.255.0   U     0      0        0 cni0

10.0.253.0      10.0.253.0      255.255.255.0   UG    0      0        0 flannel.1
10.0.254.0      10.0.254.0      255.255.255.0   UG    0      0        0 flannel.1
10.0.255.0      10.0.255.0      255.255.255.0   UG    0      0        0 flannel.1
10.1.0.0        10.1.0.0        255.255.255.0   UG    0      0        0 flannel.1
10.1.1.0        10.1.1.0        255.255.255.0   UG    0      0        0 flannel.1
..........      ..........      255.255.255.0   UG    0      0        0 flannel.1
..........      ..........      255.255.255.0   UG    0      0        0 flannel.1
10.1.247.0      10.1.247.0      255.255.255.0   UG    0      0        0 flannel.1   # node253宿主机所在Node网络下其Sbunet中其它宿主机从Pod网分得subnet的路由 

0.0.0.0         172.31.1.253    0.0.0.0         UG    0      0        0 eth0        # node253到所处Node网络下Subnet其网关的路由
172.31.1.0      0.0.0.0         255.255.255.0   U     0      0        0 eth0        # node253到所处Node网络下Subnet其网关的路由

10.0.0.0        10.0.0.0        255.255.255.0   UG    0      0        0 flannel.1
10.0.1.0        10.0.1.0        255.255.255.0   UG    0      0        0 flannel.1
10.0.2.0        10.0.2.0        255.255.255.0   UG    0      0        0 flannel.1
10.0.3.0        10.0.3.0        255.255.255.0   UG    0      0        0 flannel.1
..........      ..........      255.255.255.0   UG    0      0        0 flannel.1
..........      ..........      255.255.255.0   UG    0      0        0 flannel.1
10.0.251.0      10.0.251.0      255.255.255.0   UG    0      0        0 flannel.1   # node253宿主机所在Node网绺下其Subnet之外Subnet中相关宿主机从Pod网络分得subnet的路由 
```

## 1.3 同宿主机上Pod间的通信
注意：直接通过cni0网关就进行转发了
<image src="./picture/SameHost-Pod-to-Pod-Communication.jpg" style="width: 100%; height: auto;">

## 1.4 跨宿主机(处于同一网关)间Pod的通信
注意：会经过双方宿主机上其隧道设备flannel.1。  
**ClientPod**
<image src="./picture/CoressHost-SameSubnet-Pod-to-Pod-Communication-1.jpg" style="width: 100%; height: auto;">

**ServerPod**
<image src="./picture/CoressHost-SameSubnet-Pod-to-Pod-Communication-2.jpg" style="width: 100%; height: auto;">

## 1.5 跨宿主机(处于不同网关)间Pod的通信
注意：会经过双方宿主机上其隧道设备flannel.1。  
**ClientPod**
<image src="./picture/CoressHost-DifferentSubnet-Pod-to-Pod-Communication-1.jpg" style="width: 100%; height: auto;">

**ServerPod**
<image src="./picture/CoressHost-DifferentSubnet-Pod-to-Pod-Communication-2.jpg" style="width: 100%; height: auto;">
<br>
<br>


# 2.Flannel之vxlan(DirectRouting为false)的安装步骤
## 2.1 k8s集群的相关规划引入
<image src="./picture/flannel-vxlan-DirectRoute-false-plan-install.jpg" style="width: 100%; height: auto;">

```
## Node网络：172.31.0.0/16
  它是物理网络。underlay。

  交换机B-172-31-20-0-24：172.31.20.0/24
    etcd01  172.31.20.1
    etcd02  172.31.20.2
    etcd03  172.31.20.3
  交换机H-172-31-0-0-24： 172.31.0.0/24
    master01  172.31.0.1   # <== 会部署worker node相关组件
    master02  172.31.0.2   # <== 会部署worker node相关组件
    master03  172.31.0.3   # <== 会部署worker node相关组件
  交换机I-172-31-1-0-24： 172.31.1.0/24
    node01    172.31.1.1
    node02    172.31.1.2
    node03    172.31.1.3

## Pod网络：10.0.0.0/8
   它是个虚拟网络。overlay。
   kubernetes的kube-controller-manager组件实例
     --cluster-cidr参数指定值为10.0.0.0/8
     --node-cidr-mask-size参数指定值为24
        会按24位网络地址分配subnet,给到worker nodes,
        我们可以kubectl describe nodes <NodeName> 看其PodCIDRS:字段

## Svc网络：11.0.0.0/12
   它是个虚拟网络。overlay。网络地址得 >=12，不然kube-apiserver启动报错
   在k8s中被称为cluster network。
   集群中DNS应用(Pod)对应的svc使用的ClusterIP地址为：11.0.0.2
   集群中DNS的Domain为：cluster.local
```

## 2.2 k8s各Worker Node当前状态为NotReady
当前只把k8s的基本框架部署好了，就等着部署第一个addons之CNI插件了，部署好CNI插件后， 
k8s的各Worker Node状态就会Ready，但不代表"Pod间的通信"就一定正常，你得知道怎么去测试。
```
root@deploy:~# kubectl get nodes
NAME       STATUS                     ROLES    AGE   VERSION
master01   NotReady,SchedulingDisabled   master   14d   v1.24.4
master02   NotReady,SchedulingDisabled   master   14d   v1.24.4
master03   NotReady,SchedulingDisabled   master   14d   v1.24.4
node01     NotReady                      node     14d   v1.24.4
node02     NotReady                      node     14d   v1.24.4
node03     NotReady                      node     14d   v1.24.4
```
kube-controller-manager组件从Pod网络给各worker node分配的PodCIDRs信息为如下所示:
```
root@deploy:~# kubectl describe nodes | grep -E "Name:|PodCIDRs:"
Name:               master01
PodCIDRs:                     10.0.0.0/24
Name:               master02
PodCIDRs:                     10.0.1.0/24
Name:               master03
PodCIDRs:                     10.0.2.0/24
Name:               node01
PodCIDRs:                     10.0.3.0/24
Name:               node02
PodCIDRs:                     10.0.4.0/24
Name:               node03
PodCIDRs:                     10.0.5.0/24
```

## 2.3 k8s中安装CNI插件Flannel vxlan(DirectRouting: false)
**下载manifests**
```
#### 在线可读
https://github.com/flannel-io/flannel/blob/v0.22.3/Documentation/kube-flannel.yml

#### 下载
wget https://raw.githubusercontent.com/flannel-io/flannel/refs/tags/v0.22.3/Documentation/kube-flannel.yml
ls -l kube-flannel.yml
```

**修改manifests**
```
#### 查看所用的ns资源对象
grep "namespace:"  kube-flannel.yml
  #
  # 结果是 ns/kube-flannel 对象
  # 

#### 检查是否有所用ns资源对象的manifests
grep "^kind: Namespace" kube-flannel.yml
  #
  # 是有的
  # 这里就不剥离了
  #

#### 替换镜像
# <== 所用的image
root@deploy:~# grep "image:" kube-flannel.yml
        image: docker.io/flannel/flannel-cni-plugin:v1.2.0
        image: docker.io/flannel/flannel:v0.22.3
        image: docker.io/flannel/flannel:v0.22.3
root@deploy:~#
root@deploy:~# grep "docker.io" kube-flannel.yml
        image: docker.io/flannel/flannel-cni-plugin:v1.2.0
        image: docker.io/flannel/flannel:v0.22.3
        image: docker.io/flannel/flannel:v0.22.3

# <== 把镜像放在自己的镜像仓库中
我已将相关镜像放在我个人的镜像仓库中并公开（pull时不用认证）。
swr.cn-north-1.myhuaweicloud.com/qepyd/flannel-cni-plugin:v1.2.0
swr.cn-north-1.myhuaweicloud.com/qepyd/flannel:v0.22.3

# <== 替换镜像的相关命令
sed    's#docker.io/flannel/flannel-cni-plugin:v1.2.0#swr.cn-north-1.myhuaweicloud.com/qepyd/flannel-cni-plugin:v1.2.0#g'   kube-flannel.yml  | grep "image:"
sed -i 's#docker.io/flannel/flannel-cni-plugin:v1.2.0#swr.cn-north-1.myhuaweicloud.com/qepyd/flannel-cni-plugin:v1.2.0#g'   kube-flannel.yml

sed    's#docker.io/flannel/flannel:v0.22.3#swr.cn-north-1.myhuaweicloud.com/qepyd/flannel:v0.22.3#g'   kube-flannel.yml  | grep "image:"
sed -i 's#docker.io/flannel/flannel:v0.22.3#swr.cn-north-1.myhuaweicloud.com/qepyd/flannel:v0.22.3#g'   kube-flannel.yml

#### configmaps/kube-flannel-cfg对象
# <== data字段中的 net-conf.json 键相关值的更改
将 "Network": "10.244.0.0/16"  修改成  "Network": "10.0.0.0/8"
将 "Type": "vxlan"             修改成  "Type": "vxlan", 并在同级别下面添加 "DirectRouting": false
```

**应用manifests**
```
#### 应用manifests
kubectl apply -f kube-flannel.yml  --dry-run=client
kubectl apply -f kube-flannel.yml

#### 列出相关资源对象
kubectl get -f kube-flannel.yml

#### 检查k8s现有worker node是否处于Ready状态
kubectl get nodes -o wide
```

## 2.4 测试Pod访问互联网IPv4
当然k8s的worker node得要能够访问互联网。  
```
https://github.com/qepyd/kubernetes/blob/main/90.Addons/01.cni/ds_pod-in-container-visit-ipv4.yaml 
```

## 2.5 测试Pod访问互联网FQDN
**安装coredns**
```
参考 https://github.com/qepyd/kubernetes/tree/main/90.Addons/02.dns/01.coredns
```

**测试Pod访问互联网FQDN**
```
https://github.com/qepyd/kubernetes/blob/main/90.Addons/02.dns/ds_pod-in-container-visit-fqdn.yaml
```

## 2.6 Pod间的通信测试(必要的)
**创建ClientPod**
```
https://github.com/qepyd/kubernetes/blob/main/90.Addons/01.cni/ds_client.yaml
```

**创建ServerPod**
```
https://github.com/qepyd/kubernetes/blob/main/90.Addons/01.cni/ds_server.yaml
```

**宿主机上Pod间的通信**
```
........是能够通信的。
```

**跨宿主机(Node网络下相同subnet，L2通信)间Pod的通信**
```
........是能够通信的。
```

**跨宿主机(Node网络下不同subnet，L3通信)间Pod的通信**
```
........是能够通信的。

<br>
<br>

