==============kubeadm工具在ubuntu20.04平台部署kubernetes v1.24.4,容器运行时使用containerd==============

# 1.kubernetes的相关规划及准备相应环境
## 1.1 我的需求
**我的需求**
```
使用kubeadm工具部署k8s基本框架
   etcd
   kube-apiserver、kube-scheduler、kube-controller-manager
   kubelet、kube-proxy。
   实现控制平面(master)高可用。
   不用部署kubeadm安装任何的Addons

使用kubeadm工具部署k8s学习环境
   人为安装一些基本的Addons(cni、dns)
```

**我们来看一看kubeadm工具在初始时有哪些阶段**  
我后面在初始化时就会把addon阶段的coredns(dns addons的一种)忽略。  
以下信息可在安装有kubeadm工具的服务器上通过 kubeadm init --help 看到。
```
preflight                    Run pre-flight checks
certs                        Certificate generation
  /ca                          Generate the self-signed Kubernetes CA to provision identities for other Kubernetes components
  /apiserver                   Generate the certificate for serving the Kubernetes API
  /apiserver-kubelet-client    Generate the certificate for the API server to connect to kubelet
  /front-proxy-ca              Generate the self-signed CA to provision identities for front proxy
  /front-proxy-client          Generate the certificate for the front proxy client
  /etcd-ca                     Generate the self-signed CA to provision identities for etcd
  /etcd-server                 Generate the certificate for serving etcd
  /etcd-peer                   Generate the certificate for etcd nodes to communicate with each other
  /etcd-healthcheck-client     Generate the certificate for liveness probes to healthcheck etcd
  /apiserver-etcd-client       Generate the certificate the apiserver uses to access etcd
  /sa                          Generate a private key for signing service account tokens along with its public key
kubeconfig                   Generate all kubeconfig files necessary to establish the control plane and the admin kubeconfig file
  /admin                       Generate a kubeconfig file for the admin to use and for kubeadm itself
  /kubelet                     Generate a kubeconfig file for the kubelet to use *only* for cluster bootstrapping purposes
  /controller-manager          Generate a kubeconfig file for the controller manager to use
  /scheduler                   Generate a kubeconfig file for the scheduler to use
kubelet-start                Write kubelet settings and (re)start the kubelet
control-plane                Generate all static Pod manifest files necessary to establish the control plane
  /apiserver                   Generates the kube-apiserver static Pod manifest
  /controller-manager          Generates the kube-controller-manager static Pod manifest
  /scheduler                   Generates the kube-scheduler static Pod manifest
etcd                         Generate static Pod manifest file for local etcd
  /local                       Generate the static Pod manifest file for a local, single-node local etcd instance
upload-config                Upload the kubeadm and kubelet configuration to a ConfigMap
  /kubeadm                     Upload the kubeadm ClusterConfiguration to a ConfigMap
  /kubelet                     Upload the kubelet component config to a ConfigMap
upload-certs                 Upload certificates to kubeadm-certs
mark-control-plane           Mark a node as a control-plane
bootstrap-token              Generates bootstrap tokens used to join a node to a cluster
kubelet-finalize             Updates settings relevant to the kubelet after TLS bootstrap
  /experimental-cert-rotation  Enable kubelet client certificate rotation
addon                        Install required addons for passing conformance tests
  /coredns                     Install the CoreDNS addon to a Kubernetes cluster
  /kube-proxy                  Install the kube-proxy addon to a Kubernetes cluster
```


## 1.2 kubernetes基本规划
**kubernetes基本规划**
```
kubernetes版本：
   v1.24.4

容器运行时品牌及版本:
   https://github.com/containerd/containerd/blob/v1.7.27/RELEASES.md#kubernetes-support
   containerd v1.7.27

Nod网络：
   类型：Underlay
   CIDR：172.31.0.0/16

Pod网络：
   类型：Overlay
   CIDR：10.0.0.0/8

Svc网络：
   类型：Overlay
   CIDR：11.0.0.0/12(网络地址得>=12)

集群内DNS的Domain:
   cluster.local

集群内DNS应用(Pod)其svc资源对象的ClusterIP
   来自Svc网络,不能使用第一个可用IP(被ns/default中的svc/kubernetes所占用)
   规划地址为：11.0.0.2
```

**部署工具(kubeadm)**
```
kubeadm版本:
  v1.24.4
  得和所要部署的kubernetes版本保持一致

kubeadm介绍
  kubernetes官方的部署工具。
  不会给你优化服务器的操作系统。
  可以部署etcd集群
     非高可用集群
     高可用的集群
  可以部署kubernetes集群
     非高可用集群
     高可用的集群
  至于Addons
     只会安装Addons之dns(coredns),
     但因为不会安装CNI网络插件,所以dns(coredns)的Pod处于Pending状态
```

**人为安装一些Addons**  
Addons有很多，这里因为是学习环境，只会部署学习所需要的。
```
CNI：
  Flannel  vxlan

container-resource-monitoring：
  metrics-server
```

