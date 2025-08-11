在k8s的各控制平面、各worker node或lanlan项目相关的worker node上安装ceph-common软件包。
```
#### 添加ceph源，根据ceph集群的版本、worker node的版本
#<-- 安装基本工具
sudo apt-get update
sudo chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common

#<-- 添加ceph的仓库
sudo wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
sudo apt-add-repository 'deb https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific/ focal main'
  #
  # debian-pacific  # debian是指你的操作系统品牌，pacific是指ceph大版本的代号
  # focal          # 对应debian操作系统大版本的代号，它前面有空格的哈。
  #
sudo apt update
  #
  # 更新
  #

#### 安装ceph-comman软件包
#<-- 查看有哪些版本
sudo apt-cache madison ceph-common

#<-- 安装相应的版本
sudo chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow
sudo apt install -y --allow-downgrades  ceph-common=16.2.15-1focal

#<-- 安装后检查
which ceph rbd
ceph -v
rbd -v
ls -ld /etc/ceph/      # 就有此目录了
```

