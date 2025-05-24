
======================================= 匿名请求 和 非匿名请求 ============================
# 1.准备static token file
```
## 准备static token file
root@master01:~# cat /tmp/static-token-file.csv 
c9c080.830e9721227e8088,lili01,1001
75ecb1.3c7c4204b1047d9f,lili02.1002,"ttadmin"
5c3b26.e724603c1fb0b702,lili03.1003,"ttadmin"

## 相关说明
文件名的后缀：
   csv
文件内容格式：
   TokenID.TokenSecret,用户名,用户ID,"Group1,Group2,..."
   每行至少包含前三列(不然kube-apiserver组件实例加载此文件后重启会失败)
   其Group是可选的
```

# 2.让kube-apiserver组件各实例加载static token file
我的k8s集群使用kubeadm工具部署(kube-apiserver以静态Pod运行,高可用)
```
## 将准备的static-token-file.csv复制到/etc/kubernetes/目录下
cp -a /tmp/static-token-file.csv  /etc/kubernetes/
ls -l /etc/kubernetes/static-token-file.csv

## 对/etc/kubernetes/manifests/kube-apiserver.yaml做备份
cp -a /etc/kubernetes/manifests/kube-apiserver.yaml /root/
ls -l /root/kube-apiserver.yaml

## 复制/etc/kubernetes/manifests/kube-apiserver.yaml出来做修改
cp -a /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/kube-apiserver.yaml
ls -l /tmp/kube-apiserver.yaml

## 修改/tmp/kube-apiserver.yaml文件
# <== spec.volumes字段中添加如下令牌：
- name: static-token-file
  hostPath:
    path: /etc/kubernetes/static-token-file.csv
    type: File

# <== 主容器(containers)之kube-apiserver的volumeMounts下添加如下信息
- name: static-token-file
  mountPath: /etc/kubernetes/static-token-file.csv
  readOnly: true

# <== 主容器(containers)之kube-apiserver的args字段下添加如下信息
- --token-auth-file=/etc/kubernetes/static-token-file.csv

# <== 替换/etc/kubernetes/manifests/kube-apiserver.yaml文件
mv /tmp/kube-apiserver.yaml   /etc/kubernetes/manifests/

# <== 观察kube-apiserver对应的容器是否启动起来
docker ps
```

# 3.匿名请求
生成token
```
root@master01:~# echo "$(openssl rand -hex 3).$(openssl rand -hex 8)"
7ac43b.58266dbe587c6f5e
```

curl工具访问kube-apiserver进行测试
```
## 命令
curl -H "Authorization: Bearer 7ac43b.58266dbe587c6f5e"  \
     --cacert /etc/kubernetes/pki/ca.crt                  \
     https://172.31.7.110:6443/api/v1/nodes

## 结果
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "Unauthorized",
  "reason": "Unauthorized",
  "code": 401
}

## 结果说明
被kubernetes识别成了"匿名请求"，其过程为：
A：所推荐的token是非法的(kube-apiserver通过它无法得到用户标识)
B：那么用户标识将为：
   用户名：system:anonymous
   所属组：system:unauthenticated
C：其权限由kubernetes中的以下对象控制着:
   clusterrole/system:public-info-viewer
   clusterrolebinding/system:public-info-viewer 
D：注意：这里没有经过"准入控制"，因为我的操作命令是读(而读是会绕过"准入控制"的)。
```

kubectl工具访问kube-apiserver进行测试
```
ls -l $HOME/.kube/config
mv $HOME/.kube/config  $HOME/.kube/config.bak
ls -l $HOME/.kube/config.bak

kubectl --server='https://172.31.7.110:6443'             \
   --certificate-authority=/etc/kubernetes/pki/ca.crt     \
   --token='7ac43b.58266dbe587c6f5e'                       \
   get nodes
   #
   # 结果为：error: You must be logged in to the server (Unauthorized)
   # 

mv $HOME/.kube/config.bak  $HOME/.kube/config
```


# 4.lili01用户的访问测试,及授权
curl工具访问
```
## 命令
curl -H "Authorization: Bearer c9c080.830e9721227e8088"  \
     --cacert /etc/kubernetes/pki/ca.crt                   \
     https://172.31.7.110:6443/api/v1/nodes

## 结果
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "nodes is forbidden: User \"lili01\" cannot list resource \"nodes\" in API group \"\" at the cluster scope",
  "reason": "Forbidden",
  "details": {
    "kind": "nodes"
  },
  "code": 403
}
```

kubernetes中进行相关的授权
```
## 创建角色
我还不太会,但我知道其clusterrole/cluster-admin具备超级权限

## 创建角色绑定(我这就创建集群角色,subject类型为User)
# <== 编写manifests
cat >/tmp/clusterrolebind_lili01.yaml <<'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: lili01
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: lili01
EOF

# <== 应用manifests
kubectl apply -f /tmp/clusterrolebind_lili01.yaml --dry-run=client
kubectl apply -f /tmp/clusterrolebind_lili01.yaml
kubectl get  clusterrolebinding lili01
```

