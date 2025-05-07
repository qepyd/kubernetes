# 1.基本说明
```
使用helm安装kubernetes组织的dashboard
  # 
  # 从 7.0.0 开始，仅支持基于 Helm 的安装方式。
  # 

kubernetes的dashboard只让其部署到各master node上
  #
  # 各master node上有安装worker node的组件
  # 各master node具备标签
  #    node-role.kubernetes.io/control-plane  # 没有值
  # 各master node有两个污点
  #    node-role.kubernetes.io/control-plane:NoSchedule
  #    node-role.kubernetes.io/master:NoSchedule
  #

kubernetes的dashboard通过ingress-controller进行暴露
  #
  # 参考 ./expose/ 目录下的相关子目录
  # 
```

# 2.创建ns/kubernetes-dashboard对象
```
返回上一级目录，应用 ns_kubernetes-dashboard.yaml 文件
```

# 3.使用helm工具安装
```
## 下载相关版本的chart到本地,并解压
  wget https://github.com/kubernetes/dashboard/releases/download/kubernetes-dashboard-7.12.0/kubernetes-dashboard-7.12.0.tgz
  ls -l kubernetes-dashboard-7.12.0.tgz

  tar xf ./kubernetes-dashboard-7.12.0.tgz -C ./
  ls -ld ./kubernetes-dashboard

## 使用helm工具进行安装(模拟安装)
helm -n kubernetes-dashboard  install  kubernetes-dashboard   \
  --set app.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key='node-role.kubernetes.io/control-plane',  \
  --set app.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator='Exists'                             \
  --set app.tolerations[0].key='node-role.kubernetes.io/control-plane',                                                                                                 \
  --set app.tolerations[0].operator='Exists'                                                                                                                            \
  --set app.tolerations[1].key='node-role.kubernetes.io/master',                                                                                                        \
  --set app.tolerations[1].operator='Exists'                                                                                                                            \
  --set api.image.repository='swr.cn-north-1.myhuaweicloud.com/qepyd/k8s-dashboard-api'                                                                                 \
  --set api.image.tag='1.12.0'                                                                                                                                          \
  --set auth.image.repository='swr.cn-north-1.myhuaweicloud.com/qepyd/k8s-dashboard-auth'                                                                               \
  --set auth.image.tag='1.2.4'                                                                                                                                          \
  --set web.image.repository='swr.cn-north-1.myhuaweicloud.com/qepyd/k8s-dashboard-web'                                                                                 \
  --set web.image.tag='1.6.2'                                                                                                                                           \
  --set metricsScraper.image.repository='swr.cn-north-1.myhuaweicloud.com/qepyd/k8s-dashboard-metrics-scraper'                                                          \
  --set metricsScraper.image.tag='1.2.2'                                                                                                                                \
  --set kong.enabled='false'                                                                                                                                            \
  ./kubernetes-dashboard/  --dry-run

   
## 使用helm工具进行安装
helm -n kubernetes-dashboard  install  kubernetes-dashboard   \
  --set app.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key='node-role.kubernetes.io/control-plane',  \
  --set app.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator='Exists'                             \
  --set app.tolerations[0].key='node-role.kubernetes.io/control-plane',                                                                                                 \
  --set app.tolerations[0].operator='Exists'                                                                                                                            \
  --set app.tolerations[1].key='node-role.kubernetes.io/master',                                                                                                        \
  --set app.tolerations[1].operator='Exists'                                                                                                                            \
  --set api.image.repository='swr.cn-north-1.myhuaweicloud.com/qepyd/k8s-dashboard-api'                                                                                 \
  --set api.image.tag='1.12.0'                                                                                                                                          \
  --set auth.image.repository='swr.cn-north-1.myhuaweicloud.com/qepyd/k8s-dashboard-auth'                                                                               \
  --set auth.image.tag='1.2.4'                                                                                                                                          \
  --set web.image.repository='swr.cn-north-1.myhuaweicloud.com/qepyd/k8s-dashboard-web'                                                                                 \
  --set web.image.tag='1.6.2'                                                                                                                                           \
  --set metricsScraper.image.repository='swr.cn-north-1.myhuaweicloud.com/qepyd/k8s-dashboard-metrics-scraper'                                                          \
  --set metricsScraper.image.tag='1.2.2'                                                                                                                                \
  --set kong.enabled='false'                                                                                                                                            \
  ./kubernetes-dashboard/


## 列出相关的Release
helm -n kubernetes-dashboard  list 

## 列出相关的资源对象
kubectl -n kubernetes-dashboard get sa,role,rolebinding,secrets,cm,deploy,svc
kubectl                         get clusterrole,clusterrolebinding | grep kubernetes-dashboard
```
