# 1 树内卷插件之projected的介绍
参考: https://kubernetes.io/zh-cn/docs/concepts/storage/projected-volumes/  
一个 projected 卷可以将若干现有的卷源映射到同一个目录之上，目前，以下类型的卷源可以被投射：
```
configMap
  #
  # configmaps资源对象
  #
secret
  #
  # secrets资源对象
  # 
downwardAPI
  #
  # downwardAPI卷插件所能获取到Pod的相关信息
  #
serviceAccountToken
  #
  # 将Pod所指定serviceAccount资源对象的token(api-server会为其生成)进行挂载
  # 
clusterTrustBundle
  #
  # Kubernetes v1.33 [beta] 
  # 
```

我们在创建一个Pod时，其Pod级别会有一个默认projected卷，其name是随机的，各容器均会挂载。
```
## Pod级别会有一个默认projected卷
  volumes:
  - name: kube-api-access-pv5t4
    projected:
      defaultMode: 420
      sources:
      - serviceAccountToken:          # Pod级别的serviceAccountName默认值为default（创建ns资源对象时,会自动创建serviceAccount/default对象）
          expirationSeconds: 3607
          path: token
      - configMap:
          items:
          - key: ca.crt
            path: ca.crt
          name: kube-root-ca.crt      # 创建ns资源对象时,会自动创建cm/kube-root-ca.crt对象
      - downwardAPI:
          items:
          - fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
            path: namespace

## 各容器均会挂载Pod级别的默认projected卷
volumeMounts:
- name: kube-api-access-pv5t4
  mountPath: /var/run/secrets/kubernetes.io/serviceaccount
  readOnly: true
```

# 2 Pod的默认projected卷
```
## 应用manifests
root@master01:~# kubectl apply -f deploy_default-projected-volume.yaml  --dry-run=client
deployment.apps/default-projected-volume created (dry run)
root@master01:~#
root@master01:~# kubectl apply -f deploy_default-projected-volume.yaml
deployment.apps/default-projected-volume created

## 列出deployment/default-projected-volume对象
root@master01:~# kubectl -n lili get deployment.apps/default-projected-volume
NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
default-projected-volume   2/2     2            2           21s
root@master01:~#

## 列出deployment/default-projected-volume对象所编排的各Pod副本
root@master01:~# kubectl -n lili describe deployment.apps/default-projected-volume | grep "NewReplicaSet:" | cut -d " " -f4
default-projected-volume-697665b54b
root@master01:~#
root@master01:~# kubectl  -n lili get pods | grep default-projected-volume-697665b54b
default-projected-volume-697665b54b-khzmq   1/1     Running   0          109s
default-projected-volume-697665b54b-rbzr5   1/1     Running   0          109s

## 以deployment/default-projected-volume对象所编排的pod/default-projected-volume-697665b54b-khzmq来查看
root@master01:~# kubectl  -n lili get pods/default-projected-volume-697665b54b-khzmq -o json | jq ".spec.serviceAccountName"
"default"

root@master01:~# kubectl  -n lili get pods/default-projected-volume-697665b54b-khzmq -o json  | jq ".spec.volumes[]"
{
  "name": "kube-api-access-zkt6n",
  "projected": {
    "defaultMode": 420,
    "sources": [
      {
        "serviceAccountToken": {
          "expirationSeconds": 3607,
          "path": "token"
        }
      },
      {
        "configMap": {
          "items": [
            {
              "key": "ca.crt",
              "path": "ca.crt"
            }
          ],
          "name": "kube-root-ca.crt"
        }
      },
      {
        "downwardAPI": {
          "items": [
            {
              "fieldRef": {
                "apiVersion": "v1",
                "fieldPath": "metadata.namespace"
              },
              "path": "namespace"
            }
          ]
        }
      }
    ]
  }
}
root@master01:~#
root@master01:~# kubectl  -n lili get pods/default-projected-volume-697665b54b-khzmq -o json  | jq ".spec.containers[].name,  .spec.containers[].volumeMounts[]" 
"busybox"
{
  "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount",
  "name": "kube-api-access-zkt6n",
  "readOnly": true
}
root@master01:~#
root@master01:~# kubectl  -n lili exec -it pods/default-projected-volume-697665b54b-khzmq -c busybox --  ls -l /var/run/secrets/kubernetes.io/serviceaccount
total 0
lrwxrwxrwx    1 root     root            13 Jul 30 07:34 ca.crt -> ..data/ca.crt
lrwxrwxrwx    1 root     root            16 Jul 30 07:34 namespace -> ..data/namespace
lrwxrwxrwx    1 root     root            12 Jul 30 07:34 token -> ..data/token
```