curl工具再次进行测试
```
## 命令1(有结果)
curl -H "Authorization: Bearer c9c080.830e9721227e8088"  \
     --cacert /etc/kubernetes/pki/ca.crt                   \
     https://172.31.7.110:6443/api/v1/nodes

## 命令2(有结果,取相关字段)
curl -H "Authorization: Bearer c9c080.830e9721227e8088"  \
     --cacert /etc/kubernetes/pki/ca.crt                   \
     https://172.31.7.110:6443/api/v1/nodes  | jq '.items[] |{name: .metadata.name}'
    # 
    # jq命令在ubuntu下可用apt install jq -y进行安装
    # 
```

制作kubeconfig后
```
## 设置kubeconfig文件的clusters字段
kubectl --kubeconfig=/tmp/lili01.conf  config set-cluster      \
   k8s01                                                        \
  --server=https://172.31.7.110:6443                             \
  --certificate-authority=/etc/kubernetes/pki/ca.crt              \
  --embed-certs=true

kubectl --kubeconfig=/tmp/lili01.conf  config view --raw=false
kubectl --kubeconfig=/tmp/lili01.conf  config view --raw=true 

## 设置kubeconfig文件的users字段
kubectl --kubeconfig=/tmp/lili01.conf  config  set-credentials \
  lili01                                                        \
  --token=c9c080.830e9721227e8088

kubectl --kubeconfig=/tmp/lili01.conf  config view --raw=false
kubectl --kubeconfig=/tmp/lili01.conf  config view --raw=true 

## 设置kubeconfig文件的contexts字段
kubectl --kubeconfig=/tmp/lili01.conf  config set-context \
  lili01@k8s01                                              \
  --user=lili01                                             \
  --cluster=k8s01

kubectl --kubeconfig=/tmp/lili01.conf  config view --raw=false
kubectl --kubeconfig=/tmp/lili01.conf  config view --raw=true

## 设置kubeconfig文件的current-context字段
kubectl --kubeconfig=/tmp/lili01.conf  config use-context \
  lili01@k8s01 

kubectl --kubeconfig=/tmp/lili01.conf  config view --raw=false
kubectl --kubeconfig=/tmp/lili01.conf  config view --raw=true
```

kubectl工具使用制作好的kubeconfig去访问测试
```
kubectl --kubeconfig=/tmp/lili01.conf  get nodes
  #
  # 可列出k8s集群中所有的nodes资源对象的哈
  # 注意：因为是只读操作,会绕过kube-apiserver访问控制的第三关之"准入控制"
  #
```


# 5.lili02、lili03用户的测试及授权
curl工具进行访问测试
```
## curl拿着lili02用户的token、k8s集群的ca证书去访问
#<== 命令
curl -H "Authorization: Bearer 75ecb1.3c7c4204b1047d9f"  \
     --cacert /etc/kubernetes/pki/ca.crt                  \
     https://172.31.7.110:6443/api/v1/nodes

#<== 结果 
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "nodes is forbidden: User \"lili02.1002\" cannot list resource \"nodes\" in API group \"\" at the cluster scope",
  "reason": "Forbidden",
  "details": {
    "kind": "nodes"
  },
  "code": 403
}

## curl拿着lili03用户的token、k8s集群的ca证书去访问
#<== 命令
curl -H "Authorization: Bearer 5c3b26.e724603c1fb0b702"  \
     --cacert /etc/kubernetes/pki/ca.crt                  \
     https://172.31.7.110:6443/api/v1/nodes


#<== 结果
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "nodes is forbidden: User \"lili03.1003\" cannot list resource \"nodes\" in API group \"\" at the cluster scope",
  "reason": "Forbidden",
  "details": {
    "kind": "nodes"
  },
  "code": 403
}
```

kubernetes中授权
```
## 角色
我不太会,我知道有个clusterrole/cluster-admin对象，具备超级权限

## 角色绑定(这里为了测试，就创建集群角色绑定)
# <== 编写manifests
cat >/tmp/clusterrolebind_ttadmin.yaml <<'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ttadmin
roleRef:
  # <== 绑定clusterrole/cluster-admin
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  # <== 承载的是组，组名为ttadmin
  - apiGroup: rbac.authorization.k8s.io
    kind: Group 
    name: ttadmin
EOF

## 应用manifests
kubectl apply -f /tmp/clusterrolebind_ttadmin.yaml --dry-run=client
kubectl apply -f /tmp/clusterrolebind_ttadmin.yaml
kubectl get clusterrolebinding ttadmin
```

kubectl工具再进行访问测试
```
## kubectl拿着lili02用户的token、k8s集群的ca证书去访问
#<== 命令(可列出所有nodes资源对象)
kubectl --server='https://172.31.7.110:6443'             \
   --certificate-authority=/etc/kubernetes/pki/ca.crt     \
   --token='75ecb1.3c7c4204b1047d9f'                       \
   get nodes

## kubectl拿着lili03用户的token、k8s集群的ca证书去访问
#<== 命令(可列出所有nodes资源对象)
kubectl --server='https://172.31.7.110:6443'             \
   --certificate-authority=/etc/kubernetes/pki/ca.crt     \
   --token='5c3b26.e724603c1fb0b702'                       \
   get nodes
```






