# 1.k8s集群的相关规划引入
```
Node网络：172.31.0.0/16
   子网1：172.31.1.0/24
        etcd01    172.31.1.1/24
        etcd02    172.31.1.2/24
        etcd03    172.31.1.3/24
	master01  172.31.1.4/24
	master02  172.31.1.5/24
	master03  172.31.1.6/24

   子网2：172.31.2.0/24
	node01    172.31.2.1/24
	node02    172.31.2.2/24

   子网3：172.31.3.0/24
 	node03    172.31.3.1/24
	node04    172.31.3.2/24

Node网络：10.244.0.0/16
    
Svc网络：10.144.0.0/16
   集群dns的daemon: cluster.local
   集群dns应用的ip: 10.144.0.2
   各worker node上kubelet指定dns应用的ip为: 10.144.0.2
```

# 2.k8s各Worker Node状态
只部署了基本框架，就等着安装CNI插件呢。安装好CNI插件后，其各worker node的状态就是Ready了。
```
roott@deploy:~# kubectl get nodes
NAME       STATUS                        ROLES    AGE   VERSION
master01   NotReady,SchedulingDisabled   master   2d    v1.24.4
master02   NotReady,SchedulingDisabled   master   2d    v1.24.4
master03   NotReady,SchedulingDisabled   master   2d    v1.24.4
node01     NotReady                      node     2d    v1.24.4
node02     NotReady                      node     2d    v1.24.4
node03     NotReady                      node     2d    v1.24.4
node04     NotReady                      node     2d    v1.24.4
```

# 3.安装CNI插件之Calico 
**Clico模式选择**
```
VXLAN模式之Always，即Calico纯VXLAN模式。
```

**样式**
```
Policy   IPAM    CNI      Overlay        Routing   Database
calico   calico  calico   vxlan          calico    kubernetes
```

**下载manifests**
```
wget https://raw.githubusercontent.com/projectcalico/calico/v3.26.5/manifests/calico-typha.yaml
ls -l calico-typha.yaml
```

**修改manifests**
```
#### configmap/calico-config对象将被DaemonSet/calico-node对象引用
# <== 设置calico后端
calico_backend: "vxlan"  # 可修改为vxlan

#### daemonset/calico-node对象
# Enable IPIP
- name: CALICO_IPV4POOL_IPIP
  value: "Never"
	  
# Enable or Disable VXLAN on the default IP pool.
- name: CALICO_IPV4POOL_VXLAN
  value: "Always"
# Enable or Disable VXLAN on the default IPv6 IP pool.
- name: CALICO_IPV6POOL_VXLAN
  value: "Never"

- name: CALICO_IPV4POOL_CIDR
  value: "10.244.0.0/16"
- name: CALICO_IPV4POOL_BLOCK_SIZE
  value: "24"

#### deployment/calico-typha
其副本数默认为1，关于副本数的设置官方的建议为：
01：官方建议每200个worker node至少设置一个副本，最多不超过20个副本。
02：在生产环境中，我们建议至少设置三个副本，以减少滚动升级和故障的影响。
03：副本数量应始终小于节点数量，否则滚动升级将会停滞。
04：此外，只有当Typha实例数量少于节点数量时，Typha 才能帮助实现扩展。
```

**替换相关image**
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