## 1.3 所准备的相关服务器
所准备的服务器得要能够访问互联网(公网IP,FQDN)。
```
操作系统     主机名   业务网卡  业务网卡IP   
ubuntu20.04  lb01     eth0      172.31.7.201
ubuntu20.04  lb02     eth0      172.31.7.202
   #
   # vip01: 172.31.7.199
   # vip02: 172.31.7.200
   # 注意：在为kube-apiserver组件实例签发server证书时得包含这两个IP地址。
   # 作为kubernetes其kube-apiserver组件实例的外部代理(L4)。
   # 例如：集群管理员使用kubectl工具连接连接kube-apiserver。
   # 例如：集群外部的应用(jenkins)中的任务使用kubectl工具来连接kbue-apiserver
   # 

ubuntu20.04  master01 eth0      172.31.7.203
ubuntu20.04  master02 eth0      172.31.7.204
ubuntu20.04  master03 eth0      172.31.7.205
   #
   # 得安装部署工具
   #   kubeadm
   # 得安装k8s其worker node相关组件
   #   容器运行时之containerd
   #   kubelet(以守护进程方式部署)
   #   kube-proxy(部署工具kubeadm会用Pod控制器之Daemonset来编排Pod,并以交付到k8s中)
   # 部署工具会安装k8s master相关组件
   #   etcd：以静态Pod方式运行
   #   kube-apiserver：以静态Pod方式运行
   #   kube-scheduler：以静态Pod方式运行
   #   kube-controller-manager: 以静态Pod方式运行
   # 

ubuntu20.04  node01   eth0      172.31.7.206
ubuntu20.04  node02   eth0      172.31.7.207
   #
   # 得安装部署工具
   #   kubeadm
   # 得安装k8s worker node相关组件
   #   kubelet(以守护进程方式部署)
   #   kube-proxy(部署工具kubeadm会以Pod方式交付到k8s中)
   #   kube-proxy(部署工具kubeadm会用Pod控制器之Daemonset来编排Pod,并以交付到k8s中)
   #
```



## 1.4 所准备服务器的优化
### 1.4.1 修改主机名
请参考"1.2 所准备的相关服务器"中的信息进行设置，设置命令为:
```
hostnamectl set-hostname <主机名>
```

### 1.4.2 停止ufw防火墙
```
systemctl stop ufw.service
systemctl disable ufw.service
```

### 1.4.3 选择默认的编辑器为vim
```
echo 'export EDITOR=/usr/bin/vi' >>/etc/profile
source /etc/profile
```

### 1.4.4 解决apt安装软件时让其交互式设置
```
echo "export DEBIAN_FRONTEND=noninteractive" >>/etc/profile
source /etc/profile
```

### 1.4.5 停止自动更新软件包
```
systemctl stop unattended-upgrades.service 
systemctl disable unattended-upgrades.service 
```

### 1.4.6 确保/etc/resolv.conf文件不被systemd-resolved.service重启后覆盖
/etc/resolv.conf是个软链接文件，指向的是/run/systemd/resolve/stub-resolv.conf文件。  
当systemd-resolved.service应用一但重启，会重新生成内容到/run/systemd/resolve/stub-resolv.conf文件中。
另外：当服务器的网卡未公网/私网DNS服务器，那么是无法Ping通FQDN(公网、私网)的。

```
## 删除软链接文件/etc/resolv.conf 
find /etc/ -maxdepth 1 -type l  -name "resolv.conf" 
find /etc/ -maxdepth 1 -type l  -name "resolv.conf" | xargs rm -f

## 创建/etc/resolv.conf文件,并指定DNS服务器(阿里云)
cat >/etc/resolv.conf<<'EOF'
nameserver 223.5.5.5
nameserver 223.6.6.6
EOF

## 其 systemd-resolved.service 应用可停可不停， 其停止的命令为
systemctl stop systemd-resolved.service
systemctl disable systemd-resolved.service
```

### 1.4.7 更改apt源为阿里云的 
```
#### 更新apt源为阿里云
cat >/etc/apt/sources.list<<'EOF'
deb https://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse

# deb https://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
EOF

#### 更新
apt-get update
```


### 1.4.8 开启crond的日志
```
cat >>/etc/rsyslog.d/50-default.conf<<"EOF"
cron.*   /var/log/cron.log
EOF

systemctl restart cron.service
systemctl restart rsyslog.service
```

### 1.4.9 定时更新系统操作时间
修改时区为CST，以及时间为24小时帛
```
## 安装软件
apt update
apt-get install -y tzdata

## 修改时区为CST,其实默认下/etc/localtime是/usr/share/zoneinfo/Etc/UTC文件的软链接
ln -svf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime

## 修改时间为24小时,该操作后,退出当前连接,重新连接后就会生效
echo "LC_TIME=en_DK.UTF-8" >>/etc/default/locale
```

定时更新系统时间
```
## 创建相关的目录
mkdir -p /opt/scripts/
ls -ld /opt/scripts

## 编写脚本
cd /opt/scripts/

cat >update_os_time.sh<<'EOF'
#!/bin/bash
#
# Define variables
RETVAL=0
Ntp_server=(
ntp.aliyun.com
ntp1.aliyun.com
ntp2.aliyun.com
ntp3.aliyun.com
ntp4.aliyun.com
ntp5.aliyun.com
ntp6.aliyun.com
ntp7.aliyun.com
)
 
# Determine the user to execute
if [ $UID -ne $RETVAL ];then
   echo "Must be root to run scripts"
   exit 1
fi
 
# Install ntpdate command
apt-get install ntpdate -y >/dev/null 2>&1
 
# for loop update os time
for((i=0;i<${#Ntp_server[*]};i++))
do
    /usr/sbin/ntpdate ${Ntp_server[i]} >/dev/null 2>&1 &
    RETVAL=$?
    if [ $RETVAL -eq 0 ];then
       echo "Update os time success"
       break
      else
       echo "Update os time fail"
       continue
    fi  
done
 
# Scripts return values
exit $RTVAL
EOF

## 添加定时任务
cat >>/var/spool/cron/crontabs/root<<EOF

## crond update os time
*/05 * * * * /bin/bash  /opt/scripts/update_os_time.sh >/dev/null 2>&1
EOF

## 检查
crontab -u root -l
```


