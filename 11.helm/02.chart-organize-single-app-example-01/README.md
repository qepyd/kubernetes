# 1.部署到dev环境
```
## 检查chart的语法格式
helm lint ./myapp01/

## 使用helm工具进行安装前进行模拟安装(--dry-run)
helm -n dev-lili install myapp01 ./myapp01/  --set-string=podLabels.env=dev --dry-run=client 
  #
  # 会展示出相关的状态、各manifests(最终)
  #

## 使用helm工具进行安装
helm -n dev-lili install myapp01 ./myapp01/  --set-string=podLabels.env=dev

## 查看Release
---------># helm -n dev-lili list
NAME   	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART        	APP VERSION
myapp01	dev-lili 	1       	2025-05-01 14:56:04.517325913 +0800 CST	deployed	myapp01-0.1.0	   

## kuectl工具列出相关资源对象
root@master01:~# kubectl -n dev-lili get deploy --show-labels
NAME      READY   UP-TO-DATE   AVAILABLE   AGE   LABELS
myapp01   2/2     2            2           72s   app.kubernetes.io/managed-by=Helm,deploy=myapp01
root@master01:~#
root@master01:~# 
root@master01:~# kubectl -n dev-lili get pods -o wide --show-labels
NAME                       READY   STATUS    RESTARTS   AGE    IP             NODE     NOMINATED NODE   READINESS GATES   LABELS
myapp01-7f659654d9-2j4pr   1/1     Running   0          112s   10.244.4.143   node02   <none>           <none>            app=myapp01,env=dev,pod-template-hash=7f659654d9
myapp01-7f659654d9-zh25b   1/1     Running   0          112s   10.244.5.185   node03   <none>           <none>            app=myapp01,env=dev,pod-template-hash=7f659654d9
root@master01:~#
root@master01:~#
root@master01:~# kubectl -n dev-lili get svc --show-labels
NAME      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE     LABELS
myapp01   ClusterIP   10.144.241.94   <none>        80/TCP    2m15s   app.kubernetes.io/managed-by=Helm,svc=myapp01
root@master01:~#
root@master01:~#
root@master01:~# kubectl -n dev-lili describe svc/myapp01
Name:              myapp01
Namespace:         dev-lili
Labels:            app.kubernetes.io/managed-by=Helm
                   svc=myapp01
Annotations:       meta.helm.sh/release-name: myapp01
                   meta.helm.sh/release-namespace: dev-lili
Selector:          app=myapp01,env=dev
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.144.241.94
IPs:               10.144.241.94
Port:              http  80/TCP
TargetPort:        http/TCP
Endpoints:         10.244.4.143:80,10.244.5.185:80
Session Affinity:  None
Events:            <none>
root@master01:~# 
root@master01:~# 
root@master01:~# curl 10.144.241.94:80
myapp01
root@master01:~# 
```

# 2.部署到test环境
```
## 检查chart的语法格式
helm lint ./myapp01/

## 使用helm工具进行安装前进行模拟安装(--dry-run)
helm -n test-lili install myapp01 ./myapp01/  --set-string=podLabels.env=test --dry-run=client
  #
  # 会展示出相关的状态、各manifests(最终)
  #

## 使用helm工具进行安装 
helm -n test-lili install myapp01 ./myapp01/  --set-string=podLabels.env=test

## 列出Release
root@master01:~# helm -n test-lili list
NAME   	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART        	APP VERSION
myapp01	test-lili	1       	2025-05-01 15:00:45.822920925 +0800 CST	deployed	myapp01-0.1.0	 

## kubectl工具列出相关资源对象
root@master01:~# kubectl -n test-lili get deploy --show-labels
NAME      READY   UP-TO-DATE   AVAILABLE   AGE   LABELS
myapp01   2/2     2            2           66s   app.kubernetes.io/managed-by=Helm,deploy=myapp01
root@master01:~# 
root@master01:~# 
root@master01:~# kubectl -n test-lili get pods -o wide --show-labels
NAME                      READY   STATUS    RESTARTS   AGE   IP             NODE     NOMINATED NODE   READINESS GATES   LABELS
myapp01-b65fddd46-ln45f   1/1     Running   0          76s   10.244.4.144   node02   <none>           <none>            app=myapp01,env=test,pod-template-hash=b65fddd46
myapp01-b65fddd46-svvr6   1/1     Running   0          76s   10.244.5.186   node03   <none>           <none>            app=myapp01,env=test,pod-template-hash=b65fddd46
root@master01:~# 
root@master01:~# 
root@master01:~# kubectl -n test-lili get svc --show-labels
NAME      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE   LABELS
myapp01   ClusterIP   10.144.157.93   <none>        80/TCP    86s   app.kubernetes.io/managed-by=Helm,svc=myapp01
root@master01:~# 
root@master01:~# 
root@master01:~# kubectl -n test-lili describe svc/myapp01 
Name:              myapp01
Namespace:         test-lili
Labels:            app.kubernetes.io/managed-by=Helm
                   svc=myapp01
Annotations:       meta.helm.sh/release-name: myapp01
                   meta.helm.sh/release-namespace: test-lili
Selector:          app=myapp01,env=test
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.144.157.93
IPs:               10.144.157.93
Port:              http  80/TCP
TargetPort:        http/TCP
Endpoints:         10.244.4.144:80,10.244.5.186:80
Session Affinity:  None
Events:            <none>
root@master01:~#
root@master01:~#
root@master01:~# curl 10.144.157.93
myapp01
```

# 3.清理环境
```
## 列出所有的Release
root@master01:~# helm list -A
NAME   	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART        	APP VERSION
myapp01	dev-lili 	1       	2025-05-01 14:56:04.517325913 +0800 CST	deployed	myapp01-0.1.0	           
myapp01	test-lili	1       	2025-05-01 15:00:45.822920925 +0800 CST	deployed	myapp01-0.1.0	

## 卸载dev-lili名称空间中的myapp01 Release
helm -n dev-lili  uninstall  myapp01  

## 卸载test-lili名称空间中的myapp01 Release
helm -n test-lili  uninstall  myapp01  

## 相关Release中部署的资源对象也销毁了
kubectl -n dev-lili   get deploy,svc | grep myapp01
kubectl -n test-lili  get deploy,svc | grep myapp01
```