**应用manifests**
```
## 应用manifests
kubectl apply -f calico-typha.yaml

## 列出相关Pod
root@deploy:~# kubectl  -n kube-system get pods -o wide | grep calico | sort -k 7
calico-node-hqxqt                         1/1     Running   0          50s   172.31.1.4    master01   <none>           <none>
calico-node-jln7n                         1/1     Running   0          50s   172.31.1.5    master02   <none>           <none>
calico-typha-8c6dfc44b-8fljf              1/1     Running   0          50s   172.31.1.5    master02   <none>           <none>
calico-node-dhpzl                         1/1     Running   0          50s   172.31.1.6    master03   <none>           <none>
calico-node-vsmjg                         1/1     Running   0          50s   172.31.2.1    node01     <none>           <none>
calico-node-ppskf                         1/1     Running   0          50s   172.31.2.2    node02     <none>           <none>
calico-node-jxphk                         1/1     Running   0          50s   172.31.3.1    node03     <none>           <none>
calico-kube-controllers-7847d5868-shgzk   1/1     Running   0          50s   10.244.99.1   node03     <none>           <none>
calico-node-wwttk                         1/1     Running   0          50s   172.31.3.2    node04     <none>           <none>

## 查看各worker node的状态
root@deploy:~# kubectl get nodes
NAME       STATUS                     ROLES    AGE   VERSION
master01   Ready,SchedulingDisabled   master   2d    v1.24.4
master02   Ready,SchedulingDisabled   master   2d    v1.24.4
master03   Ready,SchedulingDisabled   master   2d    v1.24.4
node01     Ready                      node     2d    v1.24.4
node02     Ready                      node     2d    v1.24.4
node03     Ready                      node     2d    v1.24.4
node04     Ready                      node     2d    v1.24.4

## 有相关的crd
kubectl get crd | grep calico
  # 
  # ............
  # ............
  #

## 列出 ippools 资源对象
root@deploy:~# 
root@deploy:~# kubectl get ippools
NAME                  AGE
default-ipv4-ippool   21m
root@deploy:~#
root@deploy:~#

## 查看 ippools/default-ipv4-ippool 对象的在线manifests
root@deploy:~# 
root@deploy:~# kubectl get ippools -o yaml
apiVersion: v1
items:
- apiVersion: crd.projectcalico.org/v1
  kind: IPPool
  metadata:
    annotations:
      projectcalico.org/metadata: '{"uid":"5a56a03f-c1f2-49c2-b92f-dc0f9ab69a27","creationTimestamp":"2025-06-10T07:03:30Z"}'
    creationTimestamp: "2025-06-10T07:03:30Z"
    generation: 1
    name: default-ipv4-ippool
    resourceVersion: "12964"
    uid: 8a7b61a0-d75c-4678-99d2-3826cdfd47df
  spec:
    allowedUses:
    - Workload
    - Tunnel
    blockSize: 24               # <== 从IPv4CIDR中分配子网时,其子网的大小,我修改成了24
    cidr: 10.244.0.0/16         # <== IPv4的CIDR(我让其与我规范的保持了一致)
    ipipMode: Never             # <== Calico IPIP模式被禁用了的
    natOutgoing: true
    nodeSelector: all()         # <== 选择所有的worker node
    vxlanMode: Always           # <== Calico VXLAN模式之Always
kind: List
metadata:
  resourceVersion: ""
root@deploy:~# 
root@deploy:~# 
root@deploy:~# 

## 列出 blockaffinities 资源对象
root@deploy:~# kubectl get blockaffinities
NAME                       AGE
master01-10-244-170-0-24   25m
master02-10-244-239-0-24   25m
master03-10-244-40-0-24    25m
node01-10-244-220-0-24     25m
node02-10-244-231-0-24     25m
node03-10-244-99-0-24      25m
node04-10-244-143-0-24     25m
   #
   # 可看出给各worker node分配的子网(来自于10.244.0.0/16)
   # 不遵循describe WorkerNode 中的 PodCIDRs
   # 当某worker node上分配的子网中的IPv4用完后，会再给其分配子网
   #   但worker node是有Pod个数限制的哈(默认110),这里分配的子网,其IPv4肯定用不完的
   # 
```

# 4.创建几个Pod
应用 https://github.com/qepyd/kubernetes/tree/main/90.Addons/01.cni 下的 ds_client.yaml,   
会ping互联网IPv4(例如：223.5.5.5)，为了后面的对calico vxlan always的原理分析，其结果如下
```
root@deploy:~# kubectl  -n default get pods -o wide | grep client | sort -k 7
client-srnfg   1/1     Running   0          8m22s   10.244.170.1   master01   <none>           <none>
client-gq897   1/1     Running   0          8m22s   10.244.239.1   master02   <none>           <none>
client-mssql   1/1     Running   0          8m22s   10.244.40.1    master03   <none>           <none>
client-b76dk   1/1     Running   0          8m22s   10.244.220.1   node01     <none>           <none>
client-2hmzf   1/1     Running   0          8m22s   10.244.231.1   node02     <none>           <none>
client-dt79m   1/1     Running   0          8m22s   10.244.99.2    node03     <none>           <none>
client-zbh2h   1/1     Running   0          8m22s   10.244.143.1   node04     <none>           <none>
```

