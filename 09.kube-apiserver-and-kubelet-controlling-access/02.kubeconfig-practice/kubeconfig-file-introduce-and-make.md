
# 1.kubeconfig的基本介绍
官方参考
```
https://kubernetes.io/zh-cn/docs/concepts/configuration/organize-cluster-access-kubeconfig/
```
基本介绍
```
kubeconfig是遵循一定内容格式的文件统称。
用来承载kube-apiserver组件各实例其client来连接时的一些信息。
其信息肯定是要有：kube-apiserver的连接地址、client携带的所谓认证信息。
```

# 2.kubeconfig的格式展示
```
apiVersion: v1
kind: Config
clusters: <[]Object>
  - name: <String>
    cluster: <Object>
      # <== kube-apiserver组件实例的连接地址
      server: <String>
      # <== kubernetes集群的ca证书(证书)或代理认证服务的地址
      proxy-url: <string>
      certificate-authority-data: <String>
users: <[]Object>
  - name: <String>
    user: <Object>
      # <== x509客户端证书(证书、私钥)
      client-certificate-data: <String>
      client-key-data: <String>
      # <== token
      token: <String>
contexts: <[]Object>
  - name: <String>        # 其users字段中某列表的name@其clusters字段中某列表的name
    context: <Object>
      user: <String>      # 其users字段中某列表的name
      cluster: <String>   # 其clusters字段中某列表的name
current-context: <string> # 其contexts字段中某列表的name
```

# 3.客户端工具kubectl找寻kubeconfig的优先级
可通过 kubectl config --help 看到其对优先级的介绍
```
## 相关优化级
--kubeconifg   >   $KUBECONFIG   >  $HOME/.kube/config

## 相关的介绍
--kubeconfig参数
  #
  # 命令行使用参数指定的最大嘛
  # 可以指定多个kubeconfig文件
  #   例如：--kubeconfig  /path/kubeconfig   --kubeconfig /path/mykubeconfig
  # 当指定了多个kubeconfig文件时
  #   各kubeconfig是不会合并的
  #   以最后(右/下)的为准
  #

$KUBECONFIG环境变量
  #
  # 变量的值可以有多个kubeconfig
  #   例如: export KUBECONFIG=/path/kubeconfig:/path/mykubeconfig
  # 当指定了多个kubeconfig时
  #   各kubeconfig是会合并的
  #     <[]Object>类型的各字段下各列表会去重(根据name,以最左边的为准)合并。
  #     current-context字段的值,以第一个(从左至右)且拥有值的为准 
  #   

$HOME/.kube/config
  #
  # 具体文件
  # 用户家目录下的.kube/目录下名为config的kubeconfig
  #
```

# 4.客户端工具kubectl工具查看kubeconfig文件内容
查看所找到kubeconfig文件的所有内容,不显示敏感信息
```
root@master01:~# kubectl --kubeconfig /etc/kubernetes/admin.conf   config view  --raw=false
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://k8s01-kubeapi-comp.qepyd.com:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
```

