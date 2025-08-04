# 1 准备的服务器及操作系统优化
## 1.1 准备的服务器
**ceph的网络**
```
业务网络：172.31.0.0/16
集群网络：172.31.0.0/16
```

**ceph可提供的存储**
```
对象存储   # 后面会实现
文件存储   # 后面会实现
块  存储   # 后面会实现   
```

**ceph集群的服务器**
```
操作系统      主机名        IP地址            系统盘     数据盘                       角色/软件
ubuntu 20.04  ceph-mon01    172.31.8.201/16   /dev/sda   -                            部署服务器/ceph-mon
ubuntu 20.04  ceph-mon02    172.31.8.202/16   /dev/sda   -                            -/ceph-mon
ubuntu 20.04  ceph-mon03    172.31.8.203/16   /dev/sda   -                            -/ceph-mon

ubuntu 20.04  ceph-mgr01    172.31.8.204/16   /dev/sda   -                            -/ceph-mgr
ubuntu 20.04  ceph-mgr02    172.31.8.205/16   /dev/sda   -                            -/ceph-mgr
 
ubuntu 20.04  ceph-mds01    172.31.8.206/16   /dev/sda   -                            -/ceph-mds
ubuntu 20.04  ceph-mds02    172.31.8.207/16   /dev/sda   -                            -/ceph-mds

ubuntu 20.04  ceph-rgw01    172.31.8.208/16   /dev/sda   -                            -/ceph-rgw
ubuntu 20.04  ceph-rgw02    172.31.8.209/16   /dev/sda   -                            -/ceph-rgw

ubuntu 20.04  ceph-osd01    172.31.8.210/16   /dev/sda   /dev/sdb至/dev/sdf，各100G   -/ceph-osd
ubuntu 20.04  ceph-osd02    172.31.8.211/16   /dev/sda   /dev/sdb至/dev/sdf，各100G   -/ceph-osd
ubuntu 20.04  ceph-osd03    172.31.8.212/16   /dev/sda   /dev/sdb至/dev/sdf，各100G   -/ceph-osd
   #
   # 相关osd服务器上的数据盘，不做任何操作(例如：分区、格式化、挂载)
   #
```

## 1.2 操作系统优化
### 1.2.1 停止ufw防火墙
```
systemctl stop ufw.service
systemctl disable ufw.service
```

### 1.2.2 选择默认的编辑器为vim
```
echo 'export EDITOR=/usr/bin/vi' >>/etc/profile
source /etc/profile
```

### 1.2.3 解决apt安装软件时让其交互式设置
```
echo "export DEBIAN_FRONTEND=noninteractive" >>/etc/profile
source /etc/profile
```

### 1.2.4 确保/etc/resolv.conf文件不被systemd-resolved.service重启后覆盖
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

### 1.2.5 更新apt源
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

### 1.2.6 定时更新时间
修改时区为CST，以及时间为24小时制
```
## 安装软件
apt update
apt-get install -y tzdata

## 修改时区为CST,其实默认下/etc/localtime是/usr/share/zoneinfo/Etc/UTC文件的软链接
ln -svf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime

## 修改时间为24小时,该操作后,退出当前连接,重新连接后就会生效
echo "LC_TIME=en_DK.UTF-8" >>/etc/default/locale
```

安装chrony
```
chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow
apt update 
apt install -y chrony
systemctl status chrony.service     # ubuntu下安装好以后,它会给你启动的
systemctl is-enabled chrony.service # ubuntu下会给你加入开机自启动的
systemctl enable chrony.service     # 加入开机自启动 
```

配置chrony
```
### 将以pool开头的行给删除掉
grep "^pool" /etc/chrony/chrony.conf
sed   '/^pool/'d /etc/chrony/chrony.conf
sed -i '/^pool/'d /etc/chrony/chrony.conf

### 往文件中追加内容
cat >>/etc/chrony/chrony.conf <<'EOF'

server ntp1.aliyun.com iburst
server ntp2.aliyun.com iburst
server ntp3.aliyun.com iburst
server ntp4.aliyun.com iburst
server ntp5.aliyun.com iburst
server ntp6.aliyun.com iburst
server ntp7.aliyun.com iburst
EOF
```

重启并检查
```
systemctl restart chrony.service
chronyc  sources -v
```

### 1.2.7 设置主机名
参考 1.1 章节中 "ceph集群的服务器"
```
hostnamectl set-hostname <HostName>
```

### 1.2.8 DNS解析(/etc/hosts)
```
cat >>/etc/hosts<<'EOF'
172.31.8.201   ceph-mon01
172.31.8.202   ceph-mon02
172.31.8.203   ceph-mon03

172.31.8.204   ceph-mgr01
172.31.8.205   ceph-mgr02

172.31.8.206   ceph-mds01
172.31.8.207   ceph-mds02

172.31.8.208   ceph-rgw01
172.31.8.209   ceph-rgw02

172.31.8.210   ceph-osd01
172.31.8.211   ceph-osd02
172.31.8.212   ceph-osd03
EOF
```

