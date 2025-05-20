# 1.基本说明
```
使用helm安装kubernetes组织的dashboard
  # 
  # 从 7.0.0 开始，仅支持基于 Helm 的安装方式。
  # 

我让kubernetes的dashboard的相关应用(Pod)始终都是部署到各master node上
  #
  # 我的k8s其各master node上有安装worker node的组件(ContainerRuntime、kubelet、kube-proxy、CNI)
  # 各master node具备标签
  #    node-role.kubernetes.io/control-plane  # 没有值
  # 各master node有两个污点
  #    node-role.kubernetes.io/control-plane:NoSchedule
  #    node-role.kubernetes.io/master:NoSchedule
  #

我让kubernetes的dashboard其web通过NodePort类型暴露,再通过k8s外部的LB再进行代理
  #
  # 参考相关目录(例如：./k8s-external-lb-the-nginx-expose/ ) 
  # 
```

# 2.使用helm工具离线安装kubernetes-dashboard-7.12.0
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
  --set web.service.type='NodePort'                                                                                                                                     \
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
  --set web.service.type='NodePort'                                                                                                                                     \
  --set metricsScraper.image.repository='swr.cn-north-1.myhuaweicloud.com/qepyd/k8s-dashboard-metrics-scraper'                                                          \
  --set metricsScraper.image.tag='1.2.2'                                                                                                                                \
  --set kong.enabled='false'                                                                                                                                            \
  ./kubernetes-dashboard/

## kubectl工具在线非交互式修改ns/kubernetes-dashboard中其svc/kubernetes-dashboard-web  spec.ports下为0列表中nodePort的端口为30000(我规划的)
kubectl -n kubernetes-dashboard  get svc/kubernetes-dashboard-web
kubectl -n kubernetes-dashboard  patch svc kubernetes-dashboard-web -p '[{"op": "replace", "path": "/spec/ports/0/nodePort", "value": 30000}]' --type='json'
kubectl -n kubernetes-dashboard  get svc/kubernetes-dashboard-web

## 列出相关的Release
helm -n kubernetes-dashboard  list 
  #
  # 卸载相关的Release的展示
  #   helm -n kubernetes-dashboard  uninstall  kubernetes-dashboard
  # 

## 列出相关的资源对象
kubectl -n kubernetes-dashboard get sa,role,rolebinding,secrets,cm,deploy,svc
kubectl                         get clusterrole,clusterrolebinding | grep kubernetes-dashboard
```

# 3.k8s外部代理的配置
```
## nginx
参考 ./k8s-external-lb-the-nginx-proxy/ 目录
```