### 1.4.10 开启ipvs支持
```
#### 安装ipvs
apt update
chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow
apt -y install ipvsadm ipset sysstat conntrack

#### 临时生效
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
# modprobe -- nf_conntrack_ipv4
modprobe -- nf_conntrack
lsmod | grep ip_vs

   注意：如果出现modprobe: FATAL: Module nf_conntrack_ipv4 not found in directory 
   /lib/modules/5.15.0-69-generic错误，这是因为使用了高内核，当前内核版本为5.15.0-69-
   generic，在高版本内核已经把nf_conntrack_ipv4替换为nf_conntrack了。

##### 让其永久生效   
cat > /etc/profile.d/ipvs.modules.sh <<"EOF"
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack
EOF

chmod 755 /etc/profile.d/ipvs.modules.sh
bash /etc/profile.d/ipvs.modules.sh
lsmod | grep -e ip_vs -e nf_conntrack_ipv4
```


### 1.4.11 加载br_netfilter模块并设置内核参数
安装工具并临时加载br_netfilter模块
```
chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow
apt-get install bridge-utils
modprobe br_netfilter
```
永久加载模块
```
cat > /etc/profile.d/br_netfilter.sh <<'EOF'
#!/bin/bash
modprobe br_netfilter
EOF

chmod 755 /etc/profile.d/br_netfilter.sh
bash /etc/profile.d/br_netfilter.sh
```

设置内核参数
```
chattr -i /etc/sysctl.conf

cat >>/etc/sysctl.conf<<'EOF'
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl -p
```


### 1.4.12 开启内核网络转发
```
chattr -i /etc/sysctl.conf

cat >>/etc/sysctl.conf<<'EOF'
net.ipv4.ip_forward=1
EOF

sysctl -p
```

### 1.4.13 关闭交换分区
```
#### 设置vm.swappiness=0
chattr -i /etc/sysctl.conf
echo "vm.swappiness=0" >>/etc/sysctl.conf
sysctl -p 

#### 关闭swap
chattr -i /etc/fstab
swapoff -a
sed    '/swap/'d /etc/fstab
sed -i '/swap/'d /etc/fstab
```

### 1.4.14 重启服务器
```
reboot
```


## 1.5 相关软件的安装(不操作,后面来引用)
### 1.5.1 安装部署工具kubeadm及k8s组件kubelet
**更改apt源**
```
apt-get update && apt-get install -y apt-transport-https

curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add - 

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF

apt-get update
```
**查看是否有kubeadm、kubelet相关的版本**
```
apt-cache madison kubeadm   | grep 1.24.4
apt-cache madison kubelet   | grep 1.24.4
```

**安装kubeadm、kubelet相应的版本**
```
## 安装
chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow
apt-get update
apt install -y  --allow-downgrades  kubeadm=1.24.4-00  kubelet=1.24.4-00  kubectl=1.24.4-00
   #
   # 其kubeadm、kubelet、kubectl要一起安装,因为要保持版本一致。
   # 会额外安装：
   #  cri-tools
   #  ebtables
   #  kubernetes-cni
   #  socat
   # 

## 检查
which  kubeadm  kubectl crictl  kubelet  
kubeadm version
kubectl version
kubelet --version
crictl  --version

## kubelet启动是会失败的(正常)
systemctl status kubelet.service  # 未正常启动,是正常的
systemctl enable kubelet.service  # 加入开机自启动
```

**查看会用到哪些image**
```
root@master01:~# kubeadm config images list   --kubernetes-version=v1.24.4
k8s.gcr.io/kube-apiserver:v1.24.4
k8s.gcr.io/kube-controller-manager:v1.24.4
k8s.gcr.io/kube-scheduler:v1.24.4
k8s.gcr.io/kube-proxy:v1.24.4
k8s.gcr.io/pause:3.7
k8s.gcr.io/etcd:3.5.3-0
k8s.gcr.io/coredns/coredns:v1.8.6
```

**查看国内的云服务商是否有提供**
```
root@master01:~# kubeadm config images list  --kubernetes-version=v1.24.4  --image-repository=registry.aliyuncs.com/google_containers
registry.aliyuncs.com/google_containers/kube-apiserver:v1.24.4
registry.aliyuncs.com/google_containers/kube-controller-manager:v1.24.4
registry.aliyuncs.com/google_containers/kube-scheduler:v1.24.4
registry.aliyuncs.com/google_containers/kube-proxy:v1.24.4
registry.aliyuncs.com/google_containers/pause:3.7
registry.aliyuncs.com/google_containers/etcd:3.5.3-0
registry.aliyuncs.com/google_containers/coredns:v1.8.6
  #
  # 你可以把这些镜像pull-->tag--->push到自己的镜像仓库中
  # 我这里没有这样做,因为我们是安装kubernetes的学习环境
  # 
```

### 1.5.2 安装容器运行时containerd
**安装runc**
```
wget https://github.com/opencontainers/runc/releases/download/v1.1.12/runc.amd64
ls -l  runc.amd64
mv runc.amd64  runc
chmod +x  runc
mv  runc  /usr/local/sbin/
which runc
runc -v
```

**安装containerd**
```
wget https://github.com/containerd/containerd/releases/download/v1.7.27/containerd-1.7.27-linux-amd64.tar.gz
ls -l  containerd-1.7.27-linux-amd64.tar.gz
tar xf containerd-1.7.27-linux-amd64.tar.gz
cp -a bin/*  /usr/local/bin/                     # 后面systemd的service文件中其containerd命令的路径
which containerd containerd-shim ctr
```

