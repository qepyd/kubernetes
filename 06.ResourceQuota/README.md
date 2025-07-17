resourcequotas（简写quota,类型为ResourceQuota）是kubernetes中的标准资源，属于namespace级别的资源。  
官方参考： https://kubernetes.io/zh-cn/docs/concepts/policy/resource-quotas/  
要想quota资源对象能够生效，需要kubernetes启用ResourceQuota，即kube-apiserver组件实例的--enable-admission-plugins
参数得包含ResourceQuota，kubeadm工具安装的kubernetes集群默认是没有启动的，我们得人为启动。
```
用于对namespace进行资源配额
  例如1：配置namespace中相关资源能够使用的计算资源总容量。
  例如2：配置namespace中相关资源能够使用的存储资源总容器
  例如3：配置namespace中相关资源其对数的总个数，好像没有意义。
```

