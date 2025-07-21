# 1 格式
```
kubectl -n <Namespace> create configmap NAME \
  [--from-literal=key1=value1] \   # 人为指定key和value
  [--from-file=[key=]source]    \  # source是文件的路径，若不指定key即使用文件名作为key。
  [--dry-run=server|client|none] \ # 调试
  [options]
```

# 2 人为指定键值对
```
## 生成manifests前的调试
kubectl -n lili create configmap myconfig01  \
  --from-literal=name="lili"  \
  --from-literal=sex="girl"   \
  --from-literal=age="24"     \
  -o yaml --dry-run=client

## 生成manifests并存放到文件中
kubectl -n lili create configmap myconfig01  \
  --from-literal=name="lili"  \
  --from-literal=sex="girl"   \
  --from-literal=age="24"     \
  -o yaml >./cm_myconfig01.yaml

## 应用manifests、查看资源对象、删除资源对象
kubectl apply -f cm_myconfig01.yaml  --dry-run=client
kubectl apply -f cm_myconfig01.yaml
kubectl -n lili get       cm/myconfig01
kubectl -n lili describe  cm/myconfig01
kubectl -n lili delete    cm/myconfig01
```

# 3 根据现有文件生成
**创建几个文件**
```
## 创建file01文件并写入内容
cat >./file01<<'EOF'
11111111
11111111
EOF

## 创建file02文件并写入内容
cat >./file02<<'EOF'
22222222
22222222
EOF
```

**创建cm/myconfig02对象**
```
## 生成manifests前的调试
kubectl -n lili create configmap myconfig02 \
  --from-file=./file01                      \
  --from-file=file02=./file02               \
  -o yaml --dry-run=client

## 生成manifests并存放到文件中
kubectl -n lili create configmap myconfig02 \
  --from-file=./file01                      \
  --from-file=file02=./file02               \
  -o yaml >./cm_myconfig02.yaml

## 应用manifests、查看资源对象、删除资源对象
kubectl apply -f cm_myconfig02.yaml --dry-run=client
kubectl apply -f cm_myconfig02.yaml
kubectl -n lili get      cm/myconfig02 
kubectl -n lili describe cm/myconfig02
kubectl -n lili delete   cm/myconfig02
```