**配置containerd**
```
## 生成默认配置文件
mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
cat  /etc/containerd/config.toml

## 修改sandbox_image
# <== 查看
root@master01:~# grep "sandbox_image" /etc/containerd/config.toml 
    sandbox_image = "registry.k8s.io/pause:3.8"

# <== 修改
sed    's#registry.k8s.io/pause:3.8#registry.aliyuncs.com/google_containers/pause:3.7#g' /etc/containerd/config.toml | grep "sandbox_image"
sed -i 's#registry.k8s.io/pause:3.8#registry.aliyuncs.com/google_containers/pause:3.7#g' /etc/containerd/config.toml

## 开启SystemdCgroup
# <== 查看
root@master01:~# grep SystemdCgroup /etc/containerd/config.toml 
            SystemdCgroup = false

# <== 修改
sed    's#SystemdCgroup = false#SystemdCgroup = true#g'  /etc/containerd/config.toml | grep SystemdCgroup
sed -i 's#SystemdCgroup = false#SystemdCgroup = true#g'  /etc/containerd/config.toml
```


**准备相关的containerd.service文件**
```
cat >/lib/systemd/system/containerd.service<<'EOF'
# Copyright The containerd Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/containerd

Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
EOF
```

**启动containerd**
```
## 重新加载
systemctl daemon-reload
systemctl enable --now containerd

## 加入开机自启动
systemctl start containerd.service
systemctl status containerd.service
systemctl enable containerd.service
systemctl is-enabled containerd.service
```

**安装客户端工具nerdctl**
```
wget https://github.com/containerd/nerdctl/releases/download/v1.7.6/nerdctl-1.7.6-linux-amd64.tar.gz
tar xf nerdctl-1.7.6-linux-amd64.tar.gz  -C /usr/local/bin/
which nerdctl
```

**nerdctl查看一下info**
```
nerdctl info
```

**nerdctl拉取一下镜像**
```
nerdctl image pull  --namespace=k8s.io   registry.aliyuncs.com/google_containers/pause:3.7
nerdctl image ls    --namespace=k8s.io
nerdctl image rm    --namespace=k8s.io   registry.aliyuncs.com/google_containers/pause:3.7
```

### 1.5.3 配置crictl连接containerd
创建/etc/crictl.yaml文件并配置
```
cat >/etc/crictl.yaml<<'EOF'
runtime-endpoint: unix:///run/containerd/containerd.sock
EOF
``` 
crictl工具测试拉取镜像
```
crictl pull registry.aliyuncs.com/google_containers/pause:3.7
crictl image
```
<br>
<br>


# 2.kubernetes控制平面高可用的部署
## 2.1 安装部署工具kubeadm及k8s组件kubelet
master01、master02、master03上操作。  
参考 "1.5.1 安装部署工具kubeadm及k8s组件kubelet"。

## 2.2 安装容器运行时containerd
master01、master02、master03上操作。  
参考 "1.5.2 安装容器运行时containerd"

## 2.3 配置crictl连接containerd
master01、master02、master03上操作。  
参考 "1.5.3 配置crictl连接containerd"

## 2.4 拉起控制平面(master01上操作)
### 2.4.1 先下载好镜像
```
## 下载镜像
kubeadm config images pull \
  --image-repository=registry.aliyuncs.com/google_containers \
  --kubernetes-version=v1.24.4

## 列出镜像
crictl image
```

### 2.4.2 生成配置文件
创建kubeadm-config.yaml文件,内容如下所示
```
--- 
#### 参考
# https://kubernetes.io/zh-cn/docs/reference/config-api/kubeadm-config.v1beta3/#kubeadm-k8s-io-v1beta3-InitConfiguration
#
#### 初始化配置
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
# 当前kube-apiserver的端点
localAPIEndpoint:
  advertiseAddress: 172.31.7.203
  bindPort: 6443
# 节点登记
nodeRegistration:
  name: master01
  criSocket: unix:///run/containerd/containerd.sock
  imagePullPolicy: IfNotPresent
  taints: 
  - effect: NoSchedule
    key: node-role.kubernetes.io/control-plane
# 注意：跳过的阶段(根据我的需求我路过addon阶段之coredns的安装)
# 可用kubeadm inist --help看一看
skipPhases:
  - addon/coredns


---
#### 参考
# https://kubernetes.io/zh-cn/docs/reference/config-api/kubeadm-config.v1beta3/#kubeadm-k8s-io-v1beta3-ClusterConfiguration
#
#### 集群配置
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
# 设置用来拉取镜像的容器仓库,如果此字段为空,默认使用 registry.k8s.io
imageRepository: registry.aliyuncs.com/google_containers
# 设置在何处存放或者查找所需证书
certificatesDir: /etc/kubernetes/pki
# ETCD的配置
etcd:
  local:
    dataDir: /var/lib/etcd
# K8s版本
kubernetesVersion: v1.24.4
# K8s集群的版本和名称
clusterName: kubernetes
# 网络的配置
networking:
  podSubnet: 10.0.0.0/8
  serviceSubnet: 11.0.0.0/12
  dnsDomain: cluster.local
# kube-apiserver相关的配置
controlPlaneEndpoint: "k8s01-component-connection-kubeapi.local.io:6443"
apiServer:
  extraArgs:
    authorization-mode: "Node,RBAC"
    bind-address: "0.0.0.0"
  certSANs:
  - "127.0.0.1"
  - "172.31.7.199"
  - "172.31.7.200"
  timeoutForControlPlane: 6m0s
# controller-manager相关的配置
controllerManager:
  extraArgs:
    "node-cidr-mask-size": "24"
    "bind-address": "0.0.0.0"
# scheduler相关的配置
scheduler: 
  extraArgs:
    bind-address: "0.0.0.0"


---
#### 参考
# https://kubernetes.io/zh-cn/docs/reference/config-api/kubelet-config.v1beta1/#kubelet-config-k8s-io-v1beta1-KubeletConfiguration
# 
#### kubelet的相关配置
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
# 来自于Svc网络,给集群内DNS应用(Pod)其svc资源对象所规划的ClusterIP
clusterDNS: 
 - "11.0.0.2"
# k8s集群内DNS的的Domain
clusterDomain: "cluster.local"
# 设置cgroup的驱动为systemd,默认为cgroupfs
cgroupDriver: "systemd"
# 设置各woker node上的最大Pod数,默认为110
maxPods: 110


---
#### 参考
# https://kubernetes.io/zh-cn/docs/reference/config-api/kube-proxy-config.v1alpha1/#kubeproxy-config-k8s-io-v1alpha1-KubeProxyConfiguration
#
#### kube-proxy的配置,InitConfiguration处我可没有跳过kubeadm所认为addons之kube-proxy
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
# 用于配置kube-proxy上为Service指定的代理模式，默认为iptables；
mode: "ipvs"
```

