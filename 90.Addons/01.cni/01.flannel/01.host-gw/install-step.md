# 1.Flannel之host-gw后端的相关说明
## 1.1 平面图
<image src="./picture/flannel-host-gw-plan.jpg" style="width: 100%; height: auto;">


## 1.2.k8s上各Worker Node上的路由
**node01上的路由**
```
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.0.0.0        0.0.0.0         255.255.255.0   U     0      0        0 cni0
10.0.1.0        172.31.0.2      255.255.255.0   UG    0      0        0 eth0
10.0.2.0        172.31.0.3      255.255.255.0   UG    0      0        0 eth0
............    ..............  255.255.255.0   UG    0      0        0 eth0
............    ..............  255.255.255.0   UG    0      0        0 eth0
10.255.254.0    172.31.255.254  255.255.255.0   UG    0      0        0 eth0

0.0.0.0         172.31.255.255  0.0.0.0         UG    0      0        0 eth0
172.31.0.0      0.0.0.0         255.255.0.0     U     0      0        0 eth0
```

**node02上的路由**
```
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.0.2.0        0.0.0.0         255.255.255.0   UG    0      0        0 cni0
10.0.1.0        172.31.0.1      255.255.255.0   UG    0      0        0 eth0
10.0.3.0        172.31.0.3      255.255.255.0   UG    0      0        0 eth0
............    ..............  255.255.255.0   UG    0      0        0 eth0
............    ..............  255.255.255.0   UG    0      0        0 eth0
10.255.254.0    172.31.255.254  255.255.255.0   UG    0      0        0 eth0

0.0.0.0         172.31.255.255  0.0.0.0         UG    0      0        0 eth0
172.31.0.0      0.0.0.0         255.255.0.0     U     0      0        0 eth0
```

## 1.3.同宿主机上Pod间的通信
注意：直接通过cni0网关就进行转发了
<image src="./picture/SameHost-Pod-to-Pod-Communication.jpg" style="width: 100%; height: auto;">

## 1.4.跨宿主机(处于同一网关,L2网络)间Pod的通信
注意：通过主机间的路由。另外，Flannel host-gw后端，各worker node上不存在隧道设备flannel.1。
<image src="./picture/CoressHost-Pod-to-Pod-Communication.jpg" style="width: 100%; height: auto;">

## 1.5.跨宿主机(处于不同网关,L3网络)间Pod的通信
注意：不能通信