应用 https://github.com/qepyd/kubernetes/tree/main/90.Addons/01.cni 下的 ds_server.yaml，  
为了后面的对calico vxlan always的原理分析，其结果如下
```
root@deploy:~# kubectl  -n default get pods -o wide | grep server | sort -k 7
server-69lmp   1/1     Running   0          7m58s   10.244.170.2   master01   <none>           <none>
server-b4fk6   1/1     Running   0          7m58s   10.244.239.2   master02   <none>           <none>
server-ml52d   1/1     Running   0          7m58s   10.244.40.2    master03   <none>           <none>
server-h28zl   1/1     Running   0          7m58s   10.244.220.2   node01     <none>           <none>
server-gldfz   1/1     Running   0          7m58s   10.244.231.2   node02     <none>           <none>
server-4vz7d   1/1     Running   0          7m58s   10.244.99.3    node03     <none>           <none>
server-cbgkj   1/1     Running   0          7m58s   10.244.143.2   node04     <none>           <none>
```

# 5.k8s各Worker Node上的设备
```
隧道设备: vxlan.calico
  各worker node上的隧道设备具备不同的IPv4地址,但子网掩码为32，例如：
     master01  10.244.170.0/32
     master02  10.244.239.0/32
     master03  10.244.40.0/32
     node01    10.244.220.0/32
     node02    10.244.231.0/32
     node03    10.244.99.0/32
     node04    10.244.143.0/32
  拥有唯一的MAC地址，相同的广播地址
     master01  link/ether 66:aa:99:2f:dc:24 brd ff:ff:ff:ff:ff:ff 
     master02  link/ether 66:9a:be:a5:63:87 brd ff:ff:ff:ff:ff:ff

各容器一一对应所在宿主机上的设备: cali<随机数11位>
  没有IP地址。
  具备相同的MAC地址，相同的广播地址。
    link/ether ee:ee:ee:ee:ee:ee brd ff:ff:ff:ff:ff:ff
```

# 6.安装coredns
后面的相关测试中，可能需要在Pod中的容器里面安装软件。  
```
根据k8s的规划，可以部署
  https://github.com/qepyd/kubernetes/tree/main/90.Addons/02.dns/01.coredns 下的manifests
```

# 7.做一下必要测试
**前面做的测试**
```
"4.创建几个Pod" 处应用 ds_client.yaml 后，会从容器内部ping互联网IPv4(例如:223.5.5.5)
```

**这里再做必要测试(测试容器与容器的通信)**
```
## 同宿主机上Pod间的通信
# <== 说明
node01上 pods/client-b76dk (10.244.220.1)  与 node01上 pods/server-h28zl (10.244.220.2)

# <== 操作
kubectl -n default exec -it pods/client-b76dk  --  ping -c 2 10.244.220.2
  #
  # 结果是可以通信的 
  #


## 跨宿主机(在同一子网)间Pod的通信
# <== 说明
node01上 pods/client-b76dk (10.244.220.1)  与 node02上 pods/server-gldfz (10.244.231.2)

# <== 操作
kubectl -n default exec -it pods/client-b76dk  --  ping -c 2 10.244.231.2
  #
  # 结果是可以通信的
  # 


## 跨宿主机(不在同一子网)间Pod的通信
# <== 说明
node01上 pods/client-b76dk (10.244.220.1)  与 node03上 pods/server-4vz7d (10.244.99.3)

# <== 操作
kubectl -n default exec -it pods/client-b76dk  --  ping -c 2 10.244.99.3
  #
  # 结果是可以通信的
  # 
```