### 2.4.3 初始化控制平面
**利用/etc/hosts做dns解析(127.0.0.1 k8s01-component-connection-kubeapi.local.io)**  
01:前面为初始化准备的配置文件中具备 k8s01-component-connection-kubeapi.local.io 域名。  
02:kube-apiserver组件的client之kube-controller-manager、kube-scheduler的kubeconfig文件中其连接地址为 https://本机IPv4:6443  
03:kube-apiserver组件的client之kubelet、kubectl的kubeconfig文件中其连接地址为 https://k8s01-component-connection-kubeapi.local.io:6443  
```
cat >>/etc/hosts<<'EOF'
127.0.0.1   k8s01-component-connection-kubeapi.local.io
EOF
```

**初始化**
```
## 试运行一下
kubeadm init --config  kubeadm-config.yaml  --upload-certs   --dry-run

## 初始化
kubeadm init --config  kubeadm-config.yaml  --upload-certs
```

**试运行和初始化成功结果如下所示**
```
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of the control-plane node running the following command on each as root:

  kubeadm join k8s01-component-connection-kubeapi.local.io:6443 --token 72ymcq.i8h829hx1gu0mjr6 \
	--discovery-token-ca-cert-hash sha256:d2fbc05087d171d064d701749ea934473a18c2ad73574707a1675dfc23280788 \
	--control-plane --certificate-key 15a7e1d492ab18af19f90696cc587bf8d1752bee1897e11b842ec0c588897bf4

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join k8s01-component-connection-kubeapi.local.io:6443 --token 72ymcq.i8h829hx1gu0mjr6 \
	--discovery-token-ca-cert-hash sha256:d2fbc05087d171d064d701749ea934473a18c2ad73574707a1675dfc23280788 

```

**创建目录,并复制kubectl所要用到的kubeconfig**
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

**列出k8s中所有的nodes资源对象**
```
root@master01:~# kubectl get nodes
NAME       STATUS     ROLES           AGE     VERSION
master01   NotReady   control-plane   5m28s   v1.24.4
  #
  #
  # 可用 kubectl describe ndoes/master01 看到
  #   NetworkReady=false reason:NetworkPluginNotReady message:Network plugin returns error: cni plugin not initialized
  #
```

**列出k8s中所有的Pod**  
01:没有coredns相关的Pod,因为我在安装时忽略了addon阶段其/coredns。  
02:这些Pod是在ns/kube-system中，kube-system名称空间是kubernetes中默认名称空间。  
03:kube-proxy是用Pod控制器之DaemonSet控制器所编排的,共享了所在宿主机(worker node)的网络名称空间。  
04:etcd、kube-apiserver、kube-controller-manager、kube-scheduler以静态Pod方式部署，共享所在宿主机(worker node)网络名称空间。  
```
root@master01:~# kubectl get pods -o wide -A
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE     IP             NODE       NOMINATED NODE   READINESS GATES
kube-system   etcd-master01                      1/1     Running   1          10m     172.31.7.203   master01   <none>           <none>
kube-system   kube-apiserver-master01            1/1     Running   0          10m     172.31.7.203   master01   <none>           <none>
kube-system   kube-controller-manager-master01   1/1     Running   1          10m     172.31.7.203   master01   <none>           <none>
kube-system   kube-proxy-gdhkw                   1/1     Running   0          9m52s   172.31.7.203   master01   <none>           <none>
kube-system   kube-scheduler-master01            1/1     Running   0          10m     172.31.7.203   master01   <none>           <none>
```

**crictl列出有哪些容器**
```
root@master01:~# crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                      ATTEMPT             POD ID              POD
8349d746025ba       7a53d1e08ef58       2 minutes ago       Running             kube-proxy                0                   7a91783b77e0f       kube-proxy-m8tbz
20c0eedcbc26d       aebe758cef4cd       2 minutes ago       Running             etcd                      0                   b6ee0b5a6da54       etcd-master01
72a80eea8b286       6cab9d1bed1be       2 minutes ago       Running             kube-apiserver            0                   d9a8d045c6a24       kube-apiserver-master01
ca932b06ec3f7       03fa22539fc1c       2 minutes ago       Running             kube-scheduler            0                   4fb8b69bf56f6       kube-scheduler-master01
80c4a50412137       1f99cb6da9a82       2 minutes ago       Running             kube-controller-manager   0                   24061ebb2fcce       kube-controller-manager-master01
```

