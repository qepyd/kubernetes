# 1.相关node的基本信息
```
我使用kubeadm工具部署的kubernetes集群其所有node的基本信息如下所示:
root@master01:~#
root@master01:~# kubectl get nodes -o wide
NAME       STATUS   ROLES           AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master01   Ready    control-plane   2d20h   v1.24.3   172.31.7.201   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   docker://28.1.1
master02   Ready    control-plane   2d20h   v1.24.3   172.31.7.202   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   docker://28.1.1
master03   Ready    control-plane   2d20h   v1.24.3   172.31.7.203   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   docker://28.1.1
node01     Ready    <none>          2d20h   v1.24.3   172.31.7.204   <none>        Ubuntu 20.04.4 LTS   5.4.0-215-generic   docker://28.1.1
node02     Ready    <none>          2d20h   v1.24.3   172.31.7.205   <none>        Ubuntu 20.04.4 LTS   5.4.0-215-generic   docker://28.1.1
node03     Ready    <none>          2d20h   v1.24.3   172.31.7.206   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   docker://28.1.1
root@master01:~#
各master（master01、master02、master03）上安装有worker node相关的组件(container runtime，kubelet、kube-proxy)。
这也是kubeadm工具在部署kubernetes时所要求的。我们在用其它工具安装kubernetes时，也建议这样做(其好处就不展开说了)。
```

# 2.kube-apiserver组件各实例其服务端证书允许的连接地址为
```
## master01上kube-apiserver组件实例其服务端证书允许的连接地址为:
root@master01:~# openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -text | grep -A 1 "X509v3 Subject Alternative Name"  | tail -1 | tr "," "\n"
                DNS:k8s01-kubeapi-comp.qepyd.com   # 我准备的域名，已在我自己公网DNS上解析成了127.0.0.1
 DNS:kubernetes
 DNS:kubernetes.default
 DNS:kubernetes.default.svc
 DNS:kubernetes.default.svc.cluster.local          # k8s集群内部的连接地址(集群内DNS的domain为cluster.local)，kubernetes.default.svc即default名称空间中的svc/kubernetes
 DNS:master01 
 IP Address:10.144.0.1                             # 我的k8s其servie network CIDR为 10.144.0.0/16，此IP是给 ns/default 中其 svc/kubernetes 所占用
 IP Address:172.31.7.201         
 IP Address:172.31.7.110                           # 这是我在部署k8s时,加的vip，被k8s外部lb所用。
 IP Address:172.31.7.120                           # 这是我在部署k8s时,加的vip，被k8s外部lb所用。

## master02上kube-apiserver组件实例其服务端证书允许的连接地址为:
root@master02:~# openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -text | grep -A 1 "X509v3 Subject Alternative Name"  | tail -1 | tr "," "\n"
                DNS:k8s01-kubeapi-comp.qepyd.com
 DNS:kubernetes
 DNS:kubernetes.default
 DNS:kubernetes.default.svc
 DNS:kubernetes.default.svc.cluster.local
 DNS:master02
 IP Address:10.144.0.1
 IP Address:172.31.7.202
 IP Address:172.31.7.110
 IP Address:172.31.7.120

## master03上kube-apiserver组件实例其服务端证书允许的连接地址为:
  root@master03:~# openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -text | grep -A 1 "X509v3 Subject Alternative Name"  | tail -1 | tr "," "\n"
                 DNS:k8s01-kubeapi-comp.qepyd.com
   DNS:kubernetes
   DNS:kubernetes.default
   DNS:kubernetes.default.svc
   DNS:kubernetes.default.svc.cluster.local
 DNS:master03
 IP Address:10.144.0.1
 IP Address:172.31.7.203
 IP Address:172.31.7.110
 IP Address:172.31.7.120
```

# 3.kube-apiserver组件的连接地址有
```
## https://k8s01-kubeapi-comp.qepyd.com:6443
  # <== 基本说明
  其 k8s01-kubeapi-comp.qepyd.com 我在自己互联网DNS上解析成了127.0.0.1。
  kube-apiserver组件各实例的6443端口绑定到了具体的IPv4(172.31.7.201、172.31.7.202、172.31.7.203)。
  各node上有安装nginx作4层代理,代理至kube-apiserver组件各实例。
    root@master01:~# cat /etc/nginx/nginx.conf | grep -A 10000 "^stream"
    stream {
      # apisrevers
      upstream k8s01-apiservers {
        server 172.31.7.201:6443 max_fails=2 fail_timeout=30s;
        server 172.31.7.202:6443 max_fails=2 fail_timeout=30s;
        server 172.31.7.203:6443 max_fails=2 fail_timeout=30s;
      }
      server {
        listen 127.0.0.1:6443;
        proxy_pass k8s01-apiservers;
      }
     }

  # <== 用途
  各node上相关组件作为client去连接kube-apiserver组件实例时的连接地址
  
  # <== 用途展示 
  root@master01:~# grep "server" /etc/kubernetes/scheduler.conf                     # 我有修改 
    server: https://k8s01-kubeapi-comp.qepyd.com:6443
  root@master01:~# 
  root@master01:~# 
  root@master01:~# grep "server" /etc/kubernetes/controller-manager.conf            # 我有修改
    server: https://k8s01-kubeapi-comp.qepyd.com:6443
  root@master01:~# 
  root@master01:~# grep "server" /etc/kubernetes/kubelet.conf                       # 我未修改
    server: https://k8s01-kubeapi-comp.qepyd.com:6443
  root@master01:~# 
  root@master01:~# kubectl -n kube-system get cm/kube-proxy -o yaml | grep server   # 我未修改
        server: https://k8s01-kubeapi-comp.qepyd.com:6443
  root@master01:~# grep "server" $HOME/.kube/config                                 # 来自于 /etc/kubernetes/admin.conf
    server: https://k8s01-kubeapi-comp.qepyd.com:6443
  root@master01:~# 
  root@master01:~# kubectl cluster-info
  Kubernetes control plane is running at https://k8s01-kubeapi-comp.qepyd.com:6443
  CoreDNS is running at https://k8s01-kubeapi-comp.qepyd.com:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
  
  To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

## https://kubernetes.default.svc.cluster.local:443
  用于kubernetes中的Pod连接kube-apiserver组件各实例

## https://172.31.7.110:6443
## https://172.31.7.120:6443
  用于k8s集群外部的client(例如我PC机上的kubectl工具、helm工具)连接时所用
  会经过了k8s外部LB代理至kube-apiserver组件各实例

  root@lb01:~# kubectl cluster-info
  Kubernetes control plane is running at https://172.31.7.110:6443
  CoreDNS is running at https://172.31.7.110:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
  
  To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

# 4.部署有dashboard之kubernetes-dashboard
```
根据 https://github.com/qepyd/kubernetes/tree/main/90.Addons/03.dashboard/kubernetes-dashboard/v2.6.1 所部署
```