### 1.2.9 各主机上设置ceph的源
```
## 安装一些工具
sudo apt-get update
sudo chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common

## 更改ceph的仓库 
sudo wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -

sudo apt-add-repository 'deb https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific/ focal main'

	# debian-pacific  # debian是指你的操作系统品牌，pacific是指ceph大版本的代号
	# focal          # 对应debian操作系统大版本的代号，它前面有空格的哈。
	
sudo apt update

## 查看有哪些版本
apt-cache madison ceph
    # 可看到不同源对应的有不同的ceph版本。
    # 只会有ceph pacific版本，因为前面添加源的时候指定了ceph的版本
    # 结果为
    #  ceph | 16.2.15-1focal | https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific focal/main amd64 Packages
    #  ceph | 15.2.17-0ubuntu0.20.04.6 | https://mirrors.aliyun.com/ubuntu focal-security/main amd64 Packages
    #  ceph | 15.2.17-0ubuntu0.20.04.6 | https://mirrors.aliyun.com/ubuntu focal-updates/main amd64 Packages
    #  ceph | 15.2.1-0ubuntu1 | https://mirrors.aliyun.com/ubuntu focal/main amd64 Packages
    #  ceph | 15.2.1-0ubuntu1 | https://mirrors.aliyun.com/ubuntu focal/main Sources
    #  ceph | 15.2.17-0ubuntu0.20.04.6 | https://mirrors.aliyun.com/ubuntu focal-security/main Sources
    #  ceph | 15.2.17-0ubuntu0.20.04.6 | https://mirrors.aliyun.com/ubuntu focal-updates/main Sources
```

### 1.2.10 各主机上安装Python 2.7
```
sudo apt update
sudo chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow 
sudo apt-cache madison python2.7
sudo apt install -y python2.7

sudo ln -svf /usr/bin/python2.7 /usr/bin/python2
sudo which python2
```

### 1.2.11 创建普通用户admin并visudo
```
#### 用途：相当于root用户,因为root用户我们会禁止远程登录
01：用来充当root用户的角色。
02：它不会用来运行任何的应用。

#### 用户的基本要求
01：用户要能够远程登录，要有家目录。
02：用户不能过期、密码得复杂化，密码是否过期是另外一回事。
03：用户的主组为admin,用户的辅组为wheel。
04：用户得被visudo授权为：admin ALL=(ALL:ALL) NOPASSWD: ALL

#### 创建用户的命令
chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow
groupadd -g 91 wheel
groupadd -g 1000 admin
useradd admin -u 1000 -g admin -G wheel -m -s /bin/bash
echo "admin:123456"|chpasswd

#### visudo
echo "admin ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
visudo -c
```


## 1.3 部署服务器安装部署工具ceph-deploy
部署服务器(172.31.8.201   ceph-mon01)的admin用户下操作

### 1.3.1 安装部署工具ceph-deploy
eph-deploy工具是用户ceph集群工具集中的一种。这里只在ceph-deploy服务器上部署。

**安装pip2**
```
## 启用 universe 源仓库
sudo add-apt-repository universe
sudo apt update

## 安装pip2
#  Python 2的 pip 没有被包含在 Ubuntu 20.04源仓库中。使用get-pip.py脚本来为 Python 2安装 pip。
wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
sudo python2 get-pip.py   # 前面已经安装了python2

## 验证pip2
pip2 --version
pip --version
```

**安装ceph-deploy工具**
```
## 查看ceph-deploy版本，apt源里面自带的 
apt-cache madison ceph-deploy

## pip2来安装ceph-deploy
sudo pip2 install ceph-deploy
which ceph-deploy
ceph-deploy --version       # 版本是2.0.1
```

### 1.3.2 生成ssh密钥对
**编写脚本**
```
mkdir  $HOME/tools/
ls -ld $HOME/tools/

cat >$HOME/tools/01.create-key-pair.sh<<'EOF'
#!/bin/bash
#
#  此脚本是在需要生成密钥对的用户下执行，它会判断是否存在密钥对（当然有不同的类型），若存在,就不会生成密钥对。
# 
if   [ ! -d $HOME/.ssh ];then
	 ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -P ""
elif [  ! -f $HOME/.ssh/id_rsa -a   ! -f $HOME/.ssh/id_rsa.pub  ];then
	  ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -P ""
else 
	 echo "**** The current user has an RSA key pair. Procedure,exit script" && exit 0
fi
EOF
```

**执行脚本**
```
bash $HOME/tools/01.create-key-pair.sh
```

### 1.3.3 实现ssh单向免密钥
**安装sshpass工具**
```
sudo apt update
sudo chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow
sudo apt install -y sshpass
which sshpass
```

