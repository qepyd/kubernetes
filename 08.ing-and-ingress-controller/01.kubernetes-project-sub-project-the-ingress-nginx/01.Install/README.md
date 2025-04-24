```
kubernetes中可以有多套ingress controller
  我们可以以project为准,为各项目安装独有的ingress controller
  因为kubernetes是平台,不同的项目其使用ingress controller统一暴露时,得分散

ingress controller之ingress-nginx安装后其暴露的方式可以有：
  01:某项目的ingress-nginx使用Daemonset + nodeSelector匹配专属的worker node上的标签：
      共享宿主机的Network，会占用宿主机的80和443端口
      k8s外部LB中的某虚拟主机的上流端点即专属worker node的内部IP:80/443 
      即：通过主机网络 暴露
  02:某项目的ingress-nginx使用Deployment + nodeSelector匹配专属worker node上的标签:
      不共享宿主机的Network
      使用NodePort类型的svc暴露,其nodePort你得规划并固定
      k8s外部LB中的某虚拟主机的上流端点即专属worker node的内部IP:nodePort(80、443相对应的)
      即：通过NodePort类型的svc
  03:某项目的ingress-nginx使用Deploy + nodeSelector匹配专属的worker node上的标签：
      不共享宿主机的Netwok
      官方不建议：使用LoadBalancer类型的方式暴露。
      即：external-ips
```
