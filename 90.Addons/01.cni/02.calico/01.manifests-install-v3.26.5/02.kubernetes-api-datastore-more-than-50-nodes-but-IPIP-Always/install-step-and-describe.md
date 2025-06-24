# 1.Calico IPIP模式之Always的相关说明
## 1.1 网络平面图
<image src="./picture/calico-ipip-always-plan.jpg" style="width: 100%; height: auto;">

## 1.2 各宿主机上的路由
**Node网络下Subnet(172.31.0.0/24)下的节点(k8s node01)**
```
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.0.0.0        0.0.0.0         255.255.255.0   U     0      0        0 *
10.0.0.1        0.0.0.0         255.255.255.255 UH    0      0        0 cali<随机数11位>  
10.0.0.2        0.0.0.0         255.255.255.255 UH    0      0        0 cali<随机数11位>
..........      0.0.0.0         255.255.255.255 UH    0      0        0 cali<随机数11位>
..........      0.0.0.0         255.255.255.255 UH    0      0        0 cali<随机数11位>
10.0.0.255      0.0.0.0         255.255.255.255 UH    0      0        0 cali<随机数11位>    # node01宿主机上相关Pod副本(例如IP为10.0.0.255)在本机的路由 

10.0.1.0        172.31.0.2      255.255.255.0   UG    0      0        0 tunl0
10.0.2.0        172.31.0.3      255.255.255.0   UG    0      0        0 tunl0
..........      ............    255.255.255.0   UG    0      0        0 tunl0
..........      ............    255.255.255.0   UG    0      0        0 tunl0
10.0.251.0      172.31.0.252    255.255.255.0   UG    0      0        0 tunl0               # node01宿主机所在Node网络下其Sbunet中其它宿主机从Pod网分得subnet的路由 

0.0.0.0         172.31.0.253    0.0.0.0         UG    0      0        0 eth0                # node01到所处Node网络下Subnet其网关的路由
172.31.0.0      0.0.0.0         255.255.255.0   U     0      0        0 eth0                # node01到所处Node网络下Subnet其网关的路由

10.0.252.0      172.31.1.1      255.255.255.0   UG    0      0        0 tunl0
10.0.253.0      172.31.1.2      255.255.255.0   UG    0      0        0 tunl0
10.0.254.0      172.31.1.3      255.255.255.0   UG    0      0        0 tunl0
10.0.255.0      172.31.1.4      255.255.255.0   UG    0      0        0 tunl0
10.1.0.0        172.31.1.5      255.255.255.0   UG    0      0        0 tunl0
10.1.1.0        172.31.1.6      255.255.255.0   UG    0      0        0 tunl0
..........      ............    255.255.255.0   UG    0      0        0 tunl0
..........      ............    255.255.255.0   UG    0      0        0 tunl0
10.1.247.0      172.31.1.252    255.255.255.0   UG    0      0        0 tunl0               # node01宿主机所在Node网绺下其Subnet之外Subnet中相关宿主机从Pod网络分得subnet的路由 
```

**Node网络下Subnet(172.31.0.0/24)下的节点(k8s node02)**
```
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.0.1.0        0.0.0.0         255.255.255.0   U     0      0        0 *
10.0.1.1        0.0.0.0         255.255.255.255 UH    0      0        0 cali<随机数11位>
10.0.1.2        0.0.0.0         255.255.255.255 UH    0      0        0 cali<随机数11位>
..........      0.0.0.0         255.255.255.255 UH    0      0        0 cali<随机数11位>
..........      0.0.0.0         255.255.255.255 UH    0      0        0 cali<随机数11位>
10.0.1.255      0.0.0.0         255.255.255.255 UH    0      0        0 cali<随机数11位>    # node02宿主机上相关Pod副本(例如IP为10.0.1.255)在本机的路由

10.0.0.0        172.31.0.1      255.255.255.0   UG    0      0        0 tunl0
10.0.2.0        172.31.0.3      255.255.255.0   UG    0      0        0 tunl0
..........      ............    255.255.255.0   UG    0      0        0 tunl0
..........      ............    255.255.255.0   UG    0      0        0 tunl0
10.0.251.0      172.31.0.252    255.255.255.0   UG    0      0        0 tunl0               # node02宿主机所在Node网络下其Sbunet中其它宿主机从Pod网分得subnet的路由

0.0.0.0         172.31.0.253    0.0.0.0         UG    0      0        0 eth0                # node02到所处Node网络下Subnet其网关的路由
172.31.0.0      0.0.0.0         255.255.255.0   U     0      0        0 eth0                # node02到所处Node网络下Subnet其网关的路由

10.0.252.0      172.31.1.1      255.255.255.0   UG    0      0        0 tunl0
10.0.253.0      172.31.1.2      255.255.255.0   UG    0      0        0 tunl0
10.0.254.0      172.31.1.3      255.255.255.0   UG    0      0        0 tunl0
10.0.255.0      172.31.1.4      255.255.255.0   UG    0      0        0 tunl0
10.1.0.0        172.31.1.5      255.255.255.0   UG    0      0        0 tunl0
10.1.1.0        172.31.1.6      255.255.255.0   UG    0      0        0 tunl0
..........      ............    255.255.255.0   UG    0      0        0 tunl0
..........      ............    255.255.255.0   UG    0      0        0 tunl0
10.1.247.0      172.31.1.252    255.255.255.0   UG    0      0        0 tunl0               # node02宿主机所在Node网绺下其Subnet之外Subnet中相关宿主机从Pod网络分得subnet的路由
```

