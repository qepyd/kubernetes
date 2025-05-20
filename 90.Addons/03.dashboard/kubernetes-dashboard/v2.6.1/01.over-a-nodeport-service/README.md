# 1.我的kubernetes
```
## 我的k8s是使用kubeadm工具部署的,相关node的基本信息如下所示
root@master01:~# kubectl get nodes  -o wide
NAME       STATUS   ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master01   Ready    control-plane   39h   v1.24.3   172.31.7.201   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   docker://28.1.1
master02   Ready    control-plane   39h   v1.24.3   172.31.7.202   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   docker://28.1.1
master03   Ready    control-plane   39h   v1.24.3   172.31.7.203   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   docker://28.1.1
node01     Ready    <none>          38h   v1.24.3   172.31.7.204   <none>        Ubuntu 20.04.4 LTS   5.4.0-215-generic   docker://28.1.1
node02     Ready    <none>          38h   v1.24.3   172.31.7.205   <none>        Ubuntu 20.04.4 LTS   5.4.0-215-generic   docker://28.1.1
node03     Ready    <none>          38h   v1.24.3   172.31.7.206   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   docker://28.1.1

## kube-apiserver组件各实例其服务端证书中允许了 172.31.7.110   172.31.7.120 这两个vip
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -text  | grep -A 1 "X509v3 Subject Alternative Name"

## k8s各node上相关组件实例/工具作为client访问kube-apiserver时的连接地址 
root@master01:~# kubectl cluster-info
Kubernetes control plane is running at https://k8s01-kubeapi-comp.qepyd.com:6443
CoreDNS is running at https://k8s01-kubeapi-comp.qepyd.com:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

## kubenetes外部lb使用的nginx
其 172.31.7.200/16 这台主机上使用辅助IP来模拟的VIP
root@lb01:~# ip addr show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:a9:1f:ea brd ff:ff:ff:ff:ff:ff
    inet 172.31.7.200/16 brd 172.31.255.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet 172.31.7.110/16 brd 172.31.255.255 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet 172.31.7.120/16 brd 172.31.255.255 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fea9:1fea/64 scope link 
       valid_lft forever preferred_lft forever

其 配置的 4 层代理
root@lb01:~# cat /etc/nginx/nginx.conf | grep  -A 10000 "^stream"
stream {
    # apisrevers
    upstream k8s01-apiservers {
        server 172.31.7.201:6443 max_fails=2 fail_timeout=30s;
        server 172.31.7.202:6443 max_fails=2 fail_timeout=30s;
        server 172.31.7.203:6443 max_fails=2 fail_timeout=30s;
    }
    server {
        listen 6443;
        proxy_pass k8s01-apiservers;
    }
}

非k8s各node上相关工具作为client访问kube-apiserver时的连接地址
root@lb01:~# kubectl cluster-info
Kubernetes control plane is running at https://172.31.7.110:6443
CoreDNS is running at https://172.31.7.110:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

# 2.下载相应的manifests
```
## 来源地
https://github.com/kubernetes/dashboard/releases/tag/v2.6.1

## 下载manifests
wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml
```

# 3.相关manifests的基本修改
```
## 所用namespace
root@master01:/qepyd/kubernetes/90.Addons/03.dashboard/kubernetes-dashboard/v2.6.1# grep "namespace" recommended.yaml  | sort  | uniq
            - --namespace=kubernetes-dashboard
    namespace: kubernetes-dashboard
  namespace: kubernetes-dashboard

## 是否包含ns/kubernetes-dashboard的manifests,结果是包含的
root@master01:/qepyd/kubernetes/90.Addons/03.dashboard/kubernetes-dashboard/v2.6.1# grep -A 3 "^kind: Namespace" recommended.yaml 
kind: Namespace
metadata:
  name: kubernetes-dashboard

## 所用到的image
root@master01:/qepyd/kubernetes/90.Addons/03.dashboard/kubernetes-dashboard/v2.6.1# grep image: recommended.yaml 
          image: kubernetesui/dashboard:v2.6.1
          image: kubernetesui/metrics-scraper:v1.0.8