## 2.5 实现其现在控制平面的高可用
### 2.5.1 master01上操作,生成certificate-key和token
**准备clusterconfiguration**   
生成解密集群证书的唯一密钥
```
## 生成相应的manifests
cat >/tmp/kubeadm_clusterconfiguration.yaml<<'EOF'
##### 以下内容来自 ns/kube-system 中 
#     其 cm/kubeadm-config对象data字段
#     ClusterConfiguration 键的值
apiServer:
  certSANs:
  - 127.0.0.1
  - 172.31.7.199
  - 172.31.7.200
  extraArgs:
    authorization-mode: Node,RBAC
    bind-address: 0.0.0.0
  timeoutForControlPlane: 6m0s
apiVersion: kubeadm.k8s.io/v1beta3
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controlPlaneEndpoint: k8s01-component-connection-kubeapi.local.io:6443
controllerManager:
  extraArgs:
    bind-address: 0.0.0.0
    node-cidr-mask-size: "24"
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: registry.aliyuncs.com/google_containers
kind: ClusterConfiguration
kubernetesVersion: v1.24.4
networking:
  dnsDomain: cluster.local
  podSubnet: 10.0.0.0/8
  serviceSubnet: 11.0.0.0/12
scheduler:
  extraArgs:
    bind-address: 0.0.0.0
EOF
```

**生成解密集群证书的唯一密钥**
```
root@master01:~# kubeadm init phase upload-certs --upload-certs --config  /tmp/kubeadm_clusterconfiguration.yaml
[upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[upload-certs] Using certificate key:
302120bc9d7d4da653e2a1a48c6b79b177f0b547e1340b68ee71a0b665221855
```

**生成worker node加入控制平面的token**
```
## 生成token
root@master01:~# kubeadm token create --print-join-command 
kubeadm join k8s01-component-connection-kubeapi.local.io:6443 --token fbbhis.b0kszqvvr5t1sh82 --discovery-token-ca-cert-hash sha256:28d12b7d0a29a7276305d6250d809e0dd8d6caf4851547aef566c2137d43af90 

## 其 --discovery-token-ca-cert-hash 的值可从 k8s 集群 的 ca 证书中获取到 
root@master01:~# openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex
(stdin)= 28d12b7d0a29a7276305d6250d809e0dd8d6caf4851547aef566c2137d43af90

## 其 --token 的相关信息可从相关secrets中看到
# <== 查看其所保存的位置 
root@master01:~# kubectl -n kube-system get secrets bootstrap-token-fbbhis
NAME                     TYPE                            DATA   AGE
bootstrap-token-fbbhis   bootstrap.kubernetes.io/token   6      7m47s

# <== 查看其在内容
root@master01:~# kubectl -n kube-system get secrets bootstrap-token-fbbhis -o yaml
apiVersion: v1
data:
  auth-extra-groups: c3lzdGVtOmJvb3RzdHJhcHBlcnM6a3ViZWFkbTpkZWZhdWx0LW5vZGUtdG9rZW4=  
  expiration: MjAyNS0wNi0yOFQwMDozODoyMlo=        
  token-id: ZmJiaGlz                              # <== 解码后就是 fbbhis             可用命令 echo "ZmJiaGlz" | base64 -d  解码
  token-secret: YjBrc3pxdnZyNXQxc2g4Mg==          # <== 解码后就是 b0kszqvvr5t1sh82   可用命令 echo "YjBrc3pxdnZyNXQxc2g4Mg==" | base64 -d 解码
  usage-bootstrap-authentication: dHJ1ZQ==
  usage-bootstrap-signing: dHJ1ZQ==
kind: Secret
metadata:
  creationTimestamp: "2025-06-27T00:38:22Z"
  name: bootstrap-token-fbbhis
  namespace: kube-system
  resourceVersion: "1823"
  uid: a83c8c3e-40aa-400b-b77b-bc6ec58c1c69
type: bootstrap.kubernetes.io/token
```

### 2.5.2 将token与certificate进行组合
**master02的(先不要操作)**
```
kubeadm join k8s01-component-connection-kubeapi.local.io:6443 --token fbbhis.b0kszqvvr5t1sh82 --discovery-token-ca-cert-hash sha256:28d12b7d0a29a7276305d6250d809e0dd8d6caf4851547aef566c2137d43af90  \
   --control-plane  --certificate-key  302120bc9d7d4da653e2a1a48c6b79b177f0b547e1340b68ee71a0b665221855  \
   --node-name master02
```

**master03的(先不要操作)**
```
kubeadm join k8s01-component-connection-kubeapi.local.io:6443 --token fbbhis.b0kszqvvr5t1sh82 --discovery-token-ca-cert-hash sha256:28d12b7d0a29a7276305d6250d809e0dd8d6caf4851547aef566c2137d43af90  \
   --control-plane  --certificate-key  302120bc9d7d4da653e2a1a48c6b79b177f0b547e1340b68ee71a0b665221855  \
   --node-name master03
```

### 2.5.3 master02上操作
**先拉取好镜像**
```
kubeadm config images pull \
  --image-repository=registry.aliyuncs.com/google_containers \
  --kubernetes-version=v1.24.4
```

**/etc/hosts解析相应域名**
```
cat >>/etc/hosts <<'EOF'
172.31.7.203  k8s01-component-connection-kubeapi.local.io
EOF
```

**部署k8s相关组件并加入现有控制平面,成为控制平面一部分(高可用)**  
如果未事先拉取image,速度有点慢的
```
## 试运行一下
kubeadm join k8s01-component-connection-kubeapi.local.io:6443 --token fbbhis.b0kszqvvr5t1sh82 --discovery-token-ca-cert-hash sha256:28d12b7d0a29a7276305d6250d809e0dd8d6caf4851547aef566c2137d43af90  \
   --control-plane  --certificate-key  302120bc9d7d4da653e2a1a48c6b79b177f0b547e1340b68ee71a0b665221855  \
   --node-name master02  --dry-run=client

## 正式运行一下
kubeadm join k8s01-component-connection-kubeapi.local.io:6443 --token fbbhis.b0kszqvvr5t1sh82 --discovery-token-ca-cert-hash sha256:28d12b7d0a29a7276305d6250d809e0dd8d6caf4851547aef566c2137d43af90  \
   --control-plane  --certificate-key  302120bc9d7d4da653e2a1a48c6b79b177f0b547e1340b68ee71a0b665221855  \
   --node-name master02
  #
  # 成功后会提示如下信息
  # To start administering your cluster from this node, you need to run the following as a regular user:
  # 
  #	mkdir -p $HOME/.kube
  #  	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  # 	sudo chown $(id -u):$(id -g) $HOME/.kube/config
  # 
  # Run 'kubectl get nodes' to see this node join the cluster.
  #
  # 根据提示进行操作
  # 

## 列出k8s中有所有的nodes资源对象
root@master02:~# kubectl get nodes
NAME       STATUS     ROLES           AGE     VERSION
master01   NotReady   control-plane   3h17m   v1.24.4
master02   NotReady   control-plane   2m46s   v1.24.4
```