**Node网络下Subnet(172.31.1.0/24)下的节点(k8s node253)**
```
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.0.252.0      0.0.0.0         255.255.255.0   U     0      0        0 *
10.0.252.1      0.0.0.0         255.255.255.255 UH    0      0        0 cali<随机数11位>  
10.0.252.2      0.0.0.0         255.255.255.255 UH    0      0        0 cali<随机数11位>
..........      0.0.0.0         255.255.255.255 UH    0      0        0 cali<随机数11位>
..........      0.0.0.0         255.255.255.255 UH    0      0        0 cali<随机数11位>
10.0.252.255    0.0.0.0         255.255.255.255 UH    0      0        0 cali<随机数11位>    # node253宿主机上相关Pod副本(例如IP为10.0.252.255)在本机的路由

10.0.253.0      172.31.1.2      255.255.255.0   UG    0      0        0 tunl0
10.0.254.0      172.31.1.3      255.255.255.0   UG    0      0        0 tunl0
10.0.255.0      172.31.1.4      255.255.255.0   UG    0      0        0 tunl0
10.1.0.0        172.31.1.5      255.255.255.0   UG    0      0        0 tunl0
10.1.1.0        172.31.1.6      255.255.255.0   UG    0      0        0 tunl0
..........      ............    255.255.255.0   UG    0      0        0 tunl0
..........      ............    255.255.255.0   UG    0      0        0 tunl0
10.1.247.0      172.31.1.252    255.255.255.0   UG    0      0        0 tunl0               # node253宿主机所在Node网络下其Sbunet中其它宿主机从Pod网分得subnet的路由 

0.0.0.0         172.31.1.253    0.0.0.0         UG    0      0        0 eth0                # node253到所处Node网络下Subnet其网关的路由
172.31.1.0      0.0.0.0         255.255.255.0   U     0      0        0 eth0                # node253到所处Node网络下Subnet其网关的路由

10.0.0.0        172.31.0.1      255.255.255.0   UG    0      0        0 tunl0
10.0.1.0        172.31.0.2      255.255.255.0   UG    0      0        0 tunl0
10.0.2.0        172.31.0.3      255.255.255.0   UG    0      0        0 tunl0
..........      ............    255.255.255.0   UG    0      0        0 tunl0
..........      ............    255.255.255.0   UG    0      0        0 tunl0
10.0.251.0      172.31.0.252    255.255.255.0   UG    0      0        0 tunl0               # node253宿主机所在Node网绺下其Subnet之外Subnet中相关宿主机从Pod网络分得subnet的路由 
```

## 1.3 同宿主机上Pod间的通信
注意：直接通过本机的 Route Table进行路由后通信


## 1.4 跨宿主机(处于相同网关)间Pod的通信
注意：会经过双方宿主机的隧道设备tunl0


## 1.5 跨宿主机(处于不同网关)间Pod的通信
注意：会经过双方宿主机的隧道设备tunl0

<br>
<br>


# 2.Calico IPIP模式之Always的安装步骤
## 2.1 k8s集群的相关规划引入
<image src="./picture/calico-ipip-always-plan-install.jpg" style="width: 100%; height: auto;">

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
   kube-apiserver组件实例:
      --service-cluster-ip-range参数进行指定
   kube-controller-manager组件实例:
      --service-cluster-ip-range参数进行指定
   集群中DNS应用(Pod)对应的svc使用的ClusterIP地址为 11.0.0.2
      kubelet组件实例的 --cluster-dns 参数指定
   集群中DNS的Domain规划为 cluster.local
      kubelet组件实例的 --cluster-domain 参数指定。
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

## 2.3 k8s中安装CNI插件Calico IPIP Always
**Clico模式选择**
```
IPIP模式之Always，我称之为Calico纯IPIP模式。
```

**样式**
```
Policy   IPAM    CNI      Overlay   Routing    Database
calico   calico  calico   ipip      bgp        kubernetes
```

**下载manifests**
```
wget https://raw.githubusercontent.com/projectcalico/calico/v3.26.5/manifests/calico-typha.yaml
ls -l calico-typha.yaml
```

**修改manifests**
```
#### 查看所用namespace
grep "namespace:" calico-typha.yaml
  #
  # 用到的ns资源对象为kube-system
  #

#### 查看是否包含ns/kube-system对象的manifests
grep "^kind: Namespace" calico-typha.yaml
  #
  # 没有任何ns资源对象其manifests的存在
  #

#### 查看所用到的imge
grep "image:" calico-typha.yaml
  #
  # 所用到的镜像为：
  #   image: docker.io/calico/cni:v3.26.5
  #   image: docker.io/calico/kube-controllers:v3.26.5
  #   image: docker.io/calico/node:v3.26.5
  #   - image: docker.io/calico/typha:v3.26.5

#### 替换镜像
我已将相关镜像放至个人镜像仓库中并公开(下载时不用认证)。
   swr.cn-north-1.myhuaweicloud.com/qepyd/calico-cni:v3.26.5
   swr.cn-north-1.myhuaweicloud.com/qepyd/calico-node:v3.26.5
   swr.cn-north-1.myhuaweicloud.com/qepyd/calico-kube-controllers:v3.26.5
   swr.cn-north-1.myhuaweicloud.com/qepyd/calico-typha:v3.26.5
替换镜像
   sed  -i 's#docker.io/calico/cni:v3.26.5#swr.cn-north-1.myhuaweicloud.com/qepyd/calico-cni:v3.26.5#g'                            calico-typha.yaml
   sed  -i 's#docker.io/calico/node:v3.26.5#swr.cn-north-1.myhuaweicloud.com/qepyd/calico-node:v3.26.5#g'                          calico-typha.yaml
   sed  -i 's#docker.io/calico/kube-controllers:v3.26.5#swr.cn-north-1.myhuaweicloud.com/qepyd/calico-kube-controllers:v3.26.5#g'  calico-typha.yaml
   sed  -i "s#docker.io/calico/typha:v3.26.5#swr.cn-north-1.myhuaweicloud.com/qepyd/calico-typha:v3.26.5#g"                        calico-typha.yaml

#### ConfigMap/calico-config对象
# 设置calico后端为brid，这样各worker node上具备bird、confd进程
# 各worker node上的felix进程一定是有的
calico_backend: "brid"

#### DaemonSet/calico-node对象其Pod模板中的主容器之calico-node
# 配置calico的数据存储位置,默认为kubernetes(即连接kube-apiserver)
# 当Calico配置为使用Kubernetes API作为数据存储时，用于BGP配置的环
# 境将被忽略[这包括节点AS编号(AS)的选择和所有IP选择选项（IP、IP6、
# IP_AUTODETECTION_METHOD、IP6_AUTODETECTION_METHOD）]
- name: DATASTORE_TYPE
  value: "kubernetes"

# 开启或关闭IPIP模式,Never表示关闭,Always是其机制，CoressSubnet是其机制。
- name: CALICO_IPV4POOL_IPIP
  value: "Always"
	  
# 开启或关闭IPv4下VXLAN模式,Never表示关闭,Always是其机制,CoressSubnet是其机制。
- name: CALICO_IPV4POOL_VXLAN
  value: "Never"
# 开启或关闭IPv6下VXLAN模式,Never表示关闭,Always是其机制,CoressSubnet是其机制。
- name: CALICO_IPV6POOL_VXLAN
  value: "Never"

# Pod Network IPv4 CIDR，默认为192.168.0.0/16，可以不和kubernetes所规划的Pod网
# 络保持一致(即你可以另外指定一个网络,overlay)
- name: CALICO_IPV4POOL_CIDR
  value: "10.0.0.0/8"

# 基于Pod网络在给各worker node分配子网时其子网的大小,默认26位网络地址(理论上可用主机IP数为
# IP数62(1~62)个,但在此场景下可用主机数是63(1~63)个),当某worker node上的子网其IP数被占用完
# 以后,calico还会再基于Pod网络给某worker node分配子网。
# 我这时修改成了24
- name: CALICO_IPV4POOL_BLOCK_SIZE
  value: "24"

# Controls NAT Outgoing for the IPv4 Pool created at start up. [Default: true]
# 当Pod网络是overlay时，这里得设置成true，不然Pod中访问SvcName(FQDN)会失败(即使你安装有Dns、kube-proxy)。
- name: CALICO_IPV4POOL_NAT_OUTGOING
  value: "true"

#### deployment/calico-typha
其副本数默认为1，关于副本数的设置官方的建议为：
01：官方建议每200个worker node至少设置一个副本，最多不超过20个副本。
02：在生产环境中，我们建议至少设置三个副本，以减少滚动升级和故障的影响。
03：副本数量应始终小于节点数量，否则滚动升级将会停滞。
04：此外，只有当Typha实例数量少于节点数量时，Typha 才能帮助实现扩展。
```