# 8.相关worker node上的route
**Node网络子网2中各worker node的route**
```
## node01
root@node01:~# 
root@node01:~# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.31.2.253    0.0.0.0         UG    100    0        0 eth0
10.244.40.0     10.244.40.0     255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
10.244.99.0     10.244.99.0     255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
10.244.143.0    10.244.143.0    255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
10.244.170.0    10.244.170.0    255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
10.244.220.0    0.0.0.0         255.255.255.0   U     0      0        0 *
10.244.220.1    0.0.0.0         255.255.255.255 UH    0      0        0 cali0dcca1f2adb  # 本机上的 Pod(10.244.220.1) 所对应本机上的 cali<随机数11位> 网卡
10.244.220.2    0.0.0.0         255.255.255.255 UH    0      0        0 cali914974cddc2  # 本机上的 Pod(10.244.220.2) 所对应本机上的 cali<随机数11位> 网卡 
10.244.231.0    10.244.231.0    255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico 
10.244.239.0    10.244.239.0    255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
172.31.2.0      0.0.0.0         255.255.255.0   U     100    0        0 eth0             # 本机eth0网卡(来自于node网络)与同子网通信的路由,例如：node01与node02的通信
172.31.2.253    0.0.0.0         255.255.255.255 UH    100    0        0 eth0             # 本机eth0网卡(来自于node网络)与非同子网通信的路由(到达网关处)
root@node01:~# 

## node02
root@node02:~# 
root@node02:~# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.31.2.253    0.0.0.0         UG    100    0        0 eth0
10.244.40.0     10.244.40.0     255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
10.244.99.0     10.244.99.0     255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
10.244.143.0    10.244.143.0    255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
10.244.170.0    10.244.170.0    255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
10.244.220.0    10.244.220.0    255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
10.244.231.0    0.0.0.0         255.255.255.0   U     0      0        0 *
10.244.231.1    0.0.0.0         255.255.255.255 UH    0      0        0 cali1b5158766a9  # 本机上的 Pod(10.244.231.1) 所对应本机上的 cali<随机数11位> 网卡
10.244.231.2    0.0.0.0         255.255.255.255 UH    0      0        0 cali804b82732a1  # 本机上的 Pod(10.244.231.2) 所对应本机上的 cali<随机数11位> 网卡
10.244.239.0    10.244.239.0    255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
172.31.2.0      0.0.0.0         255.255.255.0   U     100    0        0 eth0             # 本机eth0网卡(来自于node网络)与同子网通信的路由,例如：node02与node01的通信
172.31.2.253    0.0.0.0         255.255.255.255 UH    100    0        0 eth0             # 本机eth0网卡(来自于node网络)与非同子网通信的路由(到达网关处)
root@node02:~# 
```