**准备主机清单**
```
cat >$HOME/tools/host.txt<<'EOF'
172.31.8.201   ceph-mon01
172.31.8.202   ceph-mon02
172.31.8.203   ceph-mon03

172.31.8.204   ceph-mgr01
172.31.8.205   ceph-mgr02

172.31.8.206   ceph-mds01
172.31.8.207   ceph-mds02

172.31.8.208   ceph-rgw01
172.31.8.209   ceph-rgw02

172.31.8.210   ceph-osd01
172.31.8.211   ceph-osd02
172.31.8.212   ceph-osd03
EOF
```

**编写脚本**
```
cat >$HOME/tools/02.sshpass-cp-publickey-to-target-host.sh<<'EOF'
#!/bin/bash
#
#
#### 01：此脚本是将A主机上某用户的公钥[单向]拷贝至目标主机上的某用户下，以实现A主机上的某用户与目标主机上的某用户实现单向免密钥。
#### 02：此脚本不负责A主机上某用户的公钥生成。
#### 03：此脚本结合A主机上的sshpass工具将公钥拷贝至目标主机上，当A主机上没有sshpass工具时,此脚本不负责安装，因为A主机上的某用户
####     可能不具备安装软件的权限。
#
#
#### 定义变量
Local_Host_User_Ssh_Pub="$HOME/.ssh/id_rsa.pub"  # public key
Target_Host_Ssh_Port="22"                        # remote host ssh port, please change
Target_Host_User="admin"                     # remote host user name, please change
Target_Host_User_Pass="123456"          # remote host user password, please change
Target_Host=( $(cat ./host.txt) )              # 查看此脚本所在路径下的hostip.txt文件内容,用来作为数组中的元素。

#### 检查本机是否有sshpass工具,当没有时,此脚本不负责安装
#### 因为拷贝A主机上某用户的公钥至other主机的用户时,A主机上的某用户有可能不具备安装软件的权限
which sshpass >/dev/null 2>&1
if [ $? -eq 0 ];then
   echo "01：[INFO] sshpass command is exists"
 else
   echo "01：[ERROR] sshpass command is not exists,script is not responsible for installation,exit"
   exit 1
fi

#### 判断 $Local_Host_User_Ssh_Pub 公钥是否存在,不存在则退出脚本
if [ -f "$Local_Host_User_Ssh_Pub"  ];then
   echo "02: [INFO] \"$Local_Host_User_Ssh_Pub\" file is exists"
  else
   echo "02：[ERROR] \"$Local_Host_User_Ssh_Pub\" file is not exists,exit script,please check"
   exit 1
fi

#### 本地结合sshpass工具将A host相关用户的公钥 拷贝 至目标机器的相应用户下
echo "03: [INFO] Copy local user(public key) to target host user"
for((i=0;i<${#Target_Host[*]};i++))
do
	sshpass -p "$Target_Host_User_Pass" \
	ssh-copy-id -o StrictHostKeyChecking=no -i $Local_Host_User_Ssh_Pub -p $Target_Host_Ssh_Port   $Target_Host_User@${Target_Host[i]}  >/dev/null 2>&1
	RETVAL=$?
	if [ $RETVAL -eq 0 ];then
	   echo "  [INFO] ssh-copy-id local(\"$Local_Host_User_Ssh_Pub\")  to \"${Target_Host[i]}\" host \"$Target_Host_User\" user successful"
	  else
	   echo "  [ERROR] ssh-copy-id local(\"$Local_Host_User_Ssh_Pub\")  to \"${Target_Host[i]}\" host \"$Target_Host_User\" user failure"
	fi
done


#### 本地ssh客户端远程连接目标端(首次测试）
echo "04: [INFO] Local user(ssh connection target host user test)"
for((i=0;i<${#Target_Host[*]};i++))
do
	ssh -o StrictHostKeyChecking=no -o PasswordAuthentication=no -p $Target_Host_Ssh_Port $Target_Host_User@${Target_Host[i]} hostname >/dev/null 2>&1
	RETVAL=$?
	if [ $RETVAL -eq 0 ];then
	   echo "  [INFO] local user ssh connection(\"${Target_Host[i]}\") user(\"$Target_Host_User\")test succeeded."
	  else
	   echo "  [ERROR] local user ssh connection(\"${Target_Host[i]}\") user(\"$Target_Host_User\")test failure."
	fi
done
EOF
```

**执行脚本**
```
cd $HOME/tools
bash 02.sshpass-cp-publickey-to-target-host.sh
```



# 2 部署服务器上部署ceph集群
部署服务器(172.31.8.201 ceph-mon01)的admin用户下操作