**应用manifests**
```
## 应用manifests
kubectl apply -f calico-typha.yaml --dry-run=client
kubectl apply -f calico-typha.yaml

## 列出相关的Pod
kubectl -n kube-system get ds/calico-node
kubectl -n kube-system get pods | grep calico-node

## 查看当前k8s中worker node的状态
kubectl get nodes
  #
  # 此时各worker node的状态为包含Ready即为正常
  #
```

**到各worker node、管理机(具备当前k8s集群kubectl工具后用kubeconfig)上安装client工具calicoctl**
```
curl -L https://github.com/projectcalico/calico/releases/download/v3.26.5/calicoctl-linux-amd64 -o calicoctl
chmod +x calicoctl
mv calicoctl /usr/local/bin/
which calicoctl
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


# 3.Calico安装后的相关说明
## 3.1 基本的一些
**相关的crd**
```
root@deploy:~# 
root@deploy:~# kubectl get crd | grep calico.org
bgpconfigurations.crd.projectcalico.org               2025-06-17T12:09:49Z
bgpfilters.crd.projectcalico.org                      2025-06-17T12:09:49Z
bgppeers.crd.projectcalico.org                        2025-06-17T12:09:49Z
blockaffinities.crd.projectcalico.org                 2025-06-17T12:09:49Z
caliconodestatuses.crd.projectcalico.org              2025-06-17T12:09:49Z
clusterinformations.crd.projectcalico.org             2025-06-17T12:09:49Z
felixconfigurations.crd.projectcalico.org             2025-06-17T12:09:49Z
globalnetworkpolicies.crd.projectcalico.org           2025-06-17T12:09:49Z
globalnetworksets.crd.projectcalico.org               2025-06-17T12:09:49Z
hostendpoints.crd.projectcalico.org                   2025-06-17T12:09:50Z
ipamblocks.crd.projectcalico.org                      2025-06-17T12:09:50Z
ipamconfigs.crd.projectcalico.org                     2025-06-17T12:09:50Z
ipamhandles.crd.projectcalico.org                     2025-06-17T12:09:50Z
ippools.crd.projectcalico.org                         2025-06-17T12:09:50Z
ipreservations.crd.projectcalico.org                  2025-06-17T12:09:50Z
kubecontrollersconfigurations.crd.projectcalico.org   2025-06-17T12:09:50Z
networkpolicies.crd.projectcalico.org                 2025-06-17T12:09:50Z
networksets.crd.projectcalico.org                     2025-06-17T12:09:50Z
root@deploy:~# 
root@deploy:~# 
root@deploy:~# kubectl api-resources  | grep crd.projectcalico.org
bgpconfigurations                              crd.projectcalico.org/v1               false        BGPConfiguration
bgpfilters                                     crd.projectcalico.org/v1               false        BGPFilter
bgppeers                                       crd.projectcalico.org/v1               false        BGPPeer
blockaffinities                                crd.projectcalico.org/v1               false        BlockAffinity
caliconodestatuses                             crd.projectcalico.org/v1               false        CalicoNodeStatus
clusterinformations                            crd.projectcalico.org/v1               false        ClusterInformation
felixconfigurations                            crd.projectcalico.org/v1               false        FelixConfiguration
globalnetworkpolicies                          crd.projectcalico.org/v1               false        GlobalNetworkPolicy
globalnetworksets                              crd.projectcalico.org/v1               false        GlobalNetworkSet
hostendpoints                                  crd.projectcalico.org/v1               false        HostEndpoint
ipamblocks                                     crd.projectcalico.org/v1               false        IPAMBlock
ipamconfigs                                    crd.projectcalico.org/v1               false        IPAMConfig
ipamhandles                                    crd.projectcalico.org/v1               false        IPAMHandle
ippools                                        crd.projectcalico.org/v1               false        IPPool
ipreservations                                 crd.projectcalico.org/v1               false        IPReservation
kubecontrollersconfigurations                  crd.projectcalico.org/v1               false        KubeControllersConfiguration
networkpolicies                                crd.projectcalico.org/v1               true         NetworkPolicy
networksets                                    crd.projectcalico.org/v1               true         NetworkSet
```

**ds/calico-node**
```
## 列出ds/calico-node对象
kubectl -n kube-system get ds/calico-node

