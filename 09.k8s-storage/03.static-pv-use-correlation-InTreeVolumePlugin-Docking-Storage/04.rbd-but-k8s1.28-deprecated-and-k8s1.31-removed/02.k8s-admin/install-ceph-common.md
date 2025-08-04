01：在各worker node上安装ceph-common软件包,或者说是在wyc项目独享的
    worker node上安装安装ceph-common软件包.

02：不然当wyc项目各应用(Pod)被调用至相应worker node上后,在准备volume时,
    worker node上无法mount(没有客户端软件)。

03：安装ceph-common软件包
```
##添加ceph的源
  sudo apt-get update
  sudo chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow	
  sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common	
  	
  sudo wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -	
  	
  sudo apt-add-repository 'deb https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific/ focal main'	
  	
  sudo apt update	
  apt-cache madison ceph	

##安装ceph-common软件包
  apt install -y ceph-common
  which ceph rbd		
  ls -ld /etc/ceph/      # 就有此目录了
```

