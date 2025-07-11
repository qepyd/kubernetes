#!/bin/bash
#
### 说明
# 查看某ds资源对象其所有的rollout history中的revision
# 以为回滚前做相关的参考
#

### 打印ds资源对象当前所处rollout history revision
Ns="lili"
ResourceName="ds"
ResourceObjectName="myapp01"
DsObjectInRolloutHistoryRevision=$(kubectl -n $Ns rollout history $ResourceName/$ResourceObjectName | sed  '$'d | sed -n '$'p | cut -d " " -f1   )

echo "<==== $ResourceName/$ResourceObjectName Current Rollout History Revision: $DsObjectInRolloutHistoryRevision"

## 打印ds资源对象 rollout history revision，以作为rollout时的参考 
for n in $(kubectl -n $Ns rollout history $ResourceName/$ResourceObjectName | sed '$'d | sed '1,2'd | cut -d " " -f1 ) 
do
  # echo $n

  echo "==> $n Info:
  $(kubectl -n $Ns rollout history --revision=$n $ResourceName/$ResourceObjectName | sed 1d )
  "
done

