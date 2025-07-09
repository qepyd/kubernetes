# 1.kubernetes的dashboard 
```
01:kubernetes dashboard 即 kubernetes集群通用的WEB UI。
02:一套kubernetes有一套WEB UI即可，列如：使用kubernetes组织的dashboard
03:多套kubernetes有一套WEB UI即可，例如：使用kubesphere组织的dashboard
```

# 2.我的kubernetes学习环境
```
## k8s外部LB的vip为
  172.31.7.114   # 此vip只要能够与k8s各node的INTERNAL-IP通信即可

## k8s的相关nodes
root@master01:~# kubectl get nodes  -o wide
NAME       STATUS   ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master01   Ready    control-plane   39h   v1.24.3   172.31.7.201   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   docker://28.1.1
master02   Ready    control-plane   39h   v1.24.3   172.31.7.202   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   docker://28.1.1
master03   Ready    control-plane   39h   v1.24.3   172.31.7.203   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   docker://28.1.1
node01     Ready    <none>          38h   v1.24.3   172.31.7.204   <none>        Ubuntu 20.04.4 LTS   5.4.0-215-generic   docker://28.1.1
node02     Ready    <none>          38h   v1.24.3   172.31.7.205   <none>        Ubuntu 20.04.4 LTS   5.4.0-215-generic   docker://28.1.1
node03     Ready    <none>          38h   v1.24.3   172.31.7.206   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   docker://28.1.1

## k8s的各master安装有worker node相关组件、插件
ContainerRuntime、kubelet、kube-proxy、CNI
```
