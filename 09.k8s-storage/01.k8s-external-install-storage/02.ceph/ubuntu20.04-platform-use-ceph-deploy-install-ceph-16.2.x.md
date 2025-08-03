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


### 1.2.4 各主机上设置ceph的源
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

```



### 1.2.5 各主机上安装Python 2.7
```
sudo apt update
sudo chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow 
sudo apt-cache madison python2.7
sudo apt install -y python2.7

sudo ln -svf /usr/bin/python2.7 /usr/bin/python2
sudo which python2
```

### 1.2.6 定时更新系统时间

### 1.2.7 创建特权用户admin

 


## 1.3 部署服务器安装部署工具ceph-deploy
部署服务器为(172.31.8.201   ceph-mon01)
```

```


# 2 部署服务器上部署ceph集群
## 2.1 为new cluster生成默认配置

## 2.2 部署ceph的Rados Cluster

## 2.3 部署ceph cluster子集组件




