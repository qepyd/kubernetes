## 1.部署应用(01.ds_myapp01.yaml)
```
## 应用manifests
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl apply -f 01.ds_myapp01.yaml
daemonset.apps/myapp01 created

## 列出ds/myapp01对象
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl -n lili get ds/myapp01
NAME      DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
myapp01   3         3         3       3            3           <none>          20s
  #
  # 可看到渴望3，当前3，就绪3，存在3，存活3
  # 可知道其选择了3个worker node
  # 

## 列出ds/myapp01对象的相关Pod
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl -n lili get pods -o wide | grep myapp01
myapp01-gzz7x   1/1     Running   0          68s   10.244.5.22    node03   <none>           <none>
myapp01-w8t2d   1/1     Running   0          68s   10.244.3.143   node01   <none>           <none>
myapp01-wpc5x   1/1     Running   0          68s   10.244.4.65    node02   <none>           <none>
  #
  # 在各worker node上只有1个Pod副本
  #

## 查看ds/myapp01对象的描述信息
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl -n lili describe ds/myapp01
Name:           myapp01                       # ds资源对象的name
Selector:       app=myapp01                   # ds/myapp01对象的标签选择器
Node-Selector:  <none>                        # template中的Pod没有用nodeSelector
Labels:         deploy=myapp01                # ds/myapp01对象的labels
Annotations:    deprecated.daemonset.template.generation: 1     # ds/myapp01对象的注释,其1对应着rollout history中的1 revision
Desired Number of Nodes Scheduled: 3                            # 所需节点数量计划
Current Number of Nodes Scheduled: 3                            # 发前节点数量计划
Number of Nodes Scheduled with Up-to-date Pods: 3               # 使用最新Pod计划的节点数量
Number of Nodes Scheduled with Available Pods: 3                # 计划使用可用Pod的节点数量
Number of Nodes Misscheduled: 0                                 # 未调度的节点数
Pods Status:  3 Running / 0 Waiting / 0 Succeeded / 0 Failed    # 所有Pod副本的状态
Pod Template:                                                   # ds/myapp01对象中template
  Labels:  app=myapp01
  Containers:
   myapp01:
    Image:        swr.cn-north-1.myhuaweicloud.com/library/nginx:1.16
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:                                                         # 事件
  Type    Reason            Age    From                  Message
  ----    ------            ----   ----                  -------
  Normal  SuccessfulCreate  2m19s  daemonset-controller  Created pod: myapp01-w8t2d   # 某Pod副本的name
  Normal  SuccessfulCreate  2m19s  daemonset-controller  Created pod: myapp01-wpc5x   # 某Pod副本的name
  Normal  SuccessfulCreate  2m19s  daemonset-controller  Created pod: myapp01-gzz7x   # 某pod副本的name

## 查看ds/myapp01当前的历史记录
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl -n lili rollout history ds/myapp01
daemonset.apps/myapp01 
REVISION  CHANGE-CAUSE
1         <none>

## 获取ds/myapp01对象所编排的任一Pod副本的manifests(主要看其daemonset控制器为其添加的污点容忍)
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl -n lili get pods/myapp01-wpc5x -o jsonpath='{.spec.tolerations}' | jq
[
  {
    "effect": "NoExecute",
    "key": "node.kubernetes.io/not-ready",
    "operator": "Exists"
  },
  {
    "effect": "NoExecute",
    "key": "node.kubernetes.io/unreachable",
    "operator": "Exists"
  },
  {
    "effect": "NoSchedule",
    "key": "node.kubernetes.io/disk-pressure",
    "operator": "Exists"
  },
  {
    "effect": "NoSchedule",
    "key": "node.kubernetes.io/memory-pressure",
    "operator": "Exists"
  },
  {
    "effect": "NoSchedule",
    "key": "node.kubernetes.io/pid-pressure",
    "operator": "Exists"
  },
  {
    "effect": "NoSchedule",
    "key": "node.kubernetes.io/unschedulable",
    "operator": "Exists"
  }
]

## 获取ds/myapp01对象所编排的任一Pod副本的manifests(主要看其与worker node的硬亲和)
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl -n lili get pods/myapp01-wpc5x -o jsonpath='{.spec.affinity}' | jq
{
  "nodeAffinity": {
    "requiredDuringSchedulingIgnoredDuringExecution": {
      "nodeSelectorTerms": [
        {
          "matchFields": [
            {
              "key": "metadata.name",
              "operator": "In",
              "values": [
                "node02"
              ]
            }
          ]
        }
      ]
    }
  }
}


## 驱逐worker node01（不要乱用哈）上的所有Pod,是不会驱逐其ds在上的Pod
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl cordon node01
node/node01 cordoned
   #
   # 驱动(cordon) worker node 之 node01
   #   
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl describe nodes/node01 | grep -A 10000 Taints | grep -B 10000 "Unschedulable:" | sed '$'d
Taints:             node.kubernetes.io/unschedulable:NoSchedule
   # 
   # worker node 之 node01上有污点了
   # 
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl -n lili get pods -o wide | grep myapp01
myapp01-gzz7x   1/1     Running   0          34m   10.244.5.22    node03   <none>           <none>
myapp01-w8t2d   1/1     Running   0          34m   10.244.3.143   node01   <none>           <none>
myapp01-wpc5x   1/1     Running   0          34m   10.244.4.65    node02   <none>           <none>
   #
   # worker node 之 node01上的 1 Pod副本还在的
   # 

root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl uncordon node01
node/node01 uncordoned
   # 
   # 取消对 worker node 之 node01 上 Pod的驱逐
   # 


## 对worker node01打上污点(cl=lili:NoSchedule)
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl taint nodes node01 cl=lili:NoSchedule
node/node01 tainted
   #
   # worker node之node01上打污点成功
   #
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl describe nodes/node01 | grep -A 10000 Taints | grep -B 10000 "Unschedulable:" | sed '$'d
Taints:             cl=lili:NoSchedule
   #
   # 查看worker node之node01上有哪些污点
   # 
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl -n lili get pods -o wide | grep myapp01
myapp01-gzz7x   1/1     Running   0          40m   10.244.5.22    node03   <none>           <none>
myapp01-w8t2d   1/1     Running   0          40m   10.244.3.143   node01   <none>           <none>
myapp01-wpc5x   1/1     Running   0          40m   10.244.4.65    node02   <none>           <none>
   # 
   # 列出ds/myapp01对象的相关Pod副本,
   # 可看到node01上是有1Pod副本的。
   # 说明：对worker node打污点,对未容忍污点且运行的Pod副本暂时不影响
   # 为什么呢？因为对node01有硬亲和
   # 
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl -n lili delete pods/myapp01-w8t2d 
pod "myapp01-w8t2d" deleted
   #
   # 人为删除ds/myapp01对象其在node01上的Pod副本
   # 不是删除ds/myapp01对象的哈。
   # 
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl -n lili get pods -o wide | grep myapp01
myapp01-gzz7x   1/1     Running   0          43m   10.244.5.22   node03   <none>           <none>
myapp01-wpc5x   1/1     Running   0          43m   10.244.4.65   node02   <none>           <none>
   # 
   # 可看到Daemonset是没有为ds/myapp01对象在node01上拉起Pod副本
   # 因为ds/myapp01其template中Pod没有事先容忍cl=lili:NodeSchedule污点
   # 要想ds/myapp01对象其Pod副本再次具备在node01上,有以下两种做法
   #   第一种:现在取消node01上之前打的污点。
   #   第二种:对ds/myapp01对象其template中Pod人为设置容忍其污点,再重建应用
   # 
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl taint nodes node01 cl-
node/node01 untainted
   #
   # 取消worker node之node01上key为cl的污点
   # 
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl -n lili get pods -o wide | grep myapp01
myapp01-gzz7x   1/1     Running   0          47m   10.244.5.22    node03   <none>           <none>
myapp01-lm8qd   1/1     Running   0          52s   10.244.3.144   node01   <none>           <none>
myapp01-wpc5x   1/1     Running   0          47m   10.244.4.65    node02   <none>           <none>
   #
   # 再看ds/myapp01对象其Pod副本是否有在node1上存在
   # 是存在的
```


