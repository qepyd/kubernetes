# 1.kubernetes中的资源(resource)介绍
## 1.1 资源(resource)基于来源的分类
### 1.1.1 自定义资源
**介绍**
我们可以使用 kubectl get crd 看到所维护的kubernetes中有没有自定义资源，若没有任何自定义资源，其结果为No resources found，若
有相应的自定义资源，其结果中NAME字段的值以点分隔其第一列就是资源名(resource name)。自定义资源其实是通过非自定义资源(后面称为
标准资源)customresourcedefinitions(简写crd或crds)定义出来的。

**实践**
这里安装Addons CNI 之Calico 的 crd
```
## 下载manifests
wget https://raw.githubusercontent.com/projectcalico/calico/v3.26.5/manifests/tigera-operator.yaml
ls -l tigera-operator.yaml

## 查看有哪些类型



```


### 1.1.2 标准资源


## 1.2 资源(resource)基于名称空间的分类
**介绍**
kubernetes中的所有资源(自定义资源、标准资源)可分为"namespace级别"、"非namespace级别(也称为cluster集群)"。像nodes资源就是"非
namespace级别"的资源。注意：namespaces资源属于"非namespace级别"的资源。

**实践**