**Node网络子网3中各worker node的route**
```
## node03
root@node03:~# 
root@node03:~# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.31.3.253    0.0.0.0         UG    100    0        0 eth0
10.244.40.0     10.244.40.0     255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
10.244.99.0     0.0.0.0         255.255.255.0   U     0      0        0 *
10.244.99.1     0.0.0.0         255.255.255.255 UH    0      0        0 cali9c03a6138eb  # 本机上的 Pod(10.244.99.1) 所对应本机上的 cali<随机数11位> 网卡
10.244.99.2     0.0.0.0         255.255.255.255 UH    0      0        0 cali2227d568990  # 本机上的 Pod(10.244.99.2) 所对应本机上的 cali<随机数11位> 网卡
10.244.99.3     0.0.0.0         255.255.255.255 UH    0      0        0 cali06eb98133be  # 本机上的 Pod(10.244.99.3) 所对应本机上的 cali<随机数11位> 网卡
10.244.143.0    10.244.143.0    255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
10.244.170.0    10.244.170.0    255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
10.244.220.0    10.244.220.0    255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
10.244.231.0    10.244.231.0    255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
10.244.239.0    10.244.239.0    255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
172.31.3.0      0.0.0.0         255.255.255.0   U     100    0        0 eth0             # 本机eth0网卡(来自于node网络)与同子网通信的路由,例如：node03与node04的通信
172.31.3.253    0.0.0.0         255.255.255.255 UH    100    0        0 eth0             # 本机eth0网卡(来自于node网络)与非同子网通信的路由(到达网关处)
root@node03:~# 

## node04
root@node04:~# 
root@node04:~# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.31.3.253    0.0.0.0         UG    100    0        0 eth0
10.244.40.0     10.244.40.0     255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
10.244.99.0     10.244.99.0     255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
10.244.143.0    0.0.0.0         255.255.255.0   U     0      0        0 *
10.244.143.1    0.0.0.0         255.255.255.255 UH    0      0        0 calib1aef58abd4  # 本机上的 Pod(10.244.143.1) 所对应本机上的 cali<随机数11位> 网卡
10.244.143.2    0.0.0.0         255.255.255.255 UH    0      0        0 caliab261192ca1  # 本机上的 Pod(10.244.143.2) 所对应本机上的 cali<随机数11位> 网卡
10.244.170.0    10.244.170.0    255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
10.244.220.0    10.244.220.0    255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
10.244.231.0    10.244.231.0    255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
10.244.239.0    10.244.239.0    255.255.255.0   UG    0      0        0 vxlan.calico     # 某worker node上的 隧道设备 vxlan.calico
172.31.3.0      0.0.0.0         255.255.255.0   U     100    0        0 eth0             # 本机eth0网卡(来自于node网络)与同子网通信的路由,例如：node04与node03的通信
172.31.3.253    0.0.0.0         255.255.255.255 UH    100    0        0 eth0             # 本机eth0网卡(来自于node网络)与非同子网通信的路由(到达网关处)
root@node04:~# 
```

# 9.同宿主机间Pod的通信抓包分析
## 9.1 抓包
**场景**
```
node01上 pods/client-b76dk (10.244.220.1)  与 node01上 pods/server-h28zl (10.244.220.2)
```

**说明**
```
同宿主机上Pod间的通信在本机就完成了，不会经过vxlan隧道，也不会经过本机的eth0网卡
```

**抓包相关命令(6个xshell窗口中执行)**
```
# <== 进入容器（client-b76dk）
kubectl -n default exec -it pods/client-b76dk /bin/bash   # 进入容器
   tcpdump -nn -vvv -i eth0  -p tcp port 80                  -w  1.1.Clinet-Pod-Internal-eth0.pcap

# <== node01宿主机上对 容器（client-b76dk） 对应的 cali<随机数11位> 网卡抓包
tcpdump -nn -vvv -i cali0dcca1f2adb  -p tcp port 80          -w  1.2.Clinet-Pod-In-Host-cali.pcap


# <== node01宿主机上对 eth0 网卡进行抓包
tcpdump -nn -vvv -i eth0             'udp and port 4789'            -w  1.3.Client-Server-Pod-In-Host-eth0.pcap
    #
    # 没有数据包经过
    # 

# <== node01宿主机上对 vxlan.calico 网卡进行抓包
tcpdump -nn -vvv -i vxlan.calico            -p tcp port 80   -w  1.4.Client-Server-Pod-In-Host-vxlan.calico.pcap
    #
    # 没有数据包经过
    #

# <== node01宿主机上对  pods/server-h28zl  对应的 cali<随机数11位> 网卡抓包
tcpdump -nn -vvv -i cali914974cddc2  -p tcp port 80          -w  1.5.Server-Pod-In-Host-cali.pcap


# <== 进入容器(pods/server-h28zl)
kubectl -n default exec -it pods/server-h28zl /bin/bash   # 进入容器
    tcpdump -nn -vvv -i eth0  -p tcp port 80                 -w  1.6.Server-Pod-Internal-eth0.pcap
```

**client：pods/client-b76dk (10.244.220.1) 发起请求**
```
kubectl -n default exec -it pods/client-b76dk /bin/bash  # 进入容器
   curl  10.244.220.2
```

**停止"抓包相关命令"并下载相关文件**
```
.................停止 ctrl + c
.................下载 sz 命令
```