## 2.1 为new cluster生成默认配置
```
### 创建相应的目录
mkdir $HOME/ceph-cluster
ls -ld $HOME/ceph-cluster

### 进入相应的目录
cd $HOME/ceph-cluster
pwd

### 人为使用uuidgen命令生成ceph cluster fsid，后面我就用它，因为我这是写文档。
admin@ceph-mon01:~/ceph-cluster$ uuidgen >cluster-fsid.txt
admin@ceph-mon01:~/ceph-cluster$ cat cluster-fsid.txt 
2004f705-b556-4d05-9e73-7884379e07bb

### 初始化集群的命令
cd $HOME/ceph-cluster    # 进入到相应的目录

ceph-deploy  new --fsid  $( cat ./cluster-fsid.txt ) \
  --public-network=172.31.0.0/16                     \
  --cluster-network=172.31.0.0/16                    \
  --no-ssh-copykey                                   \
  ceph-mon01  ceph-mon02
    #
    # ceph-deploy
    #   # 是部署工具
    # 
    # new
    #   # 部署工具的命令。
    #   # 为部署一个新的ceph集群而生成集群配置文件和相应的keyring文件。
    # 
    # --fsid
    #   # 指定ceph cluster的id
    #   # 例如：123456，这里是不会出错,后面部署其它组件时就会有问题了。
    #   # 例如：--fsid $( uuidgen )
    #   # 例如：--fsid $( cat ./cluster-fsid.txt ),用uuidgen事先生成并保存到文件
    #   # 我这人为指定了的,若不人为指定,会随机生成。
    # 
    # --public-network
    #   # 指定ceph cluster的业务网络地址段。
    # 
    # --cluster-network
    #   # 指定 ceph clsuter的集群网络地址段。
    #
    # --no-ssh-copykey
    #   # 不拷贝ssh的公钥至各mon node。
    # 
    # ceph-mon01 ceph-mon02
    #   # 相应的主机
    #   # 我这台部署服务器是可以解析成IP地址(public network)的,用的是
    #   # /etc/hosts文件来实现dns功能。
    #   # 注意：我规划的是3个mon node，这里只指定了2个mon node
    # 

### 上面命令会在其所在目录生成相应的文件
ceph-deploy-ceph.log
  # 记录部署工具ceph-deploy执行相关命令的日志文件
  # 后面我们还要在部署服务器上用ceph-deploy工具部署ceph的其它组件
ceph.conf             
  # ceph cluster集群的配置文件
ceph.mon.keyring    
  # 连接ceph cluster中各ceph monitor服务时要用到的认证key。


### 查看一下ceph.conf这个配置文件,是可以修改的
admin@ceph-mon01:~/ceph-cluster$ cat ceph.conf 
[global]
fsid = 2004f705-b556-4d05-9e73-7884379e07bb
public_network = 172.31.0.0/16
cluster_network = 172.31.0.0/16
mon_initial_members = ceph-mon01, ceph-mon02
mon_host = 172.31.8.201,172.31.8.202
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx


### 前面我为ceph monitor规划了三台主机,但在生成new ceph cluster配置文件和mon 的
#   key文件时，只指定了两台,这里我要把另外一台加进入来。就直接修改ceph.conf文件。
01：我们应该手动修改ceph.conf文件中mon_initial_members和mon_host的值
02：其修改后的结果如下所示：
admin@ceph-mon01:~/ceph-cluster$ cat ceph.conf 
[global]
fsid = 2004f705-b556-4d05-9e73-7884379e07bb
public_network = 172.31.0.0/16
cluster_network = 172.31.0.0/16
mon_initial_members = ceph-mon01, ceph-mon02, ceph-mon03
mon_host = 172.31.8.201,172.31.8.202,172.31.8.203
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
```

## 2.2 部署ceph的Rados Cluster
https://docs.ceph.com/en/pacific/glossary/   # 搜索rados cluster  
这里我要部署ceph的Rados Cluster。它包含ceph monitors、ceph managers、osds。

### 2.2.1 相应主机上安装ceph monitors 
ceph monitor一定是要先部署的哈。至少1个，要想高可用的话，至少得3个。
**各主机上安装ceph-mon命令**
```
cd $HOME/ceph-cluster   # 进入到相应的目录
ceph-deploy install --mon --no-adjust-repos --nogpgcheck  ceph-mon01
ceph-deploy install --mon --no-adjust-repos --nogpgcheck  ceph-mon02
ceph-deploy install --mon --no-adjust-repos --nogpgcheck  ceph-mon03
  #
  # 01：一条命令可以指定多个ceph mon host，多个时用空格分隔。安装软件的嘛。
  # 02：ceph-mon01、ceph-mon02、ceph-mon03就是主机,得要能够经过dns解析,我的
  #     部署服务器上是可以解析成相应IP地址的,用的是/etc/host文件。
  # 03：--no-adjust-repos表示不添加ceph源,因为我在前面为各ceph cluster node手
  #     动添加了的。
  # 04：--nogpgcheck 表示不进行包检查。
  # 
  # PS：会在相应主机上安装ceph-common、ceph-base、ceph-mon等软件包,对应就会有很多的命令。
  #
```

