# 1 安装ceph-common软件包
k8s所有worker node或binbin项目独占的worker node上安装
```
## 添加ceph的源
sudo apt-get update
sudo chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common

sudo wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -

sudo apt-add-repository 'deb https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific/ focal main'

sudo apt update
apt-cache madison ceph

## 安装ceph-common软件包
apt install -y ceph-common
which ceph rbd
ls -ld /etc/ceph/      # 就有此目录了
```