## 列出ds/calico-node对象所编排的Pod
kubectl -n kube-system get pods -o wide | grep calico-node
```

**各worker node上相关进程**  
到各worker node上具备felix、bird、confd进程
```
ps -ef | grep felix
ps -ef | grep bird
ps -ef | confd
```

**calico-typha**
```
## 列出deploy/calico-typha对象
kubectl -n kube-system get deploy/calico-typha

## 列出deploy/calico-typha对象所编排的Pod
kubectl -n kube-system get pods -o wide | grep calico-typha
```

## 3.2 BGP相关的
**各worker node上bgp的连接状态**
```
## 说明
启用BGP后，Calico 的默认行为是创建一个全网状的内部 BGP (iBGP) 连接，其中每个节点彼此对等。

## worker node之master01上的BGP连接情况
root@master01:~# calicoctl node status
Calico process is running.

IPv4 BGP status
+--------------+-------------------+-------+----------+-------------+
| PEER ADDRESS |     PEER TYPE     | STATE |  SINCE   |    INFO     |
+--------------+-------------------+-------+----------+-------------+
| 172.31.0.2   | node-to-node mesh | up    | 16:36:34 | Established |
| 172.31.0.3   | node-to-node mesh | up    | 17:43:34 | Established |
| 172.31.1.1   | node-to-node mesh | up    | 16:36:33 | Established |
| 172.31.1.2   | node-to-node mesh | up    | 16:36:34 | Established |
| 172.31.1.3   | node-to-node mesh | up    | 16:36:34 | Established |
+--------------+-------------------+-------+----------+-------------+   # 除了自己之外

IPv6 BGP status
No IPv6 peers found.

## worker node之master02上的BGP连接情况
root@master02:~# calicoctl node status
Calico process is running.

IPv4 BGP status
+--------------+-------------------+-------+----------+-------------+
| PEER ADDRESS |     PEER TYPE     | STATE |  SINCE   |    INFO     |
+--------------+-------------------+-------+----------+-------------+
| 172.31.0.1   | node-to-node mesh | up    | 16:36:34 | Established |
| 172.31.0.3   | node-to-node mesh | up    | 17:43:34 | Established |
| 172.31.1.1   | node-to-node mesh | up    | 15:40:15 | Established |
| 172.31.1.2   | node-to-node mesh | up    | 14:54:23 | Established |
| 172.31.1.3   | node-to-node mesh | up    | 15:10:03 | Established |
+--------------+-------------------+-------+----------+-------------+  # 除了自己之外

IPv6 BGP status
No IPv6 peers found.

## worker node之master03上的BGP连接情况
root@master03:~# calicoctl node status
Calico process is running.

IPv4 BGP status
+--------------+-------------------+-------+----------+-------------+
| PEER ADDRESS |     PEER TYPE     | STATE |  SINCE   |    INFO     |
+--------------+-------------------+-------+----------+-------------+
| 172.31.0.1   | node-to-node mesh | up    | 17:43:34 | Established |
| 172.31.0.2   | node-to-node mesh | up    | 17:43:34 | Established |
| 172.31.1.1   | node-to-node mesh | up    | 17:43:33 | Established |
| 172.31.1.2   | node-to-node mesh | up    | 17:43:33 | Established |
| 172.31.1.3   | node-to-node mesh | up    | 17:43:33 | Established |
+--------------+-------------------+-------+----------+-------------+  # 除了自己之外

IPv6 BGP status
No IPv6 peers found.

## worker node之node01上的BGP连接情况
root@node01:~# calicoctl node status
Calico process is running.

IPv4 BGP status
+--------------+-------------------+-------+----------+-------------+
| PEER ADDRESS |     PEER TYPE     | STATE |  SINCE   |    INFO     |
+--------------+-------------------+-------+----------+-------------+
| 172.31.0.1   | node-to-node mesh | up    | 16:36:32 | Established |
| 172.31.0.2   | node-to-node mesh | up    | 15:40:15 | Established |
| 172.31.0.3   | node-to-node mesh | up    | 17:43:34 | Established |
| 172.31.1.2   | node-to-node mesh | up    | 15:40:13 | Established |
| 172.31.1.3   | node-to-node mesh | up    | 15:40:13 | Established |
+--------------+-------------------+-------+----------+-------------+  # 除了自己之外

IPv6 BGP status
No IPv6 peers found.

## worker node之node02上的BGP连接情况
root@node02:~# calicoctl node status
Calico process is running.

IPv4 BGP status
+--------------+-------------------+-------+----------+-------------+
| PEER ADDRESS |     PEER TYPE     | STATE |  SINCE   |    INFO     |
+--------------+-------------------+-------+----------+-------------+
| 172.31.0.1   | node-to-node mesh | up    | 16:36:34 | Established |
| 172.31.0.2   | node-to-node mesh | up    | 14:54:24 | Established |
| 172.31.0.3   | node-to-node mesh | up    | 17:43:34 | Established |
| 172.31.1.1   | node-to-node mesh | up    | 15:40:14 | Established |
| 172.31.1.3   | node-to-node mesh | up    | 15:10:04 | Established |
+--------------+-------------------+-------+----------+-------------+  # 除了自己之外

IPv6 BGP status
No IPv6 peers found.

## worker Node之node03上的BGP连接情况
root@node03:~# calicoctl node status
Calico process is running.

