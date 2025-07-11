## 1.应用manifests以创建rs/myapp01对象、观察、调整Pod副本数。
```
## 检查语法
kubectl apply -f rs_myapp01.yaml --dry-run=client

## 应用manifests
root@master01:~/tools/pod-controller/01.replicasets# kubectl apply -f rs_myapp01.yaml
replicaset.apps/myapp01 created

## 列出rs/myapp01对象
root@master01:~/tools/pod-controller/01.replicasets# kubectl get -f rs_myapp01.yaml
NAME      DESIRED   CURRENT   READY   AGE
myapp01   1         1         1       15s
  #
  # 期望Pod副本数是1，当前是1，就绪是1
  # 

## 列出rs/myapp01对象的相关Pod数
root@master01:~/tools/pod-controller/01.replicasets# kubectl -n lili get pods | grep myapp01
myapp01-5mzkq   1/1     Running   0          95s

## 查看其ReplicaSet控制器为其rs/myapp01对象相关Pod副本所注入的污点容忍
root@master01:~/tools/pod-controller/01.replicasets# kubectl -n lili get pods/myapp01-5mzkq -o=jsonpath='{.spec.tolerations}' | jq
[
  {
    "effect": "NoExecute",
    "key": "node.kubernetes.io/not-ready",
    "operator": "Exists",
    "tolerationSeconds": 300
  },
  {
    "effect": "NoExecute",
    "key": "node.kubernetes.io/unreachable",
    "operator": "Exists",
    "tolerationSeconds": 300
  }
]

## 调整rs/myapp01对象其Pod副本数为2，可修改manifests后,再重新应用,这时正规做法。
## 也可使用kubectl工具的scale命令，非正规做法，我这就用kubectl工具的scale命令,
## 目的是为了不影响后期再次基于其做"实践理解"
root@master01:~/tools/pod-controller/01.replicasets# kubectl -n lili scale --replicas=2  rs/myapp01
replicaset.apps/myapp01 scaled
root@master01:~/tools/pod-controller/01.replicasets# kubectl -n lili get rs/myapp01
NAME      DESIRED   CURRENT   READY   AGE
myapp01   2         2         2       7m38s
   #
   # 期望Pod副本数是2，当前是2，就绪是2
   # 
```

## 2.清理环境
```
kubectl delete -f rs_myapp01.yaml
```
