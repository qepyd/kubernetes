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

更新时间的脚本
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
```

添加定时任务
```
cat >>/var/spool/cron/crontabs/root<<EOF

## crond update os time
*/05 * * * * /bin/bash  /opt/scripts/update_os_time.sh >/dev/null 2>&1
EOF

## 检查
crontab -u root -l
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
注意：ceph monitor一定是要先部署的哈。至少1个，要想高可用的话，至少得3个。
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

## 查看ceph的状态
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

### 2.2.2 集群状态查看(分发密钥、推送配置文件)
这里我要在部署服务器（ceph-mon01）的admin用户下，将ceph cluster其超级用户client.admin的keyring文件（ceph.client.admin.keyring）分发到ceph-mon02、ceph-mon03主机上（有/etc/ceph/目录、有ceph命令、还有ceph cluster的配置文件conf)。
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

### 2.2.3 部署ceph cluster子集组件




