# 1.下载manifests
```
wget https://raw.githubusercontent.com/flannel-io/flannel/v0.22.3/Documentation/kube-flannel.yml
ls -l  https://raw.githubusercontent.com/flannel-io/flannel/v0.22.3/Documentation/kube-flannel.yml
```

# 2.manifests中相关说明及修改
```
## 所用ns资源对象为，让其保持不变
root@master01:/qepyd/kubernetes/90.Addons/01.cni/flannel/v0.22.3# grep -A 3 "^kind: Namespace" kube-flannel.yml 
kind: Namespace
apiVersion: v1
metadata:
  name: kube-flannel

## 所用image为
root@master01:/qepyd/kubernetes/90.Addons/01.cni/flannel/v0.22.3# grep image: kube-flannel.yml 
        image: docker.io/flannel/flannel-cni-plugin:v1.2.0
        image: docker.io/flannel/flannel:v0.22.3
        image: docker.io/flannel/flannel:v0.22.3
root@master01:/qepyd/kubernetes/90.Addons/01.cni/flannel/v0.22.3#
root@master01:/qepyd/kubernetes/90.Addons/01.cni/flannel/v0.22.3# grep docker.io kube-flannel.yml 
        image: docker.io/flannel/flannel-cni-plugin:v1.2.0
        image: docker.io/flannel/flannel:v0.22.3
        image: docker.io/flannel/flannel:v0.22.3


## pull --> tag-->push
.......................
我已将相关镜像push到个人的私有仓库中并公开(pull时不需要认证)
swr.cn-north-1.myhuaweicloud.com/qepyd/flannel-cni-plugin:v1.2.0
swr.cn-north-1.myhuaweicloud.com/qepyd/flannel:v0.22.3


## 修改image，我已将相关镜像放在我自己的私有仓库中并公开
sed -i 's#docker.io/flannel/flannel-cni-plugin:v1.2.0#swr.cn-north-1.myhuaweicloud.com/qepyd/flannel-cni-plugin:v1.2.0#g'  kube-flannel.yml
sed -i 's#docker.io/flannel/flannel:v0.22.3#swr.cn-north-1.myhuaweicloud.com/qepyd/flannel:v0.22.3#g'   kube-flannel.yml 
grep image: kube-flannel.yml 


## 确认flannel所用的网络模式及Pod网络
ConfigMpa/kube-flannel-cfg对象
   data字段中其net-conf.json键对应的value中的相关参数
      Network 
         用于指定Pod网络，默认为 10.244.0.0/16，根据自己kubernetes的规范来定.
         可查看kube-container-manager组件其 --cluster-cidr 参数的值
      SubnetLen
         用于指定Pod网络所划分子网其子网掩码长度,默认24
      Backend
         type 用于指定网络模式，默认vxlan，还支持 host-gw
         若 DirectRouting 存在且为true时，其type只能是value,那么模式就是vxlan和host-gw的结合体
``` 

# 3.应用manifests
```
kubectl apply -f kube-flannel.yml
kubect -n kube-flannel get sa,cm,ds
kubectl                get ClusterRole,ClusterRoleBinding | grep flannel 
```