IPv4 BGP status
+--------------+-------------------+-------+----------+-------------+
| PEER ADDRESS |     PEER TYPE     | STATE |  SINCE   |    INFO     |
+--------------+-------------------+-------+----------+-------------+
| 172.31.0.1   | node-to-node mesh | up    | 16:36:34 | Established |
| 172.31.0.2   | node-to-node mesh | up    | 15:10:04 | Established |
| 172.31.0.3   | node-to-node mesh | up    | 17:43:34 | Established |
| 172.31.1.1   | node-to-node mesh | up    | 15:40:14 | Established |
| 172.31.1.2   | node-to-node mesh | up    | 15:10:04 | Established |
+--------------+-------------------+-------+----------+-------------+ # 除了自己之外

IPv6 BGP status
No IPv6 peers found.
```

**AS编号(默认64512)**
```
root@deploy:~# calicoctl get nodes -o wide
NAME       ASN       IPV4            IPV6   
master01   (64512)   172.31.0.1/24          
master02   (64512)   172.31.0.2/24          
master03   (64512)   172.31.0.3/24          
node01     (64512)   172.31.1.1/24          
node02     (64512)   172.31.1.2/24          
node03     (64512)   172.31.1.3/24    
```

## 3.3 相关crd的对象
**列出ippools资源对象**
```
## 列出ippools资源对象
root@deploy:~# kubectl get ippools
NAME                  AGE
default-ipv4-ippool   21m

## 查看ipoools/default-ipv4-ippool对象的在线manifests
root@deploy:~# kubectl get ippools -o yaml
apiVersion: v1
items:
- apiVersion: crd.projectcalico.org/v1
  kind: IPPool
  metadata:
    annotations:
      projectcalico.org/metadata: '{"uid":"e6b4d437-05d2-4a12-b491-040b19deb7ac","creationTimestamp":"2025-06-11T16:49:59Z"}'
    creationTimestamp: "2025-06-11T16:49:59Z"
    generation: 1
    name: default-ipv4-ippool
    resourceVersion: "20161"
    uid: 6471c2b4-0e82-4348-9334-a5b7e82feca6
  spec:
    allowedUses:
    - Workload
    - Tunnel
    blockSize: 24           # 基于Pod网络划分子网时的大小：24
    cidr: 10.0.0.0/8        # Pod网络：10.0.0.0/8
    ipipMode: Always        # IPIP模式：其机制是Always
    natOutgoing: true       # # nat传出: 由CALICO_IPV4POOL_NAT_OUTGOING变量控制(默认为true) 
    nodeSelector: all()     # 节点选择：所有worker node，由CALICO_IPV4POOL_NODE_SELECTOR变量控制(默认为all())
    vxlanMode: Never        # VXLAN模式：Never表示关闭/禁用
kind: List
metadata:
  resourceVersion: ""
```

**blockaffinities资源对象**
```
root@deploy:~# kubectl get blockaffinities
NAME                      AGE
master01-10-86-170-0-24   16h
master02-10-223-71-0-24   16h
master03-10-83-172-0-24   16h
node01-10-214-66-0-24     16h
node02-10-126-231-0-24    16h
node03-10-130-186-0-24    16h
  #
  # 可看出各worker node当前只从Pod网络中得到了一个Subnet、Subnet的CIDR
  #
```

**ipamconfigs资源对象**
```
root@deploy:~# kubectl get ipamconfigs
NAME      AGE
default   17h
```

**ipamblocks资源对象**  
各资源中可看到与之关联的worker node，所关联handle_id(相关ipamhandles资源对象)，可用IP数的范围、哪些IP被占用了、哪些未被占用。
```
root@deploy:~# kubectl get ipamblocks
NAME              AGE
10-126-231-0-24   17h
10-130-186-0-24   17h
10-214-66-0-24    17h
10-223-71-0-24    17h
10-83-172-0-24    17h
10-86-170-0-24    17h
```

**ipamhandles资源对象**
```
root@deploy:~# kubectl get ipamhandles
NAME                                                                               AGE
ipip-tunnel-addr-master01                                                          17h
ipip-tunnel-addr-master02                                                          17h
ipip-tunnel-addr-master03                                                          17h
ipip-tunnel-addr-node01                                                            17h
ipip-tunnel-addr-node02                                                            17h
ipip-tunnel-addr-node03                                                            17h
k8s-pod-network.98d1c733cd91f2616378083c9c3f6b53a4320774d7001748894ae5309a2cdc15   17h
k8s-pod-network.cf18fbcbd446f6bd78af0a58d883206ae83fd10407cbd28a493f6ab6a4e0e0e6   17h
```

**felixconfigurations资源对象**
```
root@deploy:~# kubectl get felixconfigurations
NAME      AGE
default   17h
```

**kubecontrollersconfigurations资源对象**
```
root@deploy:~# kubectl get kubecontrollersconfigurations
NAME      AGE
default   17h
```

**clusterinformations资源对象**
```
root@deploy:~# kubectl get clusterinformations          
NAME      AGE
default   17h
```

# 4.Pod间通信的测试及再看各worker node上的Route
## 4.1 Pod间通信的测试(必要)
**创建ClientPod**  
https://github.com/qepyd/kubernetes/blob/main/90.Addons/01.cni/ds_client.yaml
```
## 应用manifests
kubectl apply -f https://raw.githubusercontent.com/qepyd/kubernetes/refs/heads/main/90.Addons/01.cni/ds_client.yaml

## 相关Pod副本
root@deploy:~# kubectl get pods -o wide | grep client | sort -k 7
client-cqtzl   1/1     Running   0          24s   10.86.170.3    master01   <none>           <none>
client-kzztg   1/1     Running   0          24s   10.223.71.3    master02   <none>           <none>
client-lmv8z   1/1     Running   0          24s   10.83.172.3    master03   <none>           <none>
client-9dlbs   1/1     Running   0          24s   10.214.66.4    node01     <none>           <none>
client-4p7qh   1/1     Running   0          24s   10.126.231.3   node02     <none>           <none>
client-6cvfc   1/1     Running   0          24s   10.130.186.4   node03     <none>           <none>
```

**创建ServerPod**  
https://github.com/qepyd/kubernetes/blob/main/90.Addons/01.cni/ds_server.yaml
```
## 应用manifests
kubectl apply -f  https://raw.githubusercontent.com/qepyd/kubernetes/refs/heads/main/90.Addons/01.cni/ds_server.yaml

