## 1.基本说明
```
为每个项目部署其专有的ingress controller之ingress-nginx。
因为：kubernetes中可以存在多个ingress controller
```

## 2.创建ns/wyc-ingress-controller对象
```
wyc项目所用ingress controller部署时使用的namespace。

kubectl apply -f ./01.ns_wyc-ingress-controller.yaml --dry-run=client
kubectl apply -f ./01.ns_wyc-ingress-controller.yaml
```

## 3.wyc项目所用worker node打上标签
```
# kubectl label nodes/node01 nodes/node02 project=wyc
# kubectl get   nodes -l project=wyc --show-labels -o wide
``` 

## 4.下载ingress-controller的manifests
```
wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/refs/tags/controller-v1.8.4/deploy/static/provider/baremetal/deploy.yaml -P ./ -O ./02.wyc-ingress-nginx.yaml
ls -l  ./02.wyc-ingress-nginx.yaml
```

## 5.对 4步骤 下载的manifests 进行基本的修改
```
## 注释掉ns/ingress-nginx对象的manifests
  .............................
  .............................

## 修改其所使用的ns资源对象
  # <----查看其所用的namespace是
  ====># grep namespace: 02.wyc-ingress-nginx.yaml  | sort | uniq
      namespace: ingress-nginx
  namespace: ingress-nginx

  # <----修改其namespace为ns/wyc-ingress-controller
  sed    's#namespace: ingress-nginx#namespace: wyc-ingress-controller#g' ./02.wyc-ingress-nginx.yaml  | grep "namespace:"
  sed -i 's#namespace: ingress-nginx#namespace: wyc-ingress-controller#g' ./02.wyc-ingress-nginx.yaml


## 修改image为自己的私有仓库上的
  # <----查看用到了哪些image
  ====># grep "image:" 02.wyc-ingress-nginx.yaml | sort  | uniq 
     image: registry.k8s.io/ingress-nginx/controller:v1.8.4@sha256:8d8ddf32b83ca3e74bd5f66369fa60d85353e18ff55fa7691b321aa4716f5ba9
     image: registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20231011-8b53cabe0@sha256:a7943503b45d552785aa3b5e457f169a5661fb94d82b8a3373bcd9ebaf9aac80
  
  ====># grep "registry.k8s.io" 02.wyc-ingress-nginx.yaml  | sort  | uniq
     image: registry.k8s.io/ingress-nginx/controller:v1.8.4@sha256:8d8ddf32b83ca3e74bd5f66369fa60d85353e18ff55fa7691b321aa4716f5ba9
     image: registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20231011-8b53cabe0@sha256:a7943503b45d552785aa3b5e457f169a5661fb94d82b8a3373bcd9ebaf9aac80

  # <----修改相应的image(我已将image放我国内私有仓库并公开)
  sed   's#registry.k8s.io/ingress-nginx/controller:v1.8.4@sha256:8d8ddf32b83ca3e74bd5f66369fa60d85353e18ff55fa7691b321aa4716f5ba9#swr.cn-north-1.myhuaweicloud.com/qepyd/ingress-nginx-controller:v1.8.4#g' 02.wyc-ingress-nginx.yaml
  sed -i 's#registry.k8s.io/ingress-nginx/controller:v1.8.4@sha256:8d8ddf32b83ca3e74bd5f66369fa60d85353e18ff55fa7691b321aa4716f5ba9#swr.cn-north-1.myhuaweicloud.com/qepyd/ingress-nginx-controller:v1.8.4#g' 02.wyc-ingress-nginx.yaml
 
  sed  's#registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20231011-8b53cabe0@sha256:a7943503b45d552785aa3b5e457f169a5661fb94d82b8a3373bcd9ebaf9aac80#swr.cn-north-1.myhuaweicloud.com/qepyd/ingress-nginx-kube-webhook-certgen:v20231011-8b53cabe0#g' 02.wyc-ingress-nginx.yaml
  sed -i 's#registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20231011-8b53cabe0@sha256:a7943503b45d552785aa3b5e457f169a5661fb94d82b8a3373bcd9ebaf9aac80#swr.cn-north-1.myhuaweicloud.com/qepyd/ingress-nginx-kube-webhook-certgen:v20231011-8b53cabe0#g' 02.wyc-ingress-nginx.yaml
 
```

## 对 4步骤 下载的manifests 进行关键修改(背景为 1步骤)  
```


```



## 5.wyc项目专用的ingress-nginx部署后验证
```
# ValidatingWebhookConfiguration对象
root@master01:~# kubectl get ValidatingWebhookConfiguration
NAME                          WEBHOOKS   AGE
wyc-ingress-nginx-admission   1          7m33s

# ingressclass资源对象
root@master01:~# kubectl get ingressclass
NAME                CONTROLLER                 PARAMETERS   AGE
wyc-ingress-nginx   k8s.io/wyc-ingress-nginx   <none>       4m27s

# svc资源对象,ds资源对象,pods资源对象
root@master01:~# kubectl -n wyc-ingress-nginx get svc
NAME                                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             NodePort    10.144.240.11   <none>        80:30000/TCP,443:30001/TCP   45s
ingress-nginx-controller-admission   ClusterIP   10.144.3.248    <none>        443/TCP                      45s
    #
    # 各主机上均有相应的规则,以ipvs的为例，以NodePort的为例
    #   NodeInterIp=$(ifconfig eth0 | awk -F " " 'NR==2{print $2}')
    #   ipvsadm -L -n | grep -A 1 $NodeInterIp:30000
    #   ipvsadm -L -n | grep -A 1 $NodeInterIp:30001
    # 那么k8s集群外的LB其相关虚拟主机的后端可以是
    #   任何woker node的IP:30000/300001
    #   你也可以只为wyc的相关虚拟主机指定wyc相关的worker node
    #
root@master01:~# kubectl -n wyc-ingress-nginx get pods -o wide | grep ingress-nginx-controller
ingress-nginx-controller-5d6d48cc68-9lvlw   1/1     Running     0          91s   10.244.3.54   node01   <none>           <none>

# 定时任务及相应的pods
root@master01:~# kubectl -n wyc-ingress-nginx get jobs 
NAME                             COMPLETIONS   DURATION   AGE
ingress-nginx-admission-create   1/1           4s         5m5s
ingress-nginx-admission-patch    1/1           5s         5m5s

root@master01:~# kubectl -n wyc-ingress-nginx get pods | grep ingress-nginx-admission-create 
ingress-nginx-admission-create-kblcf   0/1     Completed   0          5m38s

root@master01:~# kubectl -n wyc-ingress-nginx get pods | grep ingress-nginx-admission-patch
ingress-nginx-admission-patch-skqsf    0/1     Completed   0          5m47s
```
