# 1 kubectl工具快速编写secrets资源对象的manifests的说明
**secrets的类型有**   
https://kubernetes.io/zh-cn/docs/concepts/configuration/secret/#secret-types
```
Opaque
kubernetes.io/service-account-token
kubernetes.io/dockercfg
kubernetes.io/dockerconfigjson
kubernetes.io/basic-auth
kubernetes.io/ssh-auth
kubernetes.io/tls              
bootstrap.kubernetes.io/token
```

**kubectl工具相关命令**   
相平面命令/子命令
```
## 获取帮助
kubectl create secret --help

## 子命令
docker-registry
  #
  # 创建 kubernetes.io/dockerconfigjson 类型的secrets资源对象
  #
generic
  #
  # 可创建任意类型的secrets
  #
tls
  #
  # 创建 kubernetes.io/tls 类型的secrets资源对象
  #
```

各子命令格式
```
## 子命令docker-registry的格式
kubectl -n <Namespace>   create secret docker-registry NAME  \
  [--docker-server=string]                                    \
  --docker-username=user                                       \
  --docker-password=password                                    \
  --docker-email=email                                           \
  [--from-file=[key=]source]                                      \
  [--dry-run=server|client|none]                                   \
  [options]

## 子命令generic的格式
kubectl -n <Namespace>   create secret generic  NAME   \
  [--type=string]                                       \
  [--from-literal=key1=value1]                           \
  [--from-file=[key=]source]                              \
  [--dry-run=server|client|none]                           \
  [options]


## 子命令tls的格式
kubectl  -n <Namespace>  create secret tls NAME \
  --cert=path/to/cert/file                       \
  --key=path/to/key/file                          \
  [--dry-run=server|client|none]                   \
  [options]
```
