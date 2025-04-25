# 1.基本说明
```
为每个项目部署其专有的ingress controller之ingress-nginx。
因为：kubernetes中可以存在多个ingress controller

ingress controller之ingress-nginx安装后其暴露的方式可以有：
  01:某项目的ingress-nginx使用Daemonset + nodeSelector匹配专属的worker node上的标签：
      共享宿主机的Network，会占用宿主机的80和443端口
      k8s外部LB中的某虚拟主机的上流端点即专属worker node的内部IP:80/443
      即：通过主机网络 暴露
  02:某项目的ingress-nginx使用Deployment + nodeSelector匹配专属worker node上的标签:
      不共享宿主机的Network
      使用NodePort类型的svc暴露,其nodePort你得规划并固定
      k8s外部LB中的某虚拟主机的上流端点即专属worker node的内部IP:nodePort(80、443相对应的)
      即：通过NodePort类型的svc
  03:某项目的ingress-nginx使用Deploy + nodeSelector匹配专属的worker node上的标签：
      不共享宿主机的Netwok
      官方不建议：使用LoadBalancer类型的方式暴露。
      即：external-ips

PS：后面即 通过主机网络 暴露 
```

# 2.当前kubernetes的各woker node
```
root@master01:~# kubectl get nodes -o wide
NAME       STATUS   ROLES           AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master01   Ready    control-plane   208d   v1.24.3   172.31.7.109   <none>        Ubuntu 20.04.4 LTS   5.4.0-196-generic   docker://20.10.24
master02   Ready    control-plane   208d   v1.24.3   172.31.7.202   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   docker://20.10.24
master03   Ready    control-plane   208d   v1.24.3   172.31.7.203   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   docker://20.10.24
node01     Ready    <none>          208d   v1.24.3   172.31.7.204   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   docker://20.10.24
node02     Ready    <none>          208d   v1.24.3   172.31.7.205   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   docker://20.10.24
node03     Ready    <none>          208d   v1.24.3   172.31.7.206   <none>        Ubuntu 20.04.4 LTS   5.4.0-100-generic   docker://20.10.24

```

# 3.假设wyc项目专属的worker node为node01、node02
```
给node01、node02打上相应的标签

kubectl label nodes/node01  nodes/node02 project=wyc
kubectl get   nodes -l project=wyc --show-labels -o wide
```

# 4.创建ns/wyc-ingress-controller对象
```
wyc项目专用ingress controller部署时使用的namespace。

kubectl apply -f ./01.ns_wyc-ingress-controller.yaml --dry-run=client
kubectl apply -f ./01.ns_wyc-ingress-controller.yaml
```

# 5.下载ingress-controller的manifests
```
## 参考：
   https://github.com/kubernetes/ingress-nginx/blob/controller-v1.8.4/deploy/static/provider/baremetal/deploy.yaml

## 下载
  wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/refs/tags/controller-v1.8.4/deploy/static/provider/baremetal/deploy.yaml -P ./ -O ./02.wyc-ingress-nginx.yaml
  ls -l  ./02.wyc-ingress-nginx.yaml
```

# 6.对 5步骤 下载的manifests 进行基本修改一
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
  sed   's#registry.k8s.io/ingress-nginx/controller:v1.8.4@sha256:8d8ddf32b83ca3e74bd5f66369fa60d85353e18ff55fa7691b321aa4716f5ba9#swr.cn-north-1.myhuaweicloud.com/qepyd/ingress-nginx-controller:v1.8.4#g' 02.wyc-ingress-nginx.yaml  | grep image:
  sed -i 's#registry.k8s.io/ingress-nginx/controller:v1.8.4@sha256:8d8ddf32b83ca3e74bd5f66369fa60d85353e18ff55fa7691b321aa4716f5ba9#swr.cn-north-1.myhuaweicloud.com/qepyd/ingress-nginx-controller:v1.8.4#g' 02.wyc-ingress-nginx.yaml
 
  sed  's#registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20231011-8b53cabe0@sha256:a7943503b45d552785aa3b5e457f169a5661fb94d82b8a3373bcd9ebaf9aac80#swr.cn-north-1.myhuaweicloud.com/qepyd/ingress-nginx-kube-webhook-certgen:v20231011-8b53cabe0#g' 02.wyc-ingress-nginx.yaml  | grep image:
  sed -i 's#registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20231011-8b53cabe0@sha256:a7943503b45d552785aa3b5e457f169a5661fb94d82b8a3373bcd9ebaf9aac80#swr.cn-north-1.myhuaweicloud.com/qepyd/ingress-nginx-kube-webhook-certgen:v20231011-8b53cabe0#g' 02.wyc-ingress-nginx.yaml
 
