
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
  # 命令行使用参数指定的最大嘛
  # 可以指定多个kubeconfig文件
  #   例如：--kubeconfig  /path/kubeconfig   --kubeconfig /path/mykubeconfig
  # 当指定了多个kubeconfig文件时
  #   各kubeconfig是不会合并的
  #   以最后(右/下)的为准
  #

$KUBECONFIG环境变量
  #
  # 变量的值可以有多个kubeconfig
  #   例如: export KUBECONFIG=/path/kubeconfig:/path/mykubeconfig
  # 当指定了多个kubeconfig时
  #   各kubeconfig是会合并的
  #     <[]object>类型的各字段下列表合并在一起
  #     current-context字段的值,以第一个(从左至右)且拥有值的为准 
  #   

$HOME/.kube/config
  #
  # 具体文件
  # 家目录下的.kube/目录下名为config的kubeconfig
  #
```

# 3.kubeconfig文件的格式
```
apiVersion: v1
kind: Config
clusters: <[]Object>
  - name: <String>
    cluster: <Object>
      # kube-apiserver组件实例的连接地址
      server: <String>
      # kubernetes集群的ca证书(证书)或代理认证服务的地址
      proxy-url: <string>
      certificate-authority-data: <String>
users: <[]Object>
  - name: <String>
    user: <Object>
      # x509客户端证书(证书、私钥)
      client-certificate-data: <String>
      client-key-data: <String>
contexts: <[]Object>
  - name: <String>        # 其users字段中某列表的name@其clusters字段中某列表的name
    context: <Object>
      user: <String>      # 其users字段中某列表的name
      cluster: <String>   # 其clusters字段中某列表的name
current-context: <string> # 指contexts字段中某列表的name 
```