**各主机上创建并初始化ceph-mon，其实就是安装、启动**
```
## 创建和初始化命令
cd $HOME/ceph-cluster   # 进入到相应的目录
ceph-deploy mon  create-initial
  #
  # ceph-deploy 
  #   部署工具
  # 
  # mon
  #   是部署工具的命令，含义为：Ceph MON Daemon management
  #   
  # create-initial
  #   是部署工具其mon命令的子命令,表示创建和初始化一起做。
  # 
  # PS：这里ceph-deploy会读取当前目录下的ceph.conf文件中的mon_initial_members
  #      参数的所有值，然后经过dns解析得到IP地址，再ssh去连接。
  # PS：会把当前目录下集群配置文件(ceph.conf)推送到各mon node的/etc/ceph/目录下

## 初始化完成后，其部署服务器的当前目录下会生成"bootstrap-组件.keyring文件"，所以
#  得先部署ceph monitor。后面用部署工具部署其它组件时,会把bootstrap-组件.keyring
#  文件推送到相应组件所在的host上。这里生成的bootstrap-组件.keyring文件如下。

admin@ceph-mon01:~/ceph-cluster$ ls -l
total 368
-rw-rw-r-- 1 admin admin 336991 Aug  4 08:34 ceph-deploy-ceph.log
-rw------- 1 admin admin    113 Aug  4 08:34 ceph.bootstrap-mds.keyring
-rw------- 1 admin admin    113 Aug  4 08:34 ceph.bootstrap-mgr.keyring
-rw------- 1 admin admin    113 Aug  4 08:34 ceph.bootstrap-osd.keyring
-rw------- 1 admin admin    113 Aug  4 08:34 ceph.bootstrap-rgw.keyring
-rw------- 1 admin admin    151 Aug  4 08:34 ceph.client.admin.keyring
-rw-rw-r-- 1 admin admin    313 Aug  4 08:27 ceph.conf
-rw------- 1 admin admin     73 Aug  4 08:11 ceph.mon.keyring
-rw-rw-r-- 1 admin admin     37 Aug  4 08:04 cluster-fsid.txt
admin@ceph-mon01:~/ceph-cluster$
admin@ceph-mon01:~/ceph-cluster$
admin@ceph-mon01:~/ceph-cluster$ ll /etc/ceph/ceph.conf 
-rw-r--r-- 1 root root 313 Aug  4 08:34 /etc/ceph/ceph.conf
```

**查看ceph的状态**
```
admin@ceph-mon01:~/ceph-cluster$ sudo cp -a ceph.client.admin.keyring /etc/ceph/
admin@ceph-mon01:~/ceph-cluster$
admin@ceph-mon01:~/ceph-cluster$ ls -l /etc/ceph/
total 12
-rw------- 1 admin admin 151 Aug  4 08:34 ceph.client.admin.keyring
-rw-r--r-- 1 root  root  313 Aug  4 08:34 ceph.conf
-rw-r--r-- 1 root  root   92 Feb 27  2024 rbdmap
-rw------- 1 root  root    0 Aug  4 08:24 tmpIttqYs
-rw------- 1 root  root    0 Aug  4 08:34 tmpXLsRGP
-rw------- 1 root  root    0 Aug  4 08:33 tmpg_CwGp
-rw------- 1 root  root    0 Aug  4 08:28 tmpl2RpTn
-rw------- 1 root  root    0 Aug  4 08:30 tmpxvMllf
admin@ceph-mon01:~/ceph-cluster$

admin@ceph-mon01:~$ ceph -s
  cluster:
    id:     2004f705-b556-4d05-9e73-7884379e07bb
    health: HEALTH_WARN
            mons are allowing insecure global_id reclaim
 
  services:
    mon: 3 daemons, quorum ceph-mon01,ceph-mon02,ceph-mon03 (age 18s)
    mgr: no daemons active
    osd: 0 osds: 0 up, 0 in
 
  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:
```

**查看mon的状态**
```
admin@ceph-mon01:~$ sudo ceph mon stat
e3: 3 mons at {ceph-mon01=[v2:172.31.8.201:3300/0,v1:172.31.8.201:6789/0],ceph-mon02=[v2:172.31.8.202:3300/0,v1:172.31.8.202:6789/0],ceph-mon03=[v2:172.31.8.203:3300/0,v1:172.31.8.203:6789/0]} removed_ranks: {2}, election epoch 16, leader 0 ceph-mon01, quorum 0,1,2 ceph-mon01,ceph-mon02,ceph-mon03
```

### 2.2.2 集群状态查看(分发密钥、推送配置文件)
将ceph cluster其超级用户client.admin的keyring文件（ceph.client.admin.keyring）分发到ceph-mon02、ceph-mon03主机上（有/etc/ceph/目录、有ceph命令、还有ceph cluster的配置文件conf)。

**分发** 
```
cd $HOME/ceph-cluster
ceph-deploy  admin   ceph-mon02
ceph-deploy  admin   ceph-mon03
```

**ceph-mon02、ceph-mon03主机上查看ceph状态**
```
sudo ceph -s
```