**修改之前对/etc/hosts文件的修改**
```
## 修改/etc/hosts文件
sed    "/k8s01-component-connection-kubeapi.local.io/"d  /etc/hosts
sed -i "/k8s01-component-connection-kubeapi.local.io/"d  /etc/hosts

cat >>/etc/hosts<<'EOF'
127.0.0.1  k8s01-component-connection-kubeapi.local.io
EOF

## 再列出k8s中所有的nodes资源对象
root@master02:~# kubectl get nodes
NAME       STATUS     ROLES           AGE     VERSION
master01   NotReady   control-plane   3h20m   v1.24.4
master02   NotReady   control-plane   5m30s   v1.24.4
```

### 2.5.4 master03上操作
**先拉取好镜像**
```
kubeadm config images pull \
  --image-repository=registry.aliyuncs.com/google_containers \
  --kubernetes-version=v1.24.4
```

**/etc/hosts解析相应域名**
```
cat >>/etc/hosts <<'EOF'
172.31.7.203  k8s01-component-connection-kubeapi.local.io
EOF
```

**部署k8s相关组件并加入现有控制平面,成为控制平面一部分(高可用)**
如果未事先拉取image,速度有点慢的
```
## 试运行一下
kubeadm join k8s01-component-connection-kubeapi.local.io:6443 --token fbbhis.b0kszqvvr5t1sh82 --discovery-token-ca-cert-hash sha256:28d12b7d0a29a7276305d6250d809e0dd8d6caf4851547aef566c2137d43af90  \
   --control-plane  --certificate-key  302120bc9d7d4da653e2a1a48c6b79b177f0b547e1340b68ee71a0b665221855  \
   --node-name master03  --dry-run

## 正式运行
kubeadm join k8s01-component-connection-kubeapi.local.io:6443 --token fbbhis.b0kszqvvr5t1sh82 --discovery-token-ca-cert-hash sha256:28d12b7d0a29a7276305d6250d809e0dd8d6caf4851547aef566c2137d43af90  \
   --control-plane  --certificate-key  302120bc9d7d4da653e2a1a48c6b79b177f0b547e1340b68ee71a0b665221855  \
   --node-name master03
  #
  # 成功后会提示如下信息
  # To start administering your cluster from this node, you need to run the following as a regular user:
  #
  #     mkdir -p $HOME/.kube
  #     sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  #     sudo chown $(id -u):$(id -g) $HOME/.kube/config
  #
  # Run 'kubectl get nodes' to see this node join the cluster.
  #
  # 根据提示进行操作
  #

## 列出k8s中有所有的nodes资源对象
root@master03:~# kubectl get nodes
NAME       STATUS     ROLES           AGE     VERSION
master01   NotReady   control-plane   3h17m   v1.24.4
master02   NotReady   control-plane   2m46s   v1.24.4
master03   NotReady   control-plane   2m46s   v1.24.4
```

**修改之前对/etc/hosts文件的修改**
```
## 修改/etc/hosts文件
sed    "/k8s01-component-connection-kubeapi.local.io/"d  /etc/hosts
sed -i "/k8s01-component-connection-kubeapi.local.io/"d  /etc/hosts

cat >>/etc/hosts<<'EOF'
127.0.0.1  k8s01-component-connection-kubeapi.local.io
EOF

## 再列出k8s中所有的nodes资源对象
root@master03:~# kubectl get nodes
NAME       STATUS     ROLES           AGE     VERSION
master01   NotReady   control-plane   3h20m   v1.24.4
master02   NotReady   control-plane   5m30s   v1.24.4
master03   NotReady   control-plane   5m30s   v1.24.4
```

### 2.5.4 引入一下
其实这个时候就可以安装一些Addons了(先安装cni-->dns-->....)。但这里我就不在这里来安装Addons。之所以这么说，是因为现在
k8s是有worker node（master01、master02、master03）的，只不过具备污点（Taints），之所以有污点，是因为其所在宿主机
运行有k8s master相关组件，也为了不让业务Pod调度到上面，安装组件我可以让其容忍污点。
<br>
<br>


# 3.加入worker node到现有控制平面
## 3.1 安装部署工具kubeadm及k8s组件kubelet
node01、node02上操作。
参考 "1.5.1 安装部署工具kubeadm及k8s组件kubelet"。

## 3.2 安装容器运行时containerd
node01、node02上操作。
参考 "1.5.2 安装容器运行时containerd"

## 3.3 配置crictl连接containerd
node01、node02上操作。
参考 "1.5.3 配置crictl连接containerd"

## 3.4 安装nginx(L4代理)
node01、node02上操作。  
**安装nginx**
```
## 安装nginx
sudo apt update
sudo chattr -i /etc/passwd /etc/group /etc/shadow /etc/gshadow
sudo apt install -y nginx
sudo systemctl status nginx.service
sudo systemctl enable nginx.service

## 查看是否有stream模块
nginx -V

## 备份nginx配置文件
cp -a /etc/nginx/nginx.conf{,.defaults}

## 精简nginx配置文件
grep  -Ev "#|^$" /etc/nginx/nginx.conf.defaults  >/etc/nginx/nginx.conf

## 启动并开机自启动
systemctl restart nginx.service
systemctl enable nginx.service
```

