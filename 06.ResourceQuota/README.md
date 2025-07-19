resourcequotas资源（简写quota,类型为ResourceQuota）是kubernetes中的标准资源，属于namespace级别的资源。  
官方参考： https://kubernetes.io/zh-cn/docs/concepts/policy/resource-quotas/  
要想quota资源对象能够生效，需要kubernetes启用ResourceQuota，即kube-apiserver组件实例的--enable-admission-plugins
参数得包含ResourceQuota，kubeadm工具安装的kubernetes集群默认是没有启动的，我们得人为启动。