root@master01:/qepyd/kubernetes/90.Addons/03.dashboard/kubernetes-dashboard/v2.6.1# grep kubernetesui recommended.yaml 
          image: kubernetesui/dashboard:v2.6.1
          image: kubernetesui/metrics-scraper:v1.0.8

## pull image-->tag image -->push image至自己的私有仓库
............我已将其push到我自己的私有仓库(公开,国内互联网可访问)
swr.cn-north-1.myhuaweicloud.com/qepyd/dashboard:v2.6.1
swr.cn-north-1.myhuaweicloud.com/qepyd/metrics-scraper:v1.0.8

## 修改manifests中的镜像
sed    's#kubernetesui/dashboard:v2.6.1#swr.cn-north-1.myhuaweicloud.com/qepyd/dashboard:v2.6.1#g'  recommended.yaml | grep image:
sed -i 's#kubernetesui/dashboard:v2.6.1#swr.cn-north-1.myhuaweicloud.com/qepyd/dashboard:v2.6.1#g'  recommended.yaml

sed    's#kubernetesui/metrics-scraper:v1.0.8#swr.cn-north-1.myhuaweicloud.com/qepyd/metrics-scraper:v1.0.8#g' recommended.yaml | grep image:
sed -i 's#kubernetesui/metrics-scraper:v1.0.8#swr.cn-north-1.myhuaweicloud.com/qepyd/metrics-scraper:v1.0.8#g' recommended.yaml
```

# 4.相关manifests的按需修改
```
## 我想让deploy/kubernetes-dashboard只能被调度至各master(当然得安装有worker node的相关组件,否则不要操作)
A:修改deploy/kubernetes-dashboard的manifests(让其能够容忍master上其NoSchedule效果的所有污点)
  默认容忍的是 node-role.kubernetes.io/master  NoSchedule 污点，即deploy.spec.template.spec.tolerations字段
      tolerations:
        - key: node-role.kubernetes.io/master
          effect: NoSchedule
Ac:将其修改成容忍各master上的上NoSchedule效果的相关污点(我的各master上有如下两个污点)
      tolerations:
        - key: node-role.kubernetes.io/control-plane
          effect: NoSchedule
        - key: node-role.kubernetes.io/master
          effect: NoSchedule

B: 修改deploy/kubernetes-dashboard的manifests(让能只能够被调度至各master上，当然你的各master得有安装worker node组件,否则不要操作)
   默认使用nodeSelector匹配"kubernetes.io/os": linux标签。
      nodeSelector:
        "kubernetes.io/os": linux
Bc:将其nodeSelector给注释掉，使用节点亲和之硬亲和方式
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: node-role.kubernetes.io/control-plane
                operator: Exists

## 我想让deploy/dashboard-metrics-scraper只能被调度至各master(当然得安装有worker node的相关组件,否则不要操作)
.............参考 deploy/kubernetes-dashboard其manifests的修改


## 我想让其以NodePort方式暴露出kubernetes,其nodePort规划占用30000，跟上述的修改没有关系。
修改svc/kubernetes-dashboard对象，默认为ClusterIP类型。修改后的整体展示如下
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  # 修改成NodePort类型
  type: NodePort
  ports:
    - port: 443
      targetPort: 8443
      # 与NodePort类型配套,规划占用30000
      nodePort: 30000
  selector:
    k8s-app: kubernetes-dashboard
```

# 5.应用manifests并检查
```
## 应用manifests
kubectl apply -f recommended.yaml --dry-run=client
kubectl apply -f recommended.yaml 

## 列出相平面资源对象
kubectl get -f recommended.yaml
```

# 6.访问测试一下
```
## 访问地址
https://172.31.7.201:30000
https://任何一个node的NodeIP:30000

## 使用现有kubeconfig(/etc/kubernetes/admin.conf)去登录
会报错：Internal error (500): Not enough data to create auth info structure.
因  为：因为这个kubeconfig文件中其帐户非"服务帐户"，即k8s中没有,它是在client证书中承载的
```

# 7.创建相关sa帐户、创建角色、角色绑定、制定kubeconfig
```
参考 ./create-sa-test-login/ 目录下的
```

# 8.k8s外部lb配置7层代理
```
参考./k8s-external-lb-expose目录
```