## 2.通过修改ds/myapp01对象中Pod的labels来触发更新(02.ds_myapp01-change-pods-labels.yaml)
```
## 应用manifests
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl apply -f 02.ds_myapp01-change-pods-labels.yaml 
daemonset.apps/myapp01 configured

## 查看ds/myapp01对象其描述信息
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl -n lili describe ds/myapp01 | grep Annotations
Annotations:    deprecated.daemonset.template.generation: 2

## 查看ds/myapp01对象其rollout history
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl -n lili rollout history ds/myapp01
daemonset.apps/myapp01 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

## 列出ds/myapp01对象其相关的Pod副本
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl -n lili get pods -o wide | grep myapp01
myapp01-lf5nl   1/1     Running   0          96s    10.244.5.23    node03   <none>           <none>
myapp01-r7m7h   1/1     Running   0          100s   10.244.3.145   node01   <none>           <none>
myapp01-zpskp   1/1     Running   0          98s    10.244.4.66    node02   <none>           <none>

```


## 3.通过修改ds/myapp01对象中Pod里面某主容器的image来触发更新(03.ds_myapp01-change-image.yaml)
```
## 应用manifests
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl apply -f 03.ds_myapp01-change-image.yaml 
daemonset.apps/myapp01 configured

## 查看ds/myapp01对象其描述信息
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl -n lili describe ds/myapp01 | grep Annotations
Annotations:    deprecated.daemonset.template.generation: 3

## 查看ds/myapp01对象其rollout history
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl -n lili rollout history ds/myapp01
daemonset.apps/myapp01 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
3         <none>

## 列出ds/myapp01对象其相关的Pod副本
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl -n lili get pods -o wide | grep myapp01
myapp01-9r2kk   1/1     Running   0          46s   10.244.5.24    node03   <none>           <none>
myapp01-g25g8   1/1     Running   0          50s   10.244.3.146   node01   <none>           <none>
myapp01-tgzz6   1/1     Running   0          48s   10.244.4.67    node02   <none>           <none>

```


