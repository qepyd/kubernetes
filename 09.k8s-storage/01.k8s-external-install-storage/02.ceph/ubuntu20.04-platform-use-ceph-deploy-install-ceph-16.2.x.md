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
操作系统      主机名        IP地址         系统盘     数据盘                       角色/软件
ubuntu 20.04  ceph-mon01    172.31.8.201   /dev/sda   -                            部署服务器/ceph-mon
ubuntu 20.04  ceph-mon02    172.31.8.202   /dev/sda   -                            -/ceph-mon
ubuntu 20.04  ceph-mon03    172.31.8.203   /dev/sda   -                            -/ceph-mon

ubuntu 20.04  ceph-mgr01    172.31.8.204   /dev/sda   -                            -/ceph-mgr
ubuntu 20.04  ceph-mgr02    172.31.8.205   /dev/sda   -                            -/ceph-mgr
 
ubuntu 20.04  ceph-mds01    172.31.8.206   /dev/sda   -                            -/ceph-mds
ubuntu 20.04  ceph-mds02    172.31.8.207   /dev/sda   -                            -/ceph-mds

ubuntu 20.04  ceph-rgw01    172.31.8.208   /dev/sda   -                            -/ceph-rgw
ubuntu 20.04  ceph-rgw02    172.31.8.209   /dev/sda   -                            -/ceph-rgw

ubuntu 20.04  ceph-osd01    172.31.8.210   /dev/sda   /dev/sdb至/dev/sdf，各100G   -/ceph-osd
ubuntu 20.04  ceph-osd02    172.31.8.211   /dev/sda   /dev/sdb至/dev/sdf，各100G   -/ceph-osd
ubuntu 20.04  ceph-osd03    172.31.8.212   /dev/sda   /dev/sdb至/dev/sdf，各100G   -/ceph-osd
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

## 1.3 部署服务器安装部署工具ceph-deploy
部署服务器为(172.31.8.201   ceph-mon01)
```

```


# 2 部署服务器上部署ceph集群
## 2.1 为new cluster生成默认配置

## 2.2 部署ceph的Rados Cluster

## 2.3 部署ceph cluster子集组件




