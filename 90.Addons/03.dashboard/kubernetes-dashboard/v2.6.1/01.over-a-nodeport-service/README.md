# 1.下载相应的manifests
```
## 来源地
https://github.com/kubernetes/dashboard/releases/tag/v2.6.1

## 下载manifests
wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml
```

# 2.相关manifests的基本修改
```
## 所用namespace
root@master01:/qepyd/kubernetes/90.Addons/03.dashboard/kubernetes-dashboard/v2.6.1# grep "namespace" recommended.yaml  | sort  | uniq
            - --namespace=kubernetes-dashboard
    namespace: kubernetes-dashboard
  namespace: kubernetes-dashboard

## 是否包含ns/kubernetes-dashboard的manifests, 结果是包含的
root@master01:/qepyd/kubernetes/90.Addons/03.dashboard/kubernetes-dashboard/v2.6.1# grep -A 3 "^kind: Namespace" recommended.yaml 
kind: Namespace
metadata:
  name: kubernetes-dashboard

## 将ns/kubernetes-dashboard对象的manifests给注释掉
为了安全考滤,ns资源对象的manifests应该存在于一个单独的文件中

## 所用到的image
root@master01:/qepyd/kubernetes/90.Addons/03.dashboard/kubernetes-dashboard/v2.6.1# grep image: recommended.yaml 
          image: kubernetesui/dashboard:v2.6.1
          image: kubernetesui/metrics-scraper:v1.0.8
root@master01:/qepyd/kubernetes/90.Addons/03.dashboard/kubernetes-dashboard/v2.6.1# grep kubernetesui recommended.yaml 
          image: kubernetesui/dashboard:v2.6.1
          image: kubernetesui/metrics-scraper:v1.0.8

## pull image-->tag image -->push image至自己的私有仓库
............我已将其push到我自己的私有仓库(公开,国内互联网可访问)
swr.cn-north-1.myhuaweicloud.com/qepyd/dashboard:v2.6.1
swr.cn-north-1.myhuaweicloud.com/qepyd/metrics-scraper:v1.0.8

## 修改manifests中的镜像
sed    's#kubernetesui/dashboard:v2.6.1#swr.cn-north-1.myhuaweicloud.com/qepyd/dashboard:v2.6.1#g'  recommended.yaml | grep image:
sed -i 's#kubernetesui/dashboard:v2.6.1#swr.cn-north-1.myhuaweicloud.com/qepyd/dashboard:v2.6.1#g'  recommended.yaml

sed    's#kubernetesui/metrics-scraper:v1.0.8#swr.cn-north-1.myhuaweicloud.com/qepyd/metrics-scraper:v1.0.8#g' recommended.yaml | grep image:
sed -i 's#kubernetesui/metrics-scraper:v1.0.8#swr.cn-north-1.myhuaweicloud.com/qepyd/metrics-scraper:v1.0.8#g' recommended.yaml
```

# 3.相关manifests的按需修改
```
## 我想让deploy/kubernetes-dashboard只能被调度至各master(当然得安装有worker node的相关组件,否则不要操作)
A:修改deploy/kubernetes-dashboard的manifests(让其能够容忍master上其NoSchedule效果的所有污点)
  默认容忍的是 node-role.kubernetes.io/master  NoSchedule 污点，即deploy.spec.template.spec.tolerations字段
      tolerations:
        - key: node-role.kubernetes.io/master
          effect: NoSchedule
Ac:将其修改成容忍各master上的上NoSchedule效果的相关污点(我的各master上有如下两个污点)
      tolerations:
        - key: node-role.kubernetes.io/control-plane
          effect: NoSchedule
        - key: node-role.kubernetes.io/master
          effect: NoSchedule

B: 修改deploy/kubernetes-dashboard的manifests(让能只能够被调度至各master上，当然你的各master得有安装worker node组件,否则不要操作)
   默认使用nodeSelector匹配"kubernetes.io/os": linux标签。
      nodeSelector:
        "kubernetes.io/os": linux
Bc:将其nodeSelector给注释掉，使用节点亲和之硬亲和方式
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: node-role.kubernetes.io/control-plane
                operator: Exists

## 我想让deploy/dashboard-metrics-scraper只能被调度至各master(当然得安装有worker node的相关组件,否则不要操作)
.............参考 deploy/kubernetes-dashboard其manifests的修改


## 我想让其以NodePort方式暴露出kubernetes,其nodePort规划占用30000，跟上述的修改没有关系。
修改svc/kubernetes-dashboard对象，默认为ClusterIP类型。修改后的整体展示如下
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  # 修改成NodePort类型
  type: NodePort
  ports:
    - port: 443
      targetPort: 8443
      # 与NodePort类型配套,规划占用30000
      nodePort: 30000
  selector:
    k8s-app: kubernetes-dashboard
```

# 4.应用manifests
```
## 应用manifests
kubectl apply -f recommended.yaml --dry-run=client
kubectl apply -f recommended.yaml 

## 列出相平面资源对象
kubectl get -f recommended.yaml
```

# 5.访问测试一下
```
https://172.31.7.201:30000
https://任何一个node的NodeIP:30000
```

# 6.k8s外部LB的配置
```
## Nginx
参考 ./k8s-external-lb-the-nginx-expose/ 目录 
```
