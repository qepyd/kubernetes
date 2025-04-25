# 1.kubernetes官方对ingres及ingress controller的介绍
```
https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/
```

# 2.基本说明
```
kubernetes中有一个ingresses资源(简写ing)
   标准资源（安装好kubernetes后就会有）
   属于namespace级别(kubectl api-resources | grep ingresses)

为了让 ingresses 资源对象工作起来就得有 ingressclasses 资源对象
   ingressclasses资源是kubernetes的标准资源(安装好kubernets后就会有)
   ingressclasses资源属于非namespace级别(kubectl api-resources | grep ingressclasses)

为了让 ingress 资源对象工作起来就得有ingress controller存在(运行)
   某种软件(ingress controller）以Pod方式交付到kubernetes中
   期间会创建 相应的 ingressclasses 资源对象(与ingress controller打交道)

ingresses资源对象
   承上：ingressclasses资源对象(会找到相应的ingress controller)
   启下：所指定的svc资源对象
   进而：转换成相应配置到ingress controller
```
