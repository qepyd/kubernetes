#!/bin/bash

# 定义变量
ScriptDir=$(dirname "$0")

## 生成secrets资源对象的manifests的方式一
kubectl -n lili create secret generic db-secret02  \
  --type="Opaque"                 \
  --from-literal=username="lili01" \
  --from-literal=password="123456"  \
  --dry-run=client                   \
  -o yaml  >$ScriptDir/05.secrets_db-secret02.yaml

