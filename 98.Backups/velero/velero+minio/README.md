# 1.安装minio社区版本之单节点驱动器
```
```

# 2.安装minio的客户端工具mc
```
```

# 3.利用客户端工具mc工具进行相关的配置
mc工具添加别名(以超级用户身份)
```
mc alias set myminio-root-user/ http://172.31.7.200:9000 root 12345678
mc alias ls  myminio-root-user/
```

mc工具创建bucket之k8s01-velero-backups
```
mc mb myminio-root-user/k8s01-velero-backups
mc ls myminio-root-user/
```

mc工具将bucket之k8s01-velero-backups设置为公共可读
```
mc anonymous set public  myminio-root-user/k8s01-velero-backups
```

测试是否可以公共读
```
## 下载图片到本地
wget https://img10.360buyimg.com/img/jfs/t1/253743/19/1794/9143/67654f2cFa801c174/779336fde4b11164.png

## 将图片上传至 k8s01-velero-backups这个桶中
mc put  779336fde4b11164.png  myminio-root-user/k8s01-velero-backups
mc tree -f                   myminio-root-user/k8s01-velero-backups

## 浏览器访问
http://172.31.7.200:9000/k8s01-velero-backups/779336fde4b11164.png
```