### 2.2.3 部署ceph manager
ceph-mgr进程至少1个，高可用的话，至少得2个。
**各主机上安装ceph-mgr命令**
```
cd $HOME/ceph-cluster
ceph-deploy install --mgr --no-adjust-repos  --nogpgcheck  ceph-mgr01
ceph-deploy install --mgr --no-adjust-repos  --nogpgcheck  ceph-mgr02
  #
  # 01：一条命令可以指定多个ceph mgr host，多个时用空格分隔。安装软件的嘛。
  # 02：ceph-mgr01、ceph-mgr02就是主机,得要能够经过dns解析,我的
  #     部署服务器上是可以解析成相应IP地址的,用的是/etc/hosts文件。所以这
  #     里，其ceph-deploy部署工具没有读取ceph.conf文件。
  # 03：--no-adjust-repos表示不添加ceph源,因为我在前面为各ceph cluster node手
  #     动添加了的。
  # 04：--nogpgcheck 表示不进行包检查。
  #  
  # PS：会在相应主机上安装ceph-common、ceph-base、ceph-mon等软件包,对应就会有很
  #     多的命令。
  #
```

**在远端主机上初始化ceph mgr，安装、配置、启动**
```
cd $HOME/ceph-cluster
ceph-deploy  mgr  create  ceph-mgr01:mgr1
ceph-deploy  mgr  create  ceph-mgr02:mgr2
  #
  # ceph-deploy  是部署工具
  # mgr          是部署工具的子命令
  # create       是部署工具其mgr子命令的子命令
  # ceph-mgr01:mgr1  前面表示主机,后面是ceph-mgr的进程ID
  # ceph-mgr02:mgr2  前面表示主机,后面是ceph-mgr的进程ID
  #
  # PS：ceph-mgr进程至少1个，高可用的话，至少得2个。
  #     A：我准备了两台服务器：ceph-mgr01、ceph-mgr02
  #     B：若1条命令搞定：ceph-deploy mgr create ceph-mgr01  ceph-mgr02
  #        但这样的话，其各host上ceph-mgr进程的id就是其主机名。
  #        我这不想，因为我写文档的话，我得给区分开。
  #
```

**查看ceph集群状态**
```
admin@ceph-mon01:~$ sudo ceph -s
  cluster:
    id:     2004f705-b556-4d05-9e73-7884379e07bb
    health: HEALTH_WARN
            mons are allowing insecure global_id reclaim
            OSD count 0 < osd_pool_default_size 3
 
  services:
    mon: 3 daemons, quorum ceph-mon01,ceph-mon02,ceph-mon03 (age 18m)
    mgr: mgr1(active, since 37s), standbys: mgr2
    osd: 0 osds: 0 up, 0 in
 
  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs: 
```

**查看mgr状态**
```
admin@ceph-mon01:~$ sudo ceph mgr stat
{
    "epoch": 5,
    "available": true,
    "active_name": "mgr1",
    "num_standby": 1
}
```

### 2.2.4 相应主机上安装osds
**安装ceph-osd命令**
```
cd $HOME/ceph-cluster
ceph-deploy install --osd --no-adjust-repos  --nogpgcheck ceph-osd01
ceph-deploy install --osd --no-adjust-repos  --nogpgcheck ceph-osd02
ceph-deploy install --osd --no-adjust-repos  --nogpgcheck ceph-osd03
  #
  # 01：一条命令可以指定多个ceph mon host，多个时用空格分隔。安装软件的嘛。
  # 02：ceph-osd01、ceph-osd02、ceph-osd03就是主机,得要能够
  #     经过dns解析,我的部署服务器上是可以解析成相应IP地址的,用的是/etc/hosts
  #     文件。所以这里，其ceph-deploy部署工具没有读取ceph.conf文件。
  # 03：--no-adjust-repos表示不添加ceph源,因为我在前面为各ceph cluster node手
  #     动添加了的。
  # 04：--nogpgcheck 表示不进行包检查。
  # 
  # PS：会在相应主机上安装ceph-common、ceph-base、ceph-mon等软件包,对应就会有很
  #     多的命令。
  #
```

**擦除各ceph osd host上的磁盘**
```
### 列出各ceph osd host上有哪些磁盘(注意：会显示操作系统上所有的盘符和分区标识)
ceph-deploy disk list ceph-osd01
ceph-deploy disk list ceph-osd02
ceph-deploy disk list ceph-osd03

### 擦除各node上的磁盘(注意：可不能选择系统盘/dev/sda)
ceph-deploy disk zap ceph-osd01  /dev/sdb
ceph-deploy disk zap ceph-osd01  /dev/sdc 
ceph-deploy disk zap ceph-osd01  /dev/sdd 
ceph-deploy disk zap ceph-osd01  /dev/sde 
ceph-deploy disk zap ceph-osd01  /dev/sdf
   # 
   # 你也可一条命令指定多个磁盘(盘符),用空格分隔
   # 小心、小心、再小心。
   # 

ceph-deploy disk zap ceph-osd02  /dev/sdb  
ceph-deploy disk zap ceph-osd02  /dev/sdc 
ceph-deploy disk zap ceph-osd02  /dev/sdd 
ceph-deploy disk zap ceph-osd02  /dev/sde 
ceph-deploy disk zap ceph-osd02  /dev/sdf

ceph-deploy disk zap ceph-osd03  /dev/sdb  
ceph-deploy disk zap ceph-osd03  /dev/sdc 
ceph-deploy disk zap ceph-osd03  /dev/sdd 
ceph-deploy disk zap ceph-osd03  /dev/sde 
ceph-deploy disk zap ceph-osd03  /dev/sdf
```

