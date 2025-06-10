# 1.k8s集群的相关规划
```
Node网络：172.31.0.0/16
   子网1：172.31.1.0/24
	master01  172.31.1.1/24
	master02  172.31.1.2/24
	master03  172.31.1.3/24
   子网2：172.31.2.0/24
	node01    172.31.2.1/24
	node02    172.31.2.2/24
   子网3：172.31.3.0/24
 	node03    172.31.3.1/24
	node04    172.31.3.2/24

Node网络：10.244.0.0/16
```

# 2.k8s各Worker Node状态
只部署了基本框架，就等着安装CNI插件呢。安装好CNI插件后，其各worker node的状态就是Ready了。
```
roott@deploy:~# kubectl get nodes
NAME       STATUS                     ROLES    AGE   VERSION
master01   NotReady,SchedulingDisabled   master   7d    v1.24.4
master02   NotReady,SchedulingDisabled   master   7d    v1.24.4
master03   NotReady,SchedulingDisabled   master   7d    v1.24.4
node01     NotReady                      node     7d    v1.24.4
node02     NotReady                      node     7d    v1.24.4
node03     NotReady                      node     7d    v1.24.4
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

# 5.各worker node上的设备
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

# 6.相关worker node上的route
```
## 子网2


## 子网3


```

