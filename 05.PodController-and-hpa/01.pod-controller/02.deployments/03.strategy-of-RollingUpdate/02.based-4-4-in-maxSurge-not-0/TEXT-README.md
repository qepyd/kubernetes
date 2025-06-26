```
## 当前Pod数 与 期望Pod数
  4 --- "4"

## 滚动更新策略
  strategy:
    type: RollingUpdate   # 默认策略
    rollingUpdate:
      maxSurge: 25%        # 默认25%
      maxUnavailable: 0%   # 默认25%

## 先增还是先减
  maxSurge不为0,所以这里是先增。

## 相关的计算
  maxSurge: 25%
    最大可激增Pod数："4" * 25% = 1(期望Pod数 * 百分比，向上取，为1)
    最大可存在Pod数："4" + 1   = 5(期望Pod数 + 最大可激增Pod数)
  maxUnavailable: 0%
    最大可减少Pod数："4" * 0% = 0(期望Pod数 * 百分比，向下取，为0)
    最少可用的Pod数："4" - 0  = 4(期望Pod数 - 最大不可用Pod数)
    最大可用的Pod数： 4  + 1  = 5(最小可用的Pod数 + 1)

## 滚动更新第一轮
  A:计算
    # 会想着把"当前Pod数"达到与"期望Pod数"一至,会产生扩/缩操作
    OldReplicaSet: +0(4 Pod)
  
    # 看maxSurge参数,最大可激增数为1
    NewReplicaSet: +1(1 Pod)

    # 看maxUnavailable参数,最大可减少为0
    OldReplicaSet: -0(4 Pod)

  B:计算结果及动作
    OldReplicaSet缩至: 4(均可用)
    NewReplicaSet扩至：1(均不可用,假如需要2分钟才能可用)

  C:说明
    是不是保证了"最少可用的Pod数 4"。
    如何说保证了"最大可用的Pod数 5":
      当所增加的Pod(这里肯定是new version)只要有
      一个就绪/可用,就进入到滚动更新的下一轮。

## 滚动更新第二轮
  A:计算
    # 前面已达"最大可存在Pod数",加不了,那就减了
    OldReplicaSet: -1(3 Pod)
  
    # 又未达到"最大可存在Pod数"
    NewReplicaSet: +1(2 Pod)

  B:结果及动作
    OldReplicaSet缩至: 3(均可用)
    NewReplicaSet扩至：2(1可用,1不可用)

## 滚动更新第三轮
  A:计算
    # 前面已达"最大可存在Pod数",加不了,那就减了
    OldReplicaSet: -1(2 Pod)

    # 又未达到"最大可存在Pod数"
    NewReplicaSet: +1(3 Pod)

  B:结果及动作
    OldReplicaSet缩至: 2(均可用)
    NewReplicaSet扩至: 3(2可用,1不可用)
 

## 滚动更新第四轮
  A:计算
    # 前面已达"最大可存在Pod数",加不了,那就减了
    OldReplicaSet: -1(1 Pod)

    # 又未达到"最大可存在Pod数"
    NewReplicaSet: +1(4 Pod)

  B:结果及动作
    OldReplicaSet缩至: 1(均可用)
    NewReplicaSet扩至: 4(3可用,1不可用,已达期望Pod数 4)

    NewReplicaSet上已达"期望Pod数 4",要将OldReplicaSet缩至0,
    但这时还不能直接做,因为需保证"最少可用的Pod数 4",若现在
    将OldReplicaSet缩至0,就无法保证了。
    
    OldReplicaSet缩至：0
```