## 9.2 分析
**ClientPod(client-b76dk 10.244.220.1) 发起请求**
```
源MAC地址  ：客户端Pod其eth0网卡的mac地址
源IP地址   : 客户端Pod的IP地址(10.244.220.1)
源Port 为  : 随机产生(32818)

目标MAC地址：mac地址(ee:ee:ee:ee:ee:ee)
目标IP地址 ：服务端Pod的IP地址(10.244.220.2)
目标Port为 : 服务端Pod的port(这里是80)
下一跳     ：169.254.1.1(route表中的网关)，到达 客户端Pod对应宿主机上的 cali<随机数11位> 网卡 
```
<image src="./picture/SameHost/1.1.Clinet-Pod-Internal-eth0.jpg" style="width: 100%; height: auto;">


**ClientPod(client-b76dk 10.244.220.1)在宿主机上的 cali<随机数11位> 网卡**
```
源MAC地址  ：客户端Pod其eth0网卡的mac地址
源IP地址   : 客户端Pod的IP地址(10.244.220.1)
源Port 为  : 随机产生(32818)

目标MAC地址：mac地址(ee:ee:ee:ee:ee:ee)
目标IP地址 ：服务端Pod的IP地址(10.244.220.2)
目标Port为 : 服务端Pod的port(这里是80)
下一跳：   : 所在宿主机的route表的 Destination字段中具备 10.244.220.2 地址，
             对应有 cali<随机数11位> 网卡[对应ServerPod(server-h28zl) ]
             所以不会经过本机的eth0和vxlan.calico网卡
```
<image src="./picture/SameHost/1.2.Clinet-Pod-In-Host-cali.jpg" style="width: 100%; height: auto;">

**同宿主机上的eth0网卡**
```
没有数据
```

**同宿主机上的vxlan.calico网卡**
```
没有数据
```

**ServerPod(server-h28zl 10.244.220.2 )在宿主机上的 cali<随机数11位> 网卡**
```
源MAC地址  ：mac地址(ee:ee:ee:ee:ee:ee)
源IP地址   : 客户端Pod的IP地址(10.244.220.1)
源Port 为  : 随机产生(32818)

目标MAC地址：服务端Pod其eth0网卡的mac地址
目标IP地址 ：服务端Pod的IP地址(10.244.220.2)
目标Port为 : 服务端Pod的port(这里是80)
           : 已在达服务端Pod其eth0网卡
``` 
<image src="./picture/SameHost/1.5.Server-Pod-In-Host-cali.jpg" style="width: 100%; height: auto;">


**ServerPod(server-h28zl 10.244.220.2 )**
```
源MAC地址  ：mac地址(ee:ee:ee:ee:ee:ee)
源IP地址   : 客户端Pod的IP地址(10.244.220.1)
源Port 为  : 随机产生(32818)

目标MAC地址：服务端Pod其eth0网卡的mac地址
目标IP地址 ：服务端Pod的IP地址(10.244.220.2)
目标Port为 : 服务端Pod的port(这里是80)
```
<image src="./picture/SameHost/1.6.Server-Pod-Internal-eth0.jpg" style="width: 100%; height: auto;">


# 10.跨宿主机间Pod的通信抓包分析
## 10.1 注意
这里的跨宿主间Pod的通信及分析，我没有强调宿主机间是否有跨Node网络下的子网(subnet)。这是因为
Calico VXLAN模式之Always机制下，只要跨主机【即使主机间在同一子网(Node网络下的)]都会走VXLAN隧道。
所以后面的实践基于 Node网络子网2 中的宿主机(node01、node02)间Pod的通信抓包分析。

## 10.2 抓包
**场景**
```
node01上 pods/client-b76dk (10.244.220.1)  与 node02上 pods/server-gldfz(10.244.231.2)
```

