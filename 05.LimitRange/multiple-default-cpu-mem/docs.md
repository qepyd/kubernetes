# 1default cpu mem LimitRange的介绍



**ns/lili名称空间级别没有limits**
```
root@master01:~# kubectl describe ns lili
Name:         lili
Labels:       kubernetes.io/metadata.name=lili
Annotations:  <none>
Status:       Active

No resource quota.         # 没有ResourceQuota资源对象相关信息

No LimitRange resource.    # 没有LimitRange资源对象相关信息
```

**创建LimitRange资源对象**
创建的LimitRange资源对象中只包含default，指定了cpu、memory
```
## 应用manifests
root@master01:~# kubectl apply -f 01.limitranges_default-cpu-mem-01.yaml  -f 02.limitranges_default-cpu-mem-02.yaml --dry-run=client
limitrange/default-cpu-mem-01 created (dry run)
limitrange/default-cpu-mem-02 created (dry run)
root@master01:~#
root@master01:~#  kubectl apply -f 01.limitranges_default-cpu-mem-01.yaml  -f 02.limitranges_default-cpu-mem-02.yaml
limitrange/default-cpu-mem-01 created
limitrange/default-cpu-mem-02 created

## 查看ns/lili资源对象的描述信息
root@master01:~# kubectl describe ns lili
Name:         lili
Labels:       kubernetes.io/metadata.name=lili
Annotations:  <none>
Status:       Active

No resource quota.

Resource Limits
 Type       Resource  Min  Max  Default Request  Default Limit  Max Limit/Request Ratio
 ----       --------  ---  ---  ---------------  -------------  -----------------------
 Container  cpu       -    -    400m             800m           -
 Container  memory    -    -    256Mi            512Mi          -
 Container  cpu       -    -    300m             900m           -
 Container  memory    -    -    156Mi            412Mi          -
```
