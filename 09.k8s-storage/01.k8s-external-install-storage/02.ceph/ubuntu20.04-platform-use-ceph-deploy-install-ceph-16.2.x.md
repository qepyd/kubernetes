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
### 1.2.1 设置主机名
参考 1.1 章节中 "ceph集群的服务器"
```
hostnamectl set-hostname <HostName>
```

### 1.2.2 DNS解析(/etc/hosts)
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

### 1.2.3 更新apt源
```
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