## 相关Pod副本
root@deploy:~# kubectl get pods -o wide | grep server | sort -k 7
server-r49qh   1/1     Running   0          46s   10.86.170.4    master01   <none>           <none>
server-lm74r   1/1     Running   0          46s   10.223.71.4    master02   <none>           <none>
server-2lnbw   1/1     Running   0          46s   10.83.172.4    master03   <none>           <none>
server-lnk6j   1/1     Running   0          46s   10.214.66.5    node01     <none>           <none>
server-xvfrg   1/1     Running   0          46s   10.126.231.4   node02     <none>           <none>
server-ldz44   1/1     Running   0          46s   10.130.186.5   node03     <none>           <none>
```

**宿主机上Pod间的通信**
```
## 说明
master01宿主机上的 client-cqtzl  10.86.170.3  访问  master01上的 server-r49qh   10.86.170.4

## 操作
kubectl -n default exec -it pods/client-cqtzl  -- curl 10.86.170.4
  #
  # 是可以通信的
  #
```

**跨宿主机(Node网络下相同subnet，L2通信)间Pod的通信**
```
## 说明
master01宿主机上的 client-cqtzl  10.86.170.3  访问  master02上的 server-lm74r  10.223.71.4

## 操作
kubectl -n default exec -it pods/client-cqtzl  -- curl 10.223.71.4
  #
  # 是可以通信的
  #
```

**跨宿主机(Node网络下不同subnet，L3通信)间Pod的通信**
```
## 说明
master01宿主机上的 client-cqtzl  10.86.170.3  访问  node01上的 server-lnk6j 10.214.66.5

## 操作
kubectl -n default exec -it pods/client-cqtzl  -- curl 10.214.66.5
  #
  # 是可以通信的
  #  
```

## 4.2 再看各worker node上的Route
**Node网络下Subnet(172.31.0.0/24)中的节点(k8s master01)**
```
root@master01:~# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.86.170.0     0.0.0.0         255.255.255.0   U     0      0        0 *
10.86.170.3     0.0.0.0         255.255.255.255 UH    0      0        0 calibe7d9632b2f
10.86.170.4     0.0.0.0         255.255.255.255 UH    0      0        0 calib07ea39a035

10.223.71.0     172.31.0.2      255.255.255.0   UG    0      0        0 tunl0
10.83.172.0     172.31.0.3      255.255.255.0   UG    0      0        0 tunl0

0.0.0.0         172.31.0.253    0.0.0.0         UG    100    0        0 eth0
172.31.0.0      0.0.0.0         255.255.255.0   U     100    0        0 eth0

10.214.66.0     172.31.1.1      255.255.255.0   UG    0      0        0 tunl0
10.126.231.0    172.31.1.2      255.255.255.0   UG    0      0        0 tunl0
10.130.186.0    172.31.1.3      255.255.255.0   UG    0      0        0 tunl0
```

**Node网络下Subnet(172.31.0.0/24)中的节点(k8s master02)**
```
root@master02:~# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.223.71.0     0.0.0.0         255.255.255.0   U     0      0        0 *
10.223.71.3     0.0.0.0         255.255.255.255 UH    0      0        0 cali58e95b3a33e
10.223.71.4     0.0.0.0         255.255.255.255 UH    0      0        0 cali9d7b8fce1a1

10.86.170.0     172.31.0.1      255.255.255.0   UG    0      0        0 tunl0
10.83.172.0     172.31.0.3      255.255.255.0   UG    0      0        0 tunl0

0.0.0.0         172.31.0.253    0.0.0.0         UG    100    0        0 eth0
172.31.0.0      0.0.0.0         255.255.255.0   U     100    0        0 eth0

10.214.66.0     172.31.1.1      255.255.255.0   UG    0      0        0 tunl0
10.126.231.0    172.31.1.2      255.255.255.0   UG    0      0        0 tunl0
10.130.186.0    172.31.1.3      255.255.255.0   UG    0      0        0 tunl0
```

**Node网络下Subnet(172.31.0.0/24)中的节点(k8s master03)**
```
root@master03:~# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.83.172.0     0.0.0.0         255.255.255.0   U     0      0        0 *
10.83.172.3     0.0.0.0         255.255.255.255 UH    0      0        0 cali2f9eb8064db
10.83.172.4     0.0.0.0         255.255.255.255 UH    0      0        0 cali3a360f74eee

10.86.170.0     172.31.0.1      255.255.255.0   UG    0      0        0 tunl0
10.223.71.0     172.31.0.2      255.255.255.0   UG    0      0        0 tunl0

0.0.0.0         172.31.0.253    0.0.0.0         UG    100    0        0 eth0
172.31.0.0      0.0.0.0         255.255.255.0   U     100    0        0 eth0

10.214.66.0     172.31.1.1      255.255.255.0   UG    0      0        0 tunl0
10.126.231.0    172.31.1.2      255.255.255.0   UG    0      0        0 tunl0
10.130.186.0    172.31.1.3      255.255.255.0   UG    0      0        0 tunl0
```

**Node网络下Subnet(172.31.1.0/24)中的节点(k8s node01)**
```
root@node01:~# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.214.66.0     0.0.0.0         255.255.255.0   U     0      0        0 *
10.214.66.1     0.0.0.0         255.255.255.255 UH    0      0        0 califa579ac4621
10.214.66.4     0.0.0.0         255.255.255.255 UH    0      0        0 cali65cb8a626f2
10.214.66.5     0.0.0.0         255.255.255.255 UH    0      0        0 cali250966d7553

10.126.231.0    172.31.1.2      255.255.255.0   UG    0      0        0 tunl0
10.130.186.0    172.31.1.3      255.255.255.0   UG    0      0        0 tunl0

0.0.0.0         172.31.1.253    0.0.0.0         UG    100    0        0 eth0
172.31.1.0      0.0.0.0         255.255.255.0   U     100    0        0 eth0

