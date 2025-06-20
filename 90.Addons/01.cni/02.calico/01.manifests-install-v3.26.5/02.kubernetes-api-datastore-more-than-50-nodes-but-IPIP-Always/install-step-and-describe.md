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
    master02  172.31.0.3   # <== 会部署worker node相关组件
  交换机I-172-31-1-0-24： 172.31.1.0/24
    node01    172.31.1.1
    node02    172.31.1.2
    node02    172.31.1.3

## Pod网络：10.0.0.0/8
   它是个虚拟网络。overlay。
   kubernetes的kube-controller-manager组件实例其--cluster-cidr参数有指定

## Svc网络：11.0.0.0/12
   它是个虚拟网络。overlay。 网络地址得 >=12，不然kube-apiserver启动报错
   在k8s中被称为cluster network。
   集群DNS的Domain为：cluster.local
   集群DNS的应用连接：11.0.0.2
```

## 2.2 k8s各Worker Node当前状态为NotReady
当前只把k8s的基本框架部署好了，就等着部署第一个addons之CNI插件了，部署好CNI插件后，
k8s的各Worker Node状态就会Ready，但不代表"Pod间的通信"就一定正常，你得知道怎么去测试。
```
root@deploy:~# kubectl get nodes
NAME       STATUS                     ROLES    AGE   VERSION
master01   NotReady,SchedulingDisabled   master   14d   v1.24.4
master02   NotReady,SchedulingDisabled   master   14d   v1.24.4
node01     NotReady                      node     14d   v1.24.4
node02     NotReady                      node     14d   v1.24.4
```

## 2.3 k8s中安装CNI插件Calico IPIP Always
**Clico模式选择**
```
IPIP模式之Always，我称之为Calico纯IPIP模式。
```

**样式**
```
Policy   IPAM    CNI      Overlay   Routing     Database
calico   calico  calico   ipip      bgp         kubernetes
```

**下载manifests**
```
wget https://raw.githubusercontent.com/projectcalico/calico/v3.26.5/manifests/calico-typha.yaml
ls -l calico-typha.yaml
```

**修改manifests**
```
## configmap/calico-config对象将被DaemonSet/calico-node对象引用
# <== 设置calico后端为brid，这样各worker node上具备felix、bird、confd进程。
calico_backend: "brid"

## daemonset/calico-node对象
# Enable IPIP
- name: CALICO_IPV4POOL_IPIP
  value: "Always"
	  
# Enable or Disable VXLAN on the default IP pool.
- name: CALICO_IPV4POOL_VXLAN
  value: "Never"
# Enable or Disable VXLAN on the default IPv6 IP pool.
- name: CALICO_IPV6POOL_VXLAN
  value: "Never"

# Pod Network IPv4 CIDR，default 192.168.0.0/16
- name: CALICO_IPV4POOL_CIDR
  value: "10.0.0.0/8"
# Pod Network IPv4 CIDR allocation subnet size，默认26
- name: CALICO_IPV4POOL_BLOCK_SIZE
  value: "24"

## deployment/calico-typha
其副本数默认为1，关于副本数的设置官方的建议为：
01：官方建议每200个worker node至少设置一个副本，最多不超过20个副本。
02：在生产环境中，我们建议至少设置三个副本，以减少滚动升级和故障的影响。
03：副本数量应始终小于节点数量，否则滚动升级将会停滞。
04：此外，只有当Typha实例数量少于节点数量时，Typha 才能帮助实现扩展。
```

**替换相关image**
```
## 所用镜像
grep image: calico-typha.yaml  | sort| uniq
   #
   # 所用镜像为
   #   image: docker.io/calico/cni:v3.26.5
   #   image: docker.io/calico/kube-controllers:v3.26.5
   #   image: docker.io/calico/node:v3.26.5
   #   - image: docker.io/calico/typha:v3.26.5
   #

## 替换镜像
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
```

**应用manifests**
```
kubectl apply -f calico-typha.yaml --dry-run=client
kubectl apply -f calico-typha.yaml
```

## 2.4 安装后相关资源对象的查看及说明
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
```

**calico-node**
```
## 列出ds/calico-node对象
kubectl -n kube-system get ds/calico-node

## 列出ds/calico-node对象所编排的Pod
kubectl -n kube-system get pods -o wide | grep calico-node
```

**各worker node上相关进程**
```
各worker node上具备felix、bird、confd进程
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
    blockSize: 24
    cidr: 10.0.0.0/8
    ipipMode: Always
    natOutgoing: true
    nodeSelector: all()
    vxlanMode: Never
kind: List
metadata:
  resourceVersion: ""
```

## 2.5 修改Worker Node从Pod网络得到的Subnet(为了学习)
注意：