**添加osds，会启动相应的ceph osd daemon**
```
### 注意：
01：每个磁盘(盘符)对应着一个ceph-osd的进程。进程id其自动编号(会从0开始)
02：下面的操作是串行执行(部署服务器上开一个shell容器,手动串行执行)

### 添加ceph-osd-node01主机上的相应磁盘
ceph-deploy osd create ceph-osd01 --data /dev/sdb    # id 0
ceph-deploy osd create ceph-osd01 --data /dev/sdc    # id 1
ceph-deploy osd create ceph-osd01 --data /dev/sdd    # id 2
ceph-deploy osd create ceph-osd01 --data /dev/sde    # id 3
ceph-deploy osd create ceph-osd01 --data /dev/sdf    # id 4

### 添加ceph-osd-node02主机上的相应磁盘
ceph-deploy osd create ceph-osd02 --data /dev/sdb    # id 5
ceph-deploy osd create ceph-osd02 --data /dev/sdc    # id 6
ceph-deploy osd create ceph-osd02 --data /dev/sdd    # id 7
ceph-deploy osd create ceph-osd02 --data /dev/sde    # id 8
ceph-deploy osd create ceph-osd02 --data /dev/sdf    # id 9

### 添加ceph-osd-node03主机上的相应磁盘
ceph-deploy osd create ceph-osd03 --data /dev/sdb    # id 10
ceph-deploy osd create ceph-osd03 --data /dev/sdc    # id 11
ceph-deploy osd create ceph-osd03 --data /dev/sdd    # id 12
ceph-deploy osd create ceph-osd03 --data /dev/sde    # id 13
ceph-deploy osd create ceph-osd03 --data /dev/sdf    # id 14
```

**查看ceph集群状态**
```
admin@ceph-mon01:~$ sudo ceph -s
  cluster:
    id:     2004f705-b556-4d05-9e73-7884379e07bb
    health: HEALTH_WARN
            mons are allowing insecure global_id reclaim
 
  services:
    mon: 3 daemons, quorum ceph-mon01,ceph-mon02,ceph-mon03 (age 38m)
    mgr: mgr1(active, since 20m), standbys: mgr2
    osd: 15 osds: 15 up (since 4s), 15 in (since 14s)
 
  data:
    pools:   1 pools, 1 pgs
    objects: 0 objects, 0 B
    usage:   4.3 GiB used, 1.5 TiB / 1.5 TiB avail
    pgs:     1 active+clean
```

**查看osd状态**
```
admin@ceph-mon01:~$ ceph osd stat
15 osds: 15 up (since 34m), 15 in (since 34m); epoch: e96
```

**显示osd的tree**
```
admin@ceph-mon01:~$ ceph osd tree
ID  CLASS  WEIGHT   TYPE NAME            STATUS  REWEIGHT  PRI-AFF
-1         1.46530  root default                                  
-3         0.48843      host ceph-osd01                           
 0    hdd  0.09769          osd.0            up   1.00000  1.00000
 1    hdd  0.09769          osd.1            up   1.00000  1.00000
 2    hdd  0.09769          osd.2            up   1.00000  1.00000
 3    hdd  0.09769          osd.3            up   1.00000  1.00000
 4    hdd  0.09769          osd.4            up   1.00000  1.00000
-5         0.48843      host ceph-osd02                           
 5    hdd  0.09769          osd.5            up   1.00000  1.00000
 6    hdd  0.09769          osd.6            up   1.00000  1.00000
 7    hdd  0.09769          osd.7            up   1.00000  1.00000
 8    hdd  0.09769          osd.8            up   1.00000  1.00000
 9    hdd  0.09769          osd.9            up   1.00000  1.00000
-7         0.48843      host ceph-osd03                           
10    hdd  0.09769          osd.10           up   1.00000  1.00000
11    hdd  0.09769          osd.11           up   1.00000  1.00000
12    hdd  0.09769          osd.12           up   1.00000  1.00000
13    hdd  0.09769          osd.13           up   1.00000  1.00000
14    hdd  0.09769          osd.14           up   1.00000  1.00000
```

