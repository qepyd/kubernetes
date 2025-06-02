```
k8s的基本架构部署好以后:  
  第一个要部署的就是cni网络插件  
  不然worker node的STATUS处于NotReady  
一套k8s中的cni插件部署一个即可:  
  根据k8s所处环境选择一种软件产品来实现,且只部署一套  
```
