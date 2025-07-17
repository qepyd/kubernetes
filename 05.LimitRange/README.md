limitranges资源(简写limits，kind为LimitRange)是kubernetes中的标准资源，是namespace级别的资源。  
官方参考：https://kubernetes.io/zh-cn/docs/concepts/policy/limit-range/  
```
对所在namespace中各Pod中的Container设置其计算资源的限制
   默认计算资源
     ./01.containers-default-cpu-mem/
   最大/最小资源
     ./02.containers-max-min-cpu-mem-not-have-Ratio-1/
     ./03.containers-max-min-cpu-mem-not-have-Ratio-2/
   最大比值
     ./04.containers-max-min-cpu-mem-have-Ratio/

对所在namespace中各Pod总计算资源的限制
   ./05.pod-max-cpu-mem/ 

对所在namesapce中各pvc的限制
  ./06.pvc-max-min/ 
```

