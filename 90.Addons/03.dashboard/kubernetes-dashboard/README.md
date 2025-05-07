# 1.kubernetes dashboard基本说明
```
基本介绍
  01:kubernetes dashboard 即 kubernetes集群通用的web ui。
  02:kubernetes dashboard
  kubernetes-dashboard 即 kubernetes组织(官方)维护的一个kubernetes集群通用web ui，
  其代码仓库为：https://github.com/kubernetes/dashboard

kubernetes 1.24 版本之前:
  01:kubernets代码仓库提供 kubernetes-dashboard 的manifests
     https://github.com/kubernetes/kubernetes/blob/v1.23.17/cluster/addons/dashboard/dashboard.yaml
  02:下载对应版本的Server Binaries，里面也包含 kubernetes-dashboard的manifests
     https://dl.k8s.io/v1.23.17/kubernetes-server-linux-amd64.tar.gz

kubernetes 1.24 版本开始:
  其kubernetes代码仓库不再提供kubernetes-dashboard的manifests
  相应Server Binaries中也不再包含 kubernetes-dashboard的manifests

kubernetes-dashboard的版本:
  01:v1.x.y、v2.x.y后直接到7.x.y
  02:而从7.x.y开始,其部署方式只支持使用helm工具部署
     


```
