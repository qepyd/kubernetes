==============kubeadm工具在ubuntu20.04平台部署kubernetes v1.24.4,容器运行时使用containerd==============

# 1.kubernetes的相关规划及准备相应环境
## 1.1 kubernetes基本规划
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

## 1.2 所准备的相关服务器
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



## 1.3 所准备服务器的优化
### 1.3.1 修改主机名
请参考"1.2 所准备的相关服务器"中的信息进行设置，设置命令为:
```
hostnamectl set-hostname <主机名>
```

### 1.3.2 停止ufw防火墙
```
systemctl stop ufw.service
systemctl disable ufw.service
```

### 1.3.3 选择默认的编辑器为vim
```
echo 'export EDITOR=/usr/bin/vi' >>/etc/profile
source /etc/profile
```

### 1.3.4 解决apt安装软件时让其交互式设置
```
echo "export DEBIAN_FRONTEND=noninteractive" >>/etc/profile
source /etc/profile
```

### 1.3.5 更改apt源为阿里云的 
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


### 1.3.6 开启crond的日志
```
cat >>/etc/rsyslog.d/50-default.conf<<'EOF'
"cron.*   /var/log/cron.log"
EOF

systemctl restart cron.service
systemctl restart rsyslog.service
```

### 1.3.7 定时更新系统操作时间
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


### 1.3.8 开启ipvs支持
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


### 1.3.9 加载br_netfilter模块并设置内核参数
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


### 1.3.10 开启内核网络转发
```
chattr -i /etc/sysctl.conf

cat >>/etc/sysctl.conf<<'EOF'
net.ipv4.ip_forward=1
EOF

sysctl -p
```




## 1.4 相关软件的安装(不操作,后面来引用)
### 1.4.1 安装部署工具kubeadm及k8s组件kubelet
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
apt install -y kubelet=1.24.4-00  kubeadm=1.24.4-00

## 检查
which kubeadm
which kubelet

## kubelet启动是会失败的(正常)
systemctl status kubelet.service  # 未正常启动,是正常的
systemctl enable kubelet.service  # 加入开机自启动
```

### 1.4.2 安装容器运行时





