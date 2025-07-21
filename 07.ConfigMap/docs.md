# 1 configmaps资源介绍
官方： https://kubernetes.io/zh-cn/docs/concepts/configuration/configmap/  

configmaps资源（简写cm，类型为ConfigMap）是kubernetes中的标准资源，属于namespace级别的资源。  

configmaps资源属于"配置"类的资源。我们在安装软件时会有三步（安装、配置、启动），利用configmaps
资源对象可以将配置数据和应用程序代码分开，即Pod中容器所用image只关注程序代码和基本程序配置（启动所需）。

configmaps资源对象用于将非机密性的数据保存到键值对（key value）中，configmaps资源的API规范中binaryData
和data字段中均可以定义键值对（key value）。configmaps在设计上不是用来保存大量数据的，configmaps资源对象
中保存的数据不可超过1MiB。configmaps资源对象中的数据是存放到kube-apiserver的数据存储之etcd中的。

kubernetes v1.19版本开始，configmaps资源的API规范提供了immutable字段，用于设置configmaps资源对象是否不可变，
没有默认值，当不定义此字段时或此字段的值为false时，configmaps资源对象是可变的，此字段的值也是可变的。当此字
段的值为true时，configmaps资源对象是不可变的，此字段也是不可变的。

configmaps资源提供定义键值对的字段有binaryData、data，两者者均不是必须的。那么我们可以创建一个可变（immutable字段不存在
或存在时其值为false）且没有数据的configmaps资源对象。binaryData、data字段可同时存在，同时存在时其data字段中的键不能与binaryData
中的键冲突，若冲突的话影响configmaps资源对象的创建。binaryData、data字段不同时存在，若键冲突，不影响configmaps资源对象的创建，以
最后一个键为准。binaryData字段中其键值对（key: value）的value得加密（base64）后填写，不然会影响configmaps资源对象的创建，当有被引
用到时，会自动解密。data字段中其键值对（key: value）的value不需要加密，当有被引用到时，没有自动解密这一说。其data字段是常用（因为
configmaps资源对象用于将非机密性的数据保存到键值对中）。

# 2 configmaps资源对象的实践理解
参考 ./01.cm-resource-object-itself/ 目录


# 3 快速编写configmaps资源对象的manifests
参考 ./02.quickly-compile-cm-resource-object-manifests/ 目录

# 4 将configmaps用作pod中的文件
./02.using-configmaps-as-files-from-a-pod/
```

```

# 5 使用configmaps作为环境变量
./03.using-configmaps-as-environment-variables/
```

```




