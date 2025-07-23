# 1 secrets资源介绍
官方：https://kubernetes.io/zh-cn/docs/concepts/configuration/secret/

secrets资源（无简写，类型为Secret）是kubernetes中的标准资源，属于namespace级别的资源。

secrets资源属于"配置"类的资源。是一种包含少量敏感信息例如密码、令牌或密钥的对象(不可超过1MiB)。
这样的信息可能会被放在Pod规约中或者镜像中。 使用Secret意味着你不需要在应用程序代码中包含机密数据。

kubernetes v1.19版本开始，secrets资源的API规范提供了immutable字段，用于设置secrets资源对象是否不可变，
没有默认值，当不定义此字段时或此字段的值为false时，secrets资源对象是可变的。当此字段的值为true时，secrets资
源对象是不可变的。

secrets资源对象有着不同的类型，不同的类型也决定了data、stringData中键值对之键的name。

secrets资源API规范中提供data、stringData字段来定义键值对，两者均不是必须的。data字段中其键的value得base64编码后填写，而
stringData字段中其键的value用明文填写即可。data、stringData字段中的键若冲突，以stringData字段中的键为准。若data、stringData字段中
均拥有键值对，在查看secrets资源对象的描述信息(describe)或在线manifests时，中会显示data字段(stringData字段中的键值对也会在里面)，只
不过，describe中不会显示value，在线manifests中会显示value(base64编码后呈现)。

注意：静态Pod不能使用secrets资源对象

# 2 secrets资源对象的实践理解
实践参考 ./01.secrets-resource-object-itself/

# 3 快速编写secrets资源对象的manifests
实践参考 ./02.quickly-compile-secrets-resource-object-manifests/

# 4 将configmaps用作pod中的文件
实践参考 ./03.using-secrets-as-files-from-a-pod/

# 5 使用configmaps作为环境变量
实践参考 ./04.using-secrets-as-environment-variables/

# 6 pods.spec.imagepullSecrets来引用
实践参考 ./05.using-imagepullsecrets/
