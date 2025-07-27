# 1 服务的服务器
这里使用"k8s学习环境"的master01服务器。  
https://github.com/qepyd/kubernetes/blob/main/01.k8s-study-env-install/kubeadm-ubuntu20.04-install-kubernetes1.24.4-and-containerd.md
```
操作系统     IP地址        主机名
ubuntu20.04  172.31.7.203  master01
```

# 2 安装nfs-server
```
apt update
apt install nfs-server -y
systemctl status      status nfs-server.service 
systemctl enable      status nfs-server.service
systemctl is-enabled  status nfs-server.service
```

# 3 expose相关目录的方式(这里正好做一下测试)
```
## 创建/data/test/目录,这个目录是给wyc项目的相关应用所使用的
mkdir -p /data/test/

## nfs expose暴露相关目录
01:在/etc/exports中添加02步骤的内容保存退出
02:/data/test *(rw,sync,no_subtree_check,no_root_squash)

## 检查是否成功暴露出
root@master01:~# exportfs -arv
exporting *:/data/test

## 本机(有nfs client的)做一下挂载测试
mkdir /test/
ls -ld /test/

mount -t nfs 172.31.7.203:/data/test/  /test/                 # 挂载
df -h 

touch /test/a.txt                                             # 挂载目录下创建文件
ls -l /test/a.txt                                             # 列出所创建的文件

ls -l /data/test/a.txt                                        # 查看nfs中是否有

find  /test/ -maxdepth 1 -type f -name "a.txt"                
find  /test/ -maxdepth 1 -type f -name "a.txt" | xargs rm -f  # 删除挂载目录下前面挂载的文件 

umount /test/                                                 # 取消挂载
df -h
```