10.86.170.0     172.31.0.1      255.255.255.0   UG    0      0        0 tunl0
10.223.71.0     172.31.0.2      255.255.255.0   UG    0      0        0 tunl0
10.83.172.0     172.31.0.3      255.255.255.0   UG    0      0        0 tunl0
```

**Node网络下Subnet(172.31.1.0/24)中的节点(k8s node02)**
```
root@node02:~# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.126.231.0    0.0.0.0         255.255.255.0   U     0      0        0 *
10.126.231.3    0.0.0.0         255.255.255.255 UH    0      0        0 calie05bd548ecc
10.126.231.4    0.0.0.0         255.255.255.255 UH    0      0        0 cali6d197cfdeb7

10.214.66.0     172.31.1.1      255.255.255.0   UG    0      0        0 tunl0
10.130.186.0    172.31.1.3      255.255.255.0   UG    0      0        0 tunl0

0.0.0.0         172.31.1.253    0.0.0.0         UG    100    0        0 eth0
172.31.1.0      0.0.0.0         255.255.255.0   U     100    0        0 eth0

10.86.170.0     172.31.0.1      255.255.255.0   UG    0      0        0 tunl0
10.223.71.0     172.31.0.2      255.255.255.0   UG    0      0        0 tunl0
10.83.172.0     172.31.0.3      255.255.255.0   UG    0      0        0 tunl0
```

**Node网络下Subnet(172.31.1.0/24)中的节点(k8s node03)**
```
root@node03:~# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.130.186.0    0.0.0.0         255.255.255.0   U     0      0        0 *
10.130.186.1    0.0.0.0         255.255.255.255 UH    0      0        0 cali2ab7d6ab173
10.130.186.4    0.0.0.0         255.255.255.255 UH    0      0        0 cali2be8dc97224
10.130.186.5    0.0.0.0         255.255.255.255 UH    0      0        0 cali18981628048

10.214.66.0     172.31.1.1      255.255.255.0   UG    0      0        0 tunl0
10.126.231.0    172.31.1.2      255.255.255.0   UG    0      0        0 tunl0

0.0.0.0         172.31.1.253    0.0.0.0         UG    100    0        0 eth0
172.31.1.0      0.0.0.0         255.255.255.0   U     100    0        0 eth0

10.86.170.0     172.31.0.1      255.255.255.0   UG    0      0        0 tunl0
10.223.71.0     172.31.0.2      255.255.255.0   UG    0      0        0 tunl0
10.83.172.0     172.31.0.3      255.255.255.0   UG    0      0        0 tunl0
```

# 5.修改全网状的内部BGP(iBGP)成"使用某些节点作为路由反射器"
**挑选几个Worker Node作为来作为路由反射器，给其打上标签**
```
kubectl label node  master01 route-reflector=true
kubectl label node  master02 route-reflector=true
kubectl label node  master03 route-reflector=true
  #
  # 取消标签的命令为
  #   kubectl label node  master01 route-reflector-
  #   kubectl label node  master02 route-reflector-
  #   kubectl label node  master03 route-reflector-
  #
```

**创建BGPPeer资源对象**
```
## 编写manifests
cat >./01.bgppeer_node-as-route-reflectors.yaml<<'EOF'
kind: BGPPeer
apiVersion: crd.projectcalico.org/v1
metadata:
  name: node-as-route-reflectors
spec:
  nodeSelector: all()
  peerSelector: route-reflector == 'true'
EOF

## 应用manifests
kubectl apply -f 01.bgppeer_node-as-route-reflectors.yaml --dry-run=client
kubectl apply -f 01.bgppeer_node-as-route-reflectors.yaml

## 各worker node上的BGP连接状态为(以master01、node02的来展示)
root@master01:~# calicoctl node status
Calico process is running.

IPv4 BGP status
+--------------+-------------------+-------+----------+-------------+
| PEER ADDRESS |     PEER TYPE     | STATE |  SINCE   |    INFO     |
+--------------+-------------------+-------+----------+-------------+
| 172.31.1.1   | node-to-node mesh | up    | 20:22:51 | Established |
| 172.31.1.2   | node-to-node mesh | up    | 20:22:52 | Established |
| 172.31.1.3   | node-to-node mesh | up    | 20:22:52 | Established |
| 172.31.0.2   | node-to-node mesh | up    | 20:22:52 | Established |
| 172.31.0.3   | node-to-node mesh | up    | 20:22:53 | Established |
| 172.31.0.2   | node specific     | start | 20:26:37 | Idle        |
| 172.31.0.3   | node specific     | start | 20:26:37 | Idle        |
| 172.31.1.1   | node specific     | start | 20:26:37 | Idle        |
| 172.31.1.2   | node specific     | start | 20:26:37 | Idle        |
| 172.31.1.3   | node specific     | start | 20:26:37 | Idle        |
+--------------+-------------------+-------+----------+-------------+

IPv6 BGP status
No IPv6 peers found.

root@node01:~# calicoctl node status
Calico process is running.

IPv4 BGP status
+--------------+-------------------+-------+----------+-------------+
| PEER ADDRESS |     PEER TYPE     | STATE |  SINCE   |    INFO     |
+--------------+-------------------+-------+----------+-------------+
| 172.31.1.2   | node-to-node mesh | up    | 15:40:13 | Established |
| 172.31.1.3   | node-to-node mesh | up    | 15:40:13 | Established |
| 172.31.0.1   | node-to-node mesh | up    | 20:22:52 | Established |
| 172.31.0.2   | node-to-node mesh | up    | 20:22:53 | Established |
| 172.31.0.3   | node-to-node mesh | up    | 20:22:54 | Established |
| 172.31.0.1   | node specific     | start | 20:26:37 | Idle        |
| 172.31.0.2   | node specific     | start | 20:26:37 | Idle        |
| 172.31.0.3   | node specific     | start | 20:26:37 | Idle        |
+--------------+-------------------+-------+----------+-------------+

IPv6 BGP status
No IPv6 peers found.


