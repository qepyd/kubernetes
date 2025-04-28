# 1.创建目录
```
mkdir  ./myapp01
ls -ld ./myapp01
```

# 2.创建Chart.yaml文件
```
cat >./myapp01/Chart.yaml<<'EOF'
apiVersion: v2
name: myapp01
version: 0.1.0
EOF
```

# 3.创建template目录存放相应的manifests
```
mkdir ./myapp01/templates/

cat > ./myapp01/templates/deploy_myapp01.yaml<<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: lili
  name: myapp01
  labels:
    deploy: myapp01
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp01
  template:
    metadata:
      namespace: lili
      labels:
        app: myapp01
    spec:
      nodeSelector:
        project: wyc
      containers:
        - name: myapp01
          image: swr.cn-north-1.myhuaweicloud.com/library/nginx:1.16
          imagePullPolicy: IfNotPresent
          command:
            - "/bin/sh"
          args:
            - "-c"
            - "echo myapp01 >/usr/share/nginx/html/index.html && nginx -g 'daemon off;'"
          ports:
            - name: http-80
              containerPort: 80
EOF


cat > ./myapp01/templates/svc_myapp01.yaml<<'EOF'
apiVersion: v1
kind: Service
metadata:
  namespace: lili
  name: myapp01
  labels:
    svc: myapp01
spec:
  selector:
    app: myapp01
  type: ClusterIP
  ports:
    - appProtocol: http
      name: http-80
      port: 80
      targetPort: http-80 
EOF
```

# 4.helm工具安装并卸载
```
# 把myapp01安装到lili名称空间中
-->命令为： helm -n lili  install myapp01  ./myapp01   # 其install后面的myapp01可以随便指定,建议与./myapp01/Chart.yaml中的name保持一致 
NAME: myapp01
LAST DEPLOYED: Mon Apr 28 14:12:30 2025
NAMESPACE: lili
STATUS: deployed
REVISION: 1
TEST SUITE: None


# 查看lili名称空间中其myapp01的状态
root@master01:~# helm -n lili status myapp01
NAME: myapp01
LAST DEPLOYED: Mon Apr 28 14:12:30 2025
NAMESPACE: lili
STATUS: deployed
REVISION: 1
TEST SUITE: None


# 列出lili名称空间中有哪些chart
root@master01:~# helm -n lili  list
NAME   	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART        	APP VERSION
myapp01	lili     	1       	2025-04-28 14:12:30.328527402 +0800 CST	deployed	myapp01-0.1.0	  

# 获取lili名称空间中其myapp01这个chart的manifests
root@master01:~# helm -n lili get manifest myapp01
..............会显示其各manifests所有文件的内容
..............会显示其各manifests所有文件的内容

# 用kubectl获取相关资源对象
kubectl -n lili get  deploy/myapp01  svc/myapp01

# 卸载lili名称空间中其myapp01这个chart
helm -n lili  list
helm -n lili uninstall myapp01
helm -n lili  list
```


