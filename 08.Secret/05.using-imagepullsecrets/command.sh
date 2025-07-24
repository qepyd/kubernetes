#!/bin/bash

# 定义变量
ScriptDir=$(dirname "$0")

## 生成secrets资源对象的manifests的方式一
#kubectl -n lili create secret docker-registry  myhuaweicloud.com.image.read             \
#  --docker-server='swr.cn-north-1.myhuaweicloud.com'                                     \
#  --docker-username='cn-north-1@HPUAFZ8ORRRVH2QTXCIJ'                                     \
#  --docker-password='411774d6b66cb4729456ffb20384f2132bea9fb6916478140b063f4a19647d65'     \
#  --dry-run=client                                                                          \
#  -o yaml  >$ScriptDir/secrets_myhuaweicloud.com.image.read.yaml

## 生成secrets资源对象的manifests的方式2
kubectl -n lili create secret docker-registry  myhuaweicloud.com.image.read            \
  --docker-server='swr.cn-north-1.myhuaweicloud.com'                                    \
  --from-file=.dockerconfigjson=$ScriptDir/config.json                                  \
  --dry-run=client                                                                        \
  -o yaml  >$ScriptDir/secrets_myhuaweicloud.com.image.read.yaml
