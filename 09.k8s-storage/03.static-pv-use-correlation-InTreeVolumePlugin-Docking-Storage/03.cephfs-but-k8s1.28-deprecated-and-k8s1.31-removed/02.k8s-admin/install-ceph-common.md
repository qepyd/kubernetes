在各worker node上安装ceph-common软件包,或者说是在binbin项目独享的worker node上安装安装ceph-common软件包.不然
当binbin项目各应用(Pod)被调用至相应worker node上后,在准备volume时,worker node上无法mount(没有客户端软件)。
```
sudo apt update
sudo chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow
sudo apt install -y ceph-common
which ceph rbd
ls -ld /etc/ceph/      # 就有此目录了
```