```


# 7.对 5步骤 下载的manifests 进行基本修改二
```
修改Deployment/ingress-nginx-controller对象

   将其修改成 DaemonSet/ingress-nginx-controller

   其spec.template.spec字段中新增 
      hostNetwork: true  
      nodeSelector:
        project: wyc
      注意：原原有的nodeSelector字段给注释掉

   其spec.template.spec.containers.args字段中相关参数进行修改
      修改 --ingress-class=nginx 成 --ingress-class=wyc-nginx  
         关联修改IngressClass/nginx对象
             将其修改成 IngressClass/wyc-nginx
      注释 --publish-service=$(POD_NAMESPACE)/ingress-nginx-controller 如果有的放 
         关联修改Service/ingress-nginx-controller对象
             将其完全注释掉


修改ClusterRole/ingress-nginx对象
   将其修改成ClusterRole/wyc-ingress-nginx

修改ClusterRoleBinding/ingress-nginx对象
   将其修改成ClusterRoleBinding/wyc-ingress-nginx
   roleRef.name字段的ingress-nginx修改成 wyc-ingress-nginx


修改ClusterRole/ingress-nginx-admission对象
   将其修改成ClusterRole/wyc-ingress-nginx-admission

修改ClusterRoleBinding/ingress-nginx-admission对象
   将其修改成ClusterRoleBinding/wyc-ingress-nginx-admission
   roleRef.name字段的ingress-nginx-admission修改成 wyc-ingress-nginx-admission 


修改ValidatingWebhookConfiguration/ingress-nginx-admission对象
   将其修改成 ValidatingWebhookConfiguration/wyc-ingress-nginx-admission 
   其webhooks.admissionReviewVersions字段同级别添加如下信息
     # 名称空间限制,让此资源对象只对相应名称空间中的ingress做验证(Validating)
     namespaceSelector:
       matchExpressions:
       - key: kubernetes.io/metadata.name
         operator: In
         values:
         - dev-wyc
         - test-wyc
         - uat-wyc
修改Job/ingress-nginx-admission-patch对象
   其--webhook-name=ingress-nginx-admission修改成--webhook-name=wyc-ingress-nginx-admission 
```


# 8.应用 manifests
```
## 应用manifests
kubectl apply -f ./02.wyc-ingress-nginx.yaml --dry-run=client
kubectl apply -f ./02.wyc-ingress-nginx.yaml

## 列出相应的资源对象
kubectl -n wyc-ingress-controller get sa,role,rolebinding,ds,svc,job
kubectl get clusterrole,clusterrolebinding,ValidatingWebhookConfiguration | grep wyc

## 列出所有的Pod
root@master01:~# kubectl -n wyc-ingress-controller get pods -o wide
root@master01:~# kubectl -n wyc-ingress-controller get pods -o wide
NAME                                   READY   STATUS      RESTARTS   AGE   IP             NODE     NOMINATED NODE   READINESS GATES
ingress-nginx-admission-create-k6vdl   0/1     Completed   0          18m   10.244.3.147   node01   <none>           <none>
ingress-nginx-admission-patch-7kq2m    0/1     Completed   0          18m   10.244.4.101   node02   <none>           <none>
ingress-nginx-controller-5tqbx         1/1     Running     0          18m   172.31.7.205   node02   <none>           <none>
ingress-nginx-controller-phhkf         1/1     Running     0          18m   172.31.7.204   node01   <none>           <none>
``` 

# 9.默认公开的后端
```
## 官方说明
https://kubernetes.github.io/ingress-nginx/user-guide/default-backend/

/healthz返回 200
/返回 404

## 当前环境下的测试
curl -s -o /dev/null  -w "%{http_code}\n"     http://172.31.7.204/healthz
curl -s -o /dev/null  -w "%{http_code}\n"     http://172.31.7.204/

curl -s -o /dev/null  -w "%{http_code}\n" -k  https://172.31.7.204/healthz
curl -s -o /dev/null  -w "%{http_code}\n" -k  https://172.31.7.204/


curl -s -o /dev/null  -w "%{http_code}\n"     http://172.31.7.205/healthz
curl -s -o /dev/null  -w "%{http_code}\n"     http://172.31.7.205/

curl -s -o /dev/null  -w "%{http_code}\n" -k  https://172.31.7.205/healthz
curl -s -o /dev/null  -w "%{http_code}\n" -k  https://172.31.7.205/
```

# 10.kubernetes外部LB
```
外部LB     
   myapp01.explain.com     --(七层代理)----> 后端(ingress controller)
   (DNS上将其解析至外部LB上的VIP)           172.31.7.204:80/443  172.31.7.205:80/443
   
   myapp02.explain.com     --(七层代理)----> 后端(ingress controller)
   (DNS上将其解析至外部LB上的VIP)       172.31.7.204:80/443  172.31.7.205:80/443
```

