#!/bin/bash
#
### 说明
# 查看某deploy资源对象其所有的rs资源对象的描述信息
# 打印各rs资源对象中Pod Template中的信息,以及对应的history revision
#

### 通过deploy资源对象当前 history 的编号 找出其 NewReplicaSet
Ns="lili"
Source="deploy"
Object="myapp01"

DeployObjectNewHistoryVersion=$( kubectl -n $Ns rollout history $Source/$Object | grep "^[0-9]" | cut -d " " -f1  | tail -1 )
   # 取出所有REVISION,取最后一个
   # 
   # echo $DeployObjectNewHistoryVersion

NewHistoryVersionPodTemplateHash=$(  kubectl -n $Ns rollout history $Source/$Object --revision=$DeployObjectNewHistoryVersion | grep pod-template-hash | cut -d "=" -f2 )
   # 取出deploy资源对象history最新version中的pod template hash
   #
   # echo $NewHistoryVersionPodTemplateHash

NewReplicaSet=$(kubectl -n $Ns get rs | grep "${Object}-${NewHistoryVersionPodTemplateHash}" | cut -d " " -f1 )
   # 列出NewReplicaSet(rs资源对象),取其name
   #
   # echo $NewReplicaSet

if [ $(kubectl -n $Ns describe $Source/$Object | grep -w "NewReplicaSet:" | cut -d " " -f4)  == $NewReplicaSet ];then
  echo -e "\n#<=== $Source/$Object Object RolloutHistoryVersion=$DeployObjectNewHistoryVersion  RS(NewReplicaSet)= [ $NewReplicaSet ] "
  echo " "
else
   echo "error: Did not achieve the desired effect，exit script"
   exit 1
fi


## 列出deploy资源对象各rollout history version对应的image
for n in  $(  kubectl -n $Ns rollout history $Source/$Object | grep "^[0-9]" | cut -d " " -f1  )
do
   # echo $n

   HistoryVersionPodTemplateHash=$(  kubectl -n $Ns rollout history $Source/$Object --revision=$n | grep pod-template-hash | cut -d "=" -f2 )
   # echo $HistoryVersionPodTemplateHash

   Rs=$(kubectl -n $Ns get rs | grep "${Object}-${HistoryVersionPodTemplateHash}" | cut -d " " -f1 )
   # echo $Rs

   echo "==>RolloutHistoryVersion=$n RS=$Rs
  $(kubectl -n $Ns describe rs/$Rs | grep  -A 10000 "Pod Template:" | grep -B 10000 'Events:' | sed '$'d)
   "
done