**抓包相关命令(8个xshell窗口中执行)**
```
# <== 进入容器（client-b76dk）
kubectl -n default exec -it pods/client-b76dk /bin/bash      # 进入容器
   tcpdump -nn -vvv -i eth0  -p tcp port 80                  -w  2.1.Clinet-Pod-Internal-eth0.pcap

# <== node01宿主机上对 容器（client-b76dk） 对应的 cali<随机数11位> 网卡抓包
tcpdump -nn -vvv -i cali0dcca1f2adb  -p tcp port 80          -w  2.2.Clinet-Pod-In-Host-cali.pcap

# <== node01宿主机上对 vxlan.calico 网卡进行抓包
tcpdump -nn -vvv -i vxlan.calico            -p tcp port 80   -w  2.3.Client-Pod-In-Host-vxlan.calico.pcap

# <== node01宿主机上对 eth0 网卡进行抓包
tcpdump -nn -vvv -i eth0             'udp and port 4789'     -w  2.4.Client-Pod-In-Host-eth0.pcap


# <== node02宿主机上对 eth0 网卡进行抓包
tcpdump -nn -vvv -i eth0             'udp and port 4789'     -w  2.5.Server-Pod-In-Host-eth0.pcap

# <== node02宿主机上对 vxlan.calico 网卡进行抓包
tcpdump -nn -vvv -i vxlan.calico            -p tcp port 80   -w  2.6.Server-Pod-In-Host-vxlan.calico.pcap

# <== node02宿主机上对  pods/server-gldfz   对应的 cali<随机数11位> 网卡抓包
tcpdump -nn -vvv -i cali804b82732a1  -p tcp port 80          -w  2.7.Server-Pod-In-Host-cali.pcap

# <== 进入容器(pods/server-gldfz)
kubectl -n default exec -it pods/server-gldfz  /bin/bash      # 进入容器
    tcpdump -nn -vvv -i eth0  -p tcp port 80                 -w  2.8.Server-Pod-Internal-eth0.pcap
```

**client：pods/client-b76dk (10.244.220.1) 发起请求**
```
kubectl -n default exec -it pods/client-b76dk /bin/bash  # 进入容器
   curl  10.244.231.2
```

**停止"抓包相关命令"并下载相关文件**
```
.................停止: ctrl + c
.................下载: sz 命令
```

## 10.3 分析
**ClientPod: pods/client-b76dk (10.244.220.1) 向 ServerPod: pods/server-gldfz (10.244.231.2) 发起请求**
```
源MAC   :  ClientPod中eth0网卡的mac
源IP    :  ClientPod中eth0网卡的ip
源Port  :  随机机生成(例如:60646) 

目的MAC :  ee:ee:ee:ee:ee:ee
目的IP  :  ServerPod中eth0网卡的ip
目的Port:  ServerPod中应用的port(例如:80)
 
下一跳  :  到达ClientPod对应所在宿主机上 cali<随机数11位> 网卡
```
<image src="./picture/CrossHost/2.1.Clinet-Pod-Internal-eth0.jpg" style="width: 100%; height: auto;">


**ClientPod所在宿主机上与之对应的 cali<随机数11位> 网卡**
<image src="./picture/CrossHost/2.2.Clinet-Pod-In-Host-cali.jpg" style="width: 100%; height: auto;">
```
源MAC   :  ClientPod中eth0网卡的mac
源IP    :  ClientPod中eth0网卡的ip
源Port  :  随机机生成(例如:60646) 

目的MAC :  ee:ee:ee:ee:ee:ee
目的IP  :  ServerPod中eth0网卡的ip
目的Port:  ServerPod中应用的port(例如:80)

下一跳  :  ClientPod所在宿主机上Route Table 中的 Destination 没有对应 "ServerPod中eth0网卡的ip(10.244.231.2)"。
           交给本机的隧道设备vxlan.calico
```

**ClientPod所在宿主机上的隧道设备vxlan.calico**
<image src="./picture/CrossHost/2.3.Client-Pod-In-Host-vxlan.calico.jpg" style="width: 100%; height: auto;">
```
源MAC   : ClientPod所在宿主机上隧道设备vxlan.calico的mac，做了 源MAC 更改 
源IP    : ClientPod中eth0网卡的ip
源Port  : 随机机生成(例如:60646)

目的MAC : ServerPod所在宿主机上隧道设备vxlan.calcio的mac，做了 目的MAC 更改。 你执行 arp -a 看一下
目的IP  : ServerPod中eth0网卡的ip
目的Port: ServerPod中应用的port(例如:80)

下一跳  : 
```