查看所找到kubeconfig文件的所有内容，显示敏感信息(经过了base64加密)，且我这里的是kubernetes的学习环境
```
root@master01:~# kubectl --kubeconfig /etc/kubernetes/admin.conf   config view  --raw=true
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJMU1EVXhNVEF6TlRjMU1sb1hEVE0xTURVd09UQXpOVGMxTWxvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTXB4CnhzMDl1ekczY3NJYWtYQ2lqRHFJbUFNbDkzb1hFVzFBSTY4cWNWNXZmVVNUc212QS9MdE9ySUpRV29aQzJrRVIKVWtxWDVXVnNaV1QyZGJ4RkZoSlJpUUJmQ3dNbWp3dVZoOUJZS1pUVWRIbmlCVktJWC9xQUpQTE1qMlpXUnhSUgordDRld2lxN3RJWlZraGNiRjhvcE1UNWwwa0RxV1pGNjJ4RGNvbks1Y1ZIcjlHOHdsdXJLNFdYZXp3RUE0U2NBCkFjekZhY3QxWTBaa0hFeFVkQnJmcDhmcTl2cllyS3plVG1SSUdSaDdBbkFzRk1iUXI0eXlJM1FHdWU4LzZ1bWgKeW9zVWVtYWtmeGhhSGN1WS8zeXBFNXV3YTR6WEhTMmU3WVVzNnBBdFlJOHdWU1psZk05Tk9tK25icjg3ZEw0bgpaZFdBVjZaYVZVRjYvMmZFVUJNQ0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZFWkptNkw4VEhKMTAvSGp2TklVaHJLbDd0RnFNQlVHQTFVZEVRUU8KTUF5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBRXNqaXdBR2RreVhmV0FpSkcraQpZR3cwcHhhUWpXUkJ2TlZDdXlOOENOQkVlalJBYUk1Q292TkpZdjdrU0d6dnovUGRXcDdtTTIrRkFtSVdWV1RaCnpKekpKQTlIaXdqTWtTMS8yOWNDY2Z6bk5zaGhVRnN6ZGErazBvMkk4UW9hZXArTHI4SjU0ZE8zVVU4OTB6OEYKQnRqRG1FWFFMRGJqd3o5Ujlkb0lOcEo5SzdCSm1YeTQyVTBNbjVFOEJJL2djYnN0Uzd4S0dSM1RnVGFKMHo5TApacWpoZEZVQXNYdWg4bExyRk1oYzB1WWJIUWxnd2VaeFROZTVRdGlCZjBUMDBaTnlXL2wxMjFKYUY4d2JFWGtNCmdZM2RqcUtHUnV5Q29OSVhybUhmSGJCa3JBekdkRGxtNm9JSjRheVQzSmJzaWFObVJFanErS1pPWmpET3VZOVEKbUw4PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://k8s01-kubeapi-comp.qepyd.com:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURJVENDQWdtZ0F3SUJBZ0lJY2EyRHNOY1c3UzR3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBMU1URXdNelUzTlRKYUZ3MHlOakExTVRFd016VTNOVFZhTURReApGekFWQmdOVkJBb1REbk41YzNSbGJUcHRZWE4wWlhKek1Sa3dGd1lEVlFRREV4QnJkV0psY201bGRHVnpMV0ZrCmJXbHVNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQXRGQVQvZTFhNE5GWXJFWFoKQlR4OWxKMmtVSkxEME9xV0h3M2RlSVRadWl1cTdNVDY3SmJDMWN2ejdYVXY3b3NrTDYxbnA2OUoxY244SEM0MgpmQUdPTjVJR2gxWU14V1JTY3lmN2lRNjZ5Q0N2RFVGcVUwTkw3d1RTQkg3cUdNQzlDOE5PNzZydVcxWlRMOHFDCktEeXc0VUhSQWJSY0VhaDFWMS9KNTkvNStzblZsenB0THRuYjk2WUQ2NHNiN1hjb1Y3UWlXVDh0UlM3ZXJvNFQKTVpqWmZpY3E1cXJzYmUxUDZsL0FlSjkwRkdaS2RIMGtJNW9vTFc3YTF6bnhsR3p4R0xORG9DbGNVQm1BNDFhcQpuQldOYlNYL0FqdmpXS0NNekM0ZVd2YUpwajNLMjljdU5iNFRWSG5aUHp2NkJRTjF6Y0hkUGZYUms0N1hWSTRBClRWM2hJd0lEQVFBQm8xWXdWREFPQmdOVkhROEJBZjhFQkFNQ0JhQXdFd1lEVlIwbEJBd3dDZ1lJS3dZQkJRVUgKQXdJd0RBWURWUjBUQVFIL0JBSXdBREFmQmdOVkhTTUVHREFXZ0JSR1NadWkvRXh5ZGRQeDQ3elNGSWF5cGU3UgphakFOQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBaTlwSXF4NldjaTdENjlrVTlkQ2UwdDd4ckd3RGRvTHdQSVZ3CkltV05NMjJvb1F4NXZVZmpwU0tPK2Zid09hSzdJRDUyQkh2MzFmK0Y5TmlER0daM2NIQjdIbWdjUkJBRW5TVTMKWG81L2FaRklXVlArR3RRbUJSQUFFQThIWExRdlJremlRa2FiZUQraFpFUGFRNFR0WXRjTlFDcnVQZkdsTzlKLwpra2lDcWNNVjBLSWhTQWM4QjJ4dXd4SFFjeTlTdzdNdGxiQWh0WkVwTHlTdjg0a0F5QTdRZS90SzZpbXAvcnBWClpaaVpwdGJvZnFVSS9mQVg4R1ZkaVhIc2RhMEFCUi9YT0piL1duS1BZZDZlMi9Memt1czdRK2Z1a1J5czUzY1AKMDZWcCt3dEJ2Uk84bVVXeklNdWFZbUVvVmJZa3Rwb01QV2pqV2M4ZFlWRVRINGdwZkE9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBdEZBVC9lMWE0TkZZckVYWkJUeDlsSjJrVUpMRDBPcVdIdzNkZUlUWnVpdXE3TVQ2CjdKYkMxY3Z6N1hVdjdvc2tMNjFucDY5SjFjbjhIQzQyZkFHT041SUdoMVlNeFdSU2N5ZjdpUTY2eUNDdkRVRnEKVTBOTDd3VFNCSDdxR01DOUM4Tk83NnJ1VzFaVEw4cUNLRHl3NFVIUkFiUmNFYWgxVjEvSjU5LzUrc25WbHpwdApMdG5iOTZZRDY0c2I3WGNvVjdRaVdUOHRSUzdlcm80VE1aalpmaWNxNXFyc2JlMVA2bC9BZUo5MEZHWktkSDBrCkk1b29MVzdhMXpueGxHenhHTE5Eb0NsY1VCbUE0MWFxbkJXTmJTWC9BanZqV0tDTXpDNGVXdmFKcGozSzI5Y3UKTmI0VFZIblpQenY2QlFOMXpjSGRQZlhSazQ3WFZJNEFUVjNoSXdJREFRQUJBb0lCQVFDa3duZENFOXh5aVZncApNam0zbXlwMDNnY0N5Tmk4MFY0VFNpd1FyL1B6Tld1ZHBmQlN0ditaTkIvVDNyekpqOEtrL2lJMUN1ckF1eXZ1CjVCdE0vRzdqUUQ5TzhzWUFxRWJlaXE1QThvQ2gxWnVlMVNNK3FjTjh5RDdQZE5pYmZhSkFXVnFMalBqMzVNMW0KWWZqRW81Qk1oRU5pOTFjWm00QjlNajNmN3IwUTlrdGpNclpjaUhGS0ZPVjBodDJON1lvc2pIRVhXMi9SYjhUdgpSRUJubk9weHM0T25Gc0Z3bllMMm9HbTRnSi9aWDdtMWgrZzViM2dNNUVzVmppYUNkNEFSSC9mYlZTODRGRFRMCml3TkhMYk50UEJJSWZteTA5cVp2NXg4MjB5ZVR5QmhTNHloWGlJd3JPZkJvY0xxQlFBRW5sT0oyTnZnQTJMMjAKUkZabEhPMEJBb0dCQU9HMllNLytsS045eFkxeFNBSDNubjJsdk1wNE93K3M2b2wvMkFGc2hFODVJaWEyWHRKMwpFZTF1aEhDRHc4aWpVWGo0aWthRm8wUmlBcDh0SmV6QzNMWlo0NHR6NEduOGVhZDEwN2w1aVlVV01nQXh3MkdUCmpmTHIrVmFpN0NPaG5vVDJtaytidUVNWW52UHJ6UXhUWUtBTjl6OGpRTkVqVkE5b0RDdHNBQlNEQW9HQkFNeUMKSkk0eUFLajI0akVkY1lTdEpHYXAzZWl5aVdsWHhMM1dQODhoL3BlbHd1L3VjL25KQ01DSUhxOExUTXpMZEllRgp3Y3lRR1F4NUsvQXRvMkgxU3hFOTNMcG1JUDJmeWY4VkcxS1lFYmxsRUFJQ2M0YVlOS3FTUWtydkV4TXNwMjNjCm80b2lkU2FvSTN4WExGMGYxVVRVcmJvNFdoS3ZRWXFpVmtBRllaN2hBb0dBSnVCYTNIaGs4YVFBR3RTZ0tuYVQKL2VCR0hEbUpNckg5MDZFSmUzVk5kTGZLZ2hCM1ZKamRwWitiZ0NXeDJ5VUdLMmZqcVRIclpTUGNmNzR2QWhDdQpJMXBvTHVUT2luTEtJV1hTQ2VnOUg0Y3JKWTFzc2FuUWtUN0R1NEJrVzk3Q2h2UlNyOU9LY1VRVVhMOEltazdpCkhhOUtIcjNidENuNW1JMjdTdDlYUkRFQ2dZRUFzNktGTlpuYVZwQTFjdXJuOGFDY1hzbEtzTUZTVGdQWVB0L1kKd0xxZGhOc0hkZlZBVGVJMkc5ZjFDOUNqTHlodlBUTlNYYnNkSllXeUFKQTErUytiTnBQZU5LVE15YnIzbFdZVwp6OS9mZ2JleDdmSDFRLzZpRkVuUWpUMmV4Ykx0aG1UT0NlSG1nWVFqVjI3Qyt6R2hCWXJDNXRYazJKQzB3MitBCnowOXF4a0VDZ1lCVk54cTg5Ym5OaXRjR1FhYWxEVk9ZYjVieGFQRXdOQVhUZkdhNXVueWJyNm9kZFdSelZKV24Kc1lJV2tNRVdZTVZJb1VwRTkyZ01zY1JDcEFxUWJ0TUUxMXFnT2NYU0ptUnRTb0tIaFVtb3dHRlFScmNzVWIzNQpXY3lVekJ1R2hKYVR3N0JCSWJuY2JrdkNCYkRITjhVMXl6YUJnaVVwLytlY1NIWTRCK3pYamc9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=
```
