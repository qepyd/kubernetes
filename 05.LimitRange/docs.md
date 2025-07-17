# 1.基本介绍
limitranges资源(简写limits，kind为LimitRange)是kubernetes中的标准资源，是namespace级别的资源。  
官方参考：https://kubernetes.io/zh-cn/docs/concepts/policy/limit-range/  
```
对所在namespace中各Pod中的Container设置其计算资源的default limits和default requests。
对所在namespace中各Pod中的Container设置其计算资源的最大/最小limits（limits、requests）。
对所在namespace中实施一种资源的申请值和限制值的比值的控制。
```