### 2.2.5 解决HEALTH_WARN
**EALTH_WARN  mons are allowing insecure global_id reclaim**
```
cd $HOME/ceph-cluster
ceph config set mon  auth_allow_insecure_global_id_reclaim  false
```
**查看ceph集群状态**
```
admin@ceph-mon01:~$ sudo ceph -s
  cluster:
    id:     2004f705-b556-4d05-9e73-7884379e07bb
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum ceph-mon01,ceph-mon02,ceph-mon03 (age 40m)
    mgr: mgr1(active, since 22m), standbys: mgr2
    osd: 15 osds: 15 up (since 2m), 15 in (since 2m)
 
  data:
    pools:   1 pools, 1 pgs
    objects: 0 objects, 0 B
    usage:   4.3 GiB used, 1.5 TiB / 1.5 TiB avail
    pgs:     1 active+clean
```


## 2.3 部署ceph cluster子集组件
部署服务器(172.31.8.201 ceph-mon01)的admin用户下操作

### 2.3.1 相应主机上安装ceph-rgw并添加
当我们要让ceph来提供"对象存储"时，应该为了client（应用程序）在ceph cluster中安装RADOS Gateway（即：radosgw进程，默认端口7480），RADOS Gateway提供的是REST风格的API接口，client（应用程序）通http或https与其进行交互，完成数据的增删改等管理操作。
为了RADOS Gateway（即radosgw进程）的高可用，至少在两台服务器上分别部署radosgw进程。也可在其前面加上LB，这样client（应用程序）连接RADOS Gateway前面的LB即可。

**部署rados gateway**
```
cd $HOME/ceph-cluster    # 进入相应的目录
ceph-deploy install --rgw  --no-adjust-repos  --nogpgcheck  ceph-rgw01
ceph-deploy install --rgw  --no-adjust-repos  --nogpgcheck  ceph-rgw02
  #
  # 其中ceph-rgw01和ceph-rgw02是主机的连接地址,我的部署服务器上可以正向解析
  # 只要是安装软件，就可以一条命令指定多个Host
  # 会安装相应软件包(有radosgw命令)
  #
```

**初始化**
```
cd $HOME/ceph-cluster
ceph-deploy rgw  create  ceph-rgw01:rgw1
ceph-deploy rgw  create  ceph-rgw02:rgw2
  #
  # --overwrite-conf是ceph-deploy工具的参数,它表示会强制替换rados gateway host
  #   上的配置文件之/etc/ceph/ceph.conf。我这的rados gateway host是全新的。
  # rgw是关键字,即ceph-deploy工具的command，那么create是rgw命令的子命令。
  # rados gateway是可以同时初始化的，多个host时，用空格分隔。
  # 相应主机上radowgw进程的端口为7480,若你没有部署osd,则端口你是看不到的。
  #
```

**查看ceph集群状态**
```
admin@ceph-mon01:~$ sudo ceph -s
  cluster:
    id:     2004f705-b556-4d05-9e73-7884379e07bb
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum ceph-mon01,ceph-mon02,ceph-mon03 (age 62m)
    mgr: mgr1(active, since 44m), standbys: mgr2
    osd: 15 osds: 15 up (since 24m), 15 in (since 24m)
    rgw: 2 daemons active (2 hosts, 1 zones)
 
  data:
    pools:   5 pools, 129 pgs
    objects: 189 objects, 4.9 KiB
    usage:   4.3 GiB used, 1.5 TiB / 1.5 TiB avail
    pgs:     129 active+clean
 
  io:
    recovery: 36 B/s, 1 objects/s
```

### 2.3.2 相应主机上安装ceph-mds并添加
我们知道，若我们不用ceph的文件系统(cephfs)功能，我们是可以不用安装ceph-mds服务的哈。
**安装ceph-mds**
```
cd $HOME/ceph-cluster      # 进入到相应的目录
ceph-deploy install --mds --no-adjust-repos  --nogpgcheck ceph-mds01
ceph-deploy install --mds --no-adjust-repos  --nogpgcheck ceph-mds02
```

**初始化**
```
cd $HOME/ceph-cluster      # 进入到相应的目录
ceph-deploy  --overwrite-conf mds create ceph-mds01:mds1
ceph-deploy  --overwrite-conf mds create ceph-mds02:mds2

ceph-deploy  --overwrite-conf mds create ceph-mds01:mds3
ceph-deploy  --overwrite-conf mds create ceph-mds02:mds4
```

**查看集群状态**
```
admin@ceph-mon01:~$ sudo ceph -s   # 其services下看不到mds，是因为还没有文件系统(fs volume)
  cluster:
    id:     2004f705-b556-4d05-9e73-7884379e07bb
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum ceph-mon01,ceph-mon02,ceph-mon03 (age 68m)
    mgr: mgr1(active, since 49m), standbys: mgr2
    osd: 15 osds: 15 up (since 29m), 15 in (since 30m)
    rgw: 2 daemons active (2 hosts, 1 zones)
 
  data:
    pools:   5 pools, 129 pgs
    objects: 189 objects, 4.9 KiB
    usage:   4.3 GiB used, 1.5 TiB / 1.5 TiB avail
    pgs:     129 active+clean
```

**查看mds的状态**
```
admin@ceph-mon01:~$ sudo ceph mds stat
 4 up:standby
```