## 是否影响Pod间的通信
不会影响。同宿主机上Pod间的通信、跨宿主机(Node网络下相同Subnet)间Pod的通信、跨宿主机(Node网络下不同Subnet)间Pod的通信
```

**创建bgpconfigurations/default对象**
```
## 编写manifests
cat >./02.bgpconfigurations_default.yaml<<'EOF'
apiVersion: crd.projectcalico.org/v1
kind: BGPConfiguration
metadata:
  # 名字必须得是default,不然关闭不了
  name: default 
spec:
  logSeverityScreen: Info
  # 修改成了false
  nodeToNodeMeshEnabled: false
  asNumber: 64512
EOF

## 应用manifests
kubectl apply -f 02.bgpconfigurations_default.yaml  --dry-run=client
kubectl apply -f 02.bgpconfigurations_default.yaml

## 各worker node上BGP的连接状态展示
root@master01:~#
root@master01:~#
root@master01:~# calicoctl node status
Calico process is running.

IPv4 BGP status
+--------------+---------------+-------+----------+-------------+
| PEER ADDRESS |   PEER TYPE   | STATE |  SINCE   |    INFO     |
+--------------+---------------+-------+----------+-------------+
| 172.31.0.2   | node specific | up    | 20:36:05 | Established |
| 172.31.0.3   | node specific | up    | 20:36:05 | Established |
| 172.31.1.1   | node specific | up    | 20:36:05 | Established |
| 172.31.1.2   | node specific | up    | 20:36:05 | Established |
| 172.31.1.3   | node specific | up    | 20:36:05 | Established |
+--------------+---------------+-------+----------+-------------+  # 它作为路由反射器(rr),肯定是要有其它所有worker node的连接

IPv6 BGP status
No IPv6 peers found.

root@master02:~#
root@master02:~#
root@master02:~# calicoctl node status
Calico process is running.

IPv4 BGP status
+--------------+---------------+-------+----------+-------------+
| PEER ADDRESS |   PEER TYPE   | STATE |  SINCE   |    INFO     |
+--------------+---------------+-------+----------+-------------+
| 172.31.0.3   | node specific | up    | 20:43:52 | Established |
| 172.31.0.1   | node specific | up    | 20:43:50 | Established |
| 172.31.1.1   | node specific | up    | 20:43:51 | Established |
| 172.31.1.2   | node specific | up    | 20:43:51 | Established |
| 172.31.1.3   | node specific | up    | 20:43:50 | Established |
+--------------+---------------+-------+----------+-------------+  # 它作为路由反射器(rr),肯定是要有其它所有worker node的连接

IPv6 BGP status
No IPv6 peers found.

root@master03:~#
root@master03:~#
root@master03:~# calicoctl node status
Calico process is running.

IPv4 BGP status
+--------------+---------------+-------+----------+-------------+
| PEER ADDRESS |   PEER TYPE   | STATE |  SINCE   |    INFO     |
+--------------+---------------+-------+----------+-------------+
| 172.31.0.1   | node specific | up    | 20:43:51 | Established |
| 172.31.0.2   | node specific | up    | 20:43:51 | Established |
| 172.31.1.1   | node specific | up    | 20:43:51 | Established |
| 172.31.1.2   | node specific | up    | 20:43:51 | Established |
| 172.31.1.3   | node specific | up    | 20:43:51 | Established |
+--------------+---------------+-------+----------+-------------+ # 它作为路由反射器(rr),肯定是要有其它所有worker node的连接

IPv6 BGP status
No IPv6 peers found.


root@node01:~#
root@node01:~#
root@node01:~# calicoctl  node status
Calico process is running.

IPv4 BGP status
+--------------+---------------+-------+----------+-------------+
| PEER ADDRESS |   PEER TYPE   | STATE |  SINCE   |    INFO     |
+--------------+---------------+-------+----------+-------------+
| 172.31.0.1   | node specific | up    | 20:36:05 | Established |
| 172.31.0.2   | node specific | up    | 20:36:06 | Established |
| 172.31.0.3   | node specific | up    | 20:36:06 | Established |
+--------------+---------------+-------+----------+-------------+   # 它会到作为路由反身器(rr)的节点上去建立bgp连接

IPv6 BGP status
No IPv6 peers found.


root@node02:~# 
root@node02:~# 
root@node02:~# calicoctl node status
Calico process is running.

IPv4 BGP status
+--------------+---------------+-------+----------+-------------+
| PEER ADDRESS |   PEER TYPE   | STATE |  SINCE   |    INFO     |
+--------------+---------------+-------+----------+-------------+
| 172.31.0.1   | node specific | up    | 20:43:50 | Established |
| 172.31.0.2   | node specific | up    | 20:43:51 | Established |
| 172.31.0.3   | node specific | up    | 20:43:52 | Established |
+--------------+---------------+-------+----------+-------------+  # 它会到作为路由反身器(rr)的节点上去建立bgp连接

IPv6 BGP status
No IPv6 peers found.


root@node03:~# 
root@node03:~# 
root@node03:~# calicoctl node status
Calico process is running.

IPv4 BGP status
+--------------+---------------+-------+----------+-------------+
| PEER ADDRESS |   PEER TYPE   | STATE |  SINCE   |    INFO     |
+--------------+---------------+-------+----------+-------------+
| 172.31.0.1   | node specific | up    | 20:43:50 | Established |
| 172.31.0.2   | node specific | up    | 20:43:51 | Established |
| 172.31.0.3   | node specific | up    | 20:43:52 | Established |
+--------------+---------------+-------+----------+-------------+  # 它会到作为路由反身器(rr)的节点上去建立bgp连接

IPv6 BGP status
No IPv6 peers found.


## 是否影响Pod间的通信
不会影响。同宿主机上Pod间的通信、跨宿主机(Node网络下相同Subnet)间Pod的通信、跨宿主机(Node网络下不同Subnet)间Pod的通信
```

**若想恢复BGP全网状**  
即上述操作反着来
```
kubectl delete -f 02.bgpconfigurations_default.yaml
kubectl delete -f 01.bgppeer_node-as-route-reflectors.yaml
取消所选worker node上的标签
```


