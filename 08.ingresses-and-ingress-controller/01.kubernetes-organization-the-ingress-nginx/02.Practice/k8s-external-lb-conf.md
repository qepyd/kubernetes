# 1. Nginx做七层代理的示例
```
## nginx的nginx.conf做如下配置

   upstream  k8s01-wyc-project-ingress-nginx {
       #### 其via-the-host-network方式部署时
       # 节点IP:80
       server  172.31.7.204:80;
       server  172.31.7.205:80;

       # 节点IP:443
       # server  172.31.7.204:443;
       # server  172.31.7.205:443;

       #### 其over-a-nodeport-service方式部署时 
       # 节点IP:svc上其80对应的NodePort(例如: 30080)
       # server  172.31.7.204:30080;
       # server  172.31.7.205:30080;

       # 节点IP:svc上其443对应的NodePort(例如：30443)
       # server  172.31.7.204:30443;
       # server  172.31.7.205:30443;


       #### 其external-ips方式部署时
       # 其svc资源对象的外部IP(私网):80
       # server  外部IP之私网IP:80;
     
       # 其svc资源对象的外部IP(私网):443
       # server  外部IP之私网IP:443;
   }

   upstream  k8s01-jmsco-project-ingress-nginx {
       #### 其via-the-host-network方式部署时
       # 节点IP:80
       server  172.31.7.206:80;

       # 节点IP:443
       # server  172.31.7.206:443;

       #### 其over-a-nodeport-service方式部署时
       # 节点IP:svc上其80对应的NodePort(例如: 30080)
       # server  172.31.7.206:30080;

       # 节点IP:svc上其443对应的NodePort(例如：30443)
       # server  172.31.7.206:30443;

       #### 其external-ips方式部署时
       # 其svc资源对象的外部IP(私网):80
       # server  外部IP之私网IP:80;

       # 其svc资源对象的外部IP(私网):443
       # server  外部IP之私网IP:443;
   }

## 配置server，以dev-app01.qepyd.com为例
  root@lb01:~# cat /etc/nginx/conf.d/dev-app01.qepyd.com.conf 
  server {
    listen 80;
    server_name dev-app01.qepyd.com;
    location / {
      proxy_pass http://k8s01-wyc-project-ingress-nginx;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
   }
}
```
  