## 4.滚回至某历史版本
```
## 查看ds/myapp01当前有哪些历史版本
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl -n lili rollout history ds/myapp01
daemonset.apps/myapp01 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
3         <none>

## 查看rollout history中各REVISION信息,以供回滚前做参考
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# bash print-ds-source-object-all-history-revision.sh 
<==== ds/myapp01 Current Rollout History Revision: 3
==> 1 Info:
  Pod Template:
  Labels:	app=myapp01
  Containers:
   myapp01:
    Image:	swr.cn-north-1.myhuaweicloud.com/library/nginx:1.16
    Port:	80/TCP
    Host Port:	0/TCP
    Environment:	<none>
    Mounts:	<none>
  Volumes:	<none>
  
==> 2 Info:
  Pod Template:
  Labels:	app=myapp01
	version=stable
  Containers:
   myapp01:
    Image:	swr.cn-north-1.myhuaweicloud.com/library/nginx:1.16
    Port:	80/TCP
    Host Port:	0/TCP
    Environment:	<none>
    Mounts:	<none>
  Volumes:	<none>
  
==> 3 Info:
  Pod Template:
  Labels:	app=myapp01
	ver=stable
  Containers:
   myapp01:
    Image:	swr.cn-north-1.myhuaweicloud.com/library/nginx:1.17
    Port:	80/TCP
    Host Port:	0/TCP
    Environment:	<none>
    Mounts:	<none>
  Volumes:	<none>


## 回滚至Revision 1
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl -n lili rollout undo --to-revision=1 ds/myapp01
daemonset.apps/myapp01 rolled back
  # 
  # 其--to-revision默认为0,即当前revision的前一个版本
  # 这里就是3前面的一个,即2
  #

## 再查看ds/myapp01对象有哪些rollout history
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl -n lili rollout history ds/myapp01
daemonset.apps/myapp01 
REVISION  CHANGE-CAUSE
2         <none>
3         <none>
4         <none>
  #
  # 1变成了4,4即为当前版本
  # 

## 查看ds/myapp01对象其描述信息
root@master01:~/tools/pod-controller/02.daemonsets/01.base-understand-01# kubectl -n lili describe ds/myapp01 | grep "Annotations"
Annotations:    deprecated.daemonset.template.generation: 4

```


## 5.清理环境
```
kubectl delete -f .

```