**配置nginx**
```
sudo bash -c "cat >/etc/nginx/nginx.conf"<<'EOF'
## main
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

## events
events {
    worker_connections 1024;
}

## stream
stream {
    # apisrevers
    upstream k8s01-apiservers {
        server 172.31.7.203:6443 max_fails=2 fail_timeout=30s;
        server 172.31.7.204:6443 max_fails=2 fail_timeout=30s;
        server 172.31.7.205:6443 max_fails=2 fail_timeout=30s;
    }
    server {
        listen 127.0.0.1:6443;
        proxy_pass k8s01-apiservers;
    }
}
EOF
```

**平面启动**
```
sudo nginx -t
sudo nginx -s reload
sudo ss -lntup | grep -w 6443
```

## 3.5 控制平面生成token

**控制平面生成token(我就在master01上操作了)**
```
root@master01:~# kubeadm token create --print-join-command
kubeadm join k8s01-component-connection-kubeapi.local.io:6443 --token m3hioc.1f4qr4un7xg5ymr3 --discovery-token-ca-cert-hash sha256:453ebc60e7cc65858ad4795c2b2ee3a9582c7c2dfa441bda93a332c6be1ccec5 
```

## 3.6 node01加入控制平面
**利用/etc/hosts做DNS解析**
```
cat >>/etc/hosts<<'EOF'
127.0.0.1  k8s01-component-connection-kubeapi.local.io
EOF
```

**加入控制平面**
```
## 试运行一下
kubeadm join k8s01-component-connection-kubeapi.local.io:6443 --token m3hioc.1f4qr4un7xg5ymr3 --discovery-token-ca-cert-hash sha256:453ebc60e7cc65858ad4795c2b2ee3a9582c7c2dfa441bda93a332c6be1ccec5  \
   --node-name node01  --dry-run

## 正式运行
kubeadm join k8s01-component-connection-kubeapi.local.io:6443 --token m3hioc.1f4qr4un7xg5ymr3 --discovery-token-ca-cert-hash sha256:453ebc60e7cc65858ad4795c2b2ee3a9582c7c2dfa441bda93a332c6be1ccec5  \
   --node-name node01
```

## 3.7 node02加入控制平面
**利用/etc/hosts做DNS解析**
```
cat >>/etc/hosts<<'EOF'
127.0.0.1  k8s01-component-connection-kubeapi.local.io
EOF
```

**加入控制平面**
```
## 试运行一下
kubeadm join k8s01-component-connection-kubeapi.local.io:6443 --token m3hioc.1f4qr4un7xg5ymr3 --discovery-token-ca-cert-hash sha256:453ebc60e7cc65858ad4795c2b2ee3a9582c7c2dfa441bda93a332c6be1ccec5  \
   --node-name node02  --dry-run

## 正式运行
kubeadm join k8s01-component-connection-kubeapi.local.io:6443 --token m3hioc.1f4qr4un7xg5ymr3 --discovery-token-ca-cert-hash sha256:453ebc60e7cc65858ad4795c2b2ee3a9582c7c2dfa441bda93a332c6be1ccec5  \
   --node-name node02
```

## 3.8 查看现有nodes资源对象
在master01、master02、master03上操作均可
```
root@master01:~# kubectl get nodes -o wide
NAME       STATUS     ROLES           AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master01   NotReady   control-plane   4h9m   v1.24.4   172.31.7.203   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   containerd://1.7.27
master02   NotReady   control-plane   54m    v1.24.4   172.31.7.204   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   containerd://1.7.27
master03   NotReady   control-plane   40m    v1.24.4   172.31.7.205   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   containerd://1.7.27
node01     NotReady   <none>          38s    v1.24.4   172.31.7.206   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   containerd://1.7.27
node02     NotReady   <none>          6s     v1.24.4   172.31.7.207   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   containerd://1.7.27
```
<br>
<br>


## 3.8 查看现有nodes资源对象
在master01、master02、master03上操作均可
```
root@master01:~# kubectl get nodes -o wide
NAME       STATUS     ROLES           AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master01   NotReady   control-plane   4h9m   v1.24.4   172.31.7.203   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   containerd://1.7.27
master02   NotReady   control-plane   54m    v1.24.4   172.31.7.204   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   containerd://1.7.27
master03   NotReady   control-plane   40m    v1.24.4   172.31.7.205   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   containerd://1.7.27
node01     NotReady   <none>          38s    v1.24.4   172.31.7.206   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   containerd://1.7.27
node02     NotReady   <none>          6s     v1.24.4   172.31.7.207   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   containerd://1.7.27
```
<br>
<br>


# 4. 安装相关的Addons
在master01、master02、master03上任何一台上操作
## 4.1 安装CNI插件之Flannel vxlan
参考  https://github.com/qepyd/kubernetes/tree/main/91.Addons/01.cni/01.flannel/03.vxlan-And-DirectRouting-false  
根据现有k8s集群的规划，直接应用里面的 kube-flannel.yml 这个manifests

## 4.2 安装DNS插件之Coredns 
参考 https://github.com/qepyd/kubernetes/tree/main/91.Addons/02.dns/01.coredns  
根据现有k8s集群的规划，直接应用里面的 coredns.yaml 这个manifests

## 4.3 安装container-resource-monitoring插件之metrics-server
参考  https://github.com/qepyd/kubernetes/tree/main/91.Addons/04.container-resource-monitoring/metrics-server/v0.6.4  
直接应用里面的 components.yaml 这个manifests

