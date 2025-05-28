
# 1.kubeconfig文件的基本介绍
官方参考
```
https://kubernetes.io/zh-cn/docs/concepts/configuration/organize-cluster-access-kubeconfig/
```
基本介绍
```
kubeconfig是遵循一定格式文件的统称，用来承载连接kubernetes其kube-apiserver组件各实例的信息。
其信息主要的两部分为：kube-apiserver的连接地址、client携带的所谓认证信息。
client工具(例如:kubectl、helm)指定kubeconfig文件并提交相关操作命令。
```

# 2.kubectl工具找寻kubeconfig的优先级
可通过 kubectl config --help 看到其对优先级的介绍
```
## 相关优化级
--kubeconifg   >   $KUBECONFIG   >  $HOME/.kube/config

## 相关的介绍
--kubeconfig参数
  #
  # 命令行使用参数指定的最大嘛。
  # 可以指定多个kubeconfig文件。
  #   例如：--kubeconfig  path/kubeconfig   --kubeconfig path/mkubeconfig
  # 当指定了多个kubeconfig文件时：
  #   各kubeconfig是不会合并的。
  #   以最后(右/下)的为准。
  #

$KUBECONFIG环境变量
  #
  # 变量的值其值可以有多个kubeconfig,
  # 当




```


