# 第1章 安装minio社区版本之单节点驱动器并配置
## 1.1 安装minio服务器
```
```

## 1.2 安装minio的客户端工具mc
```
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
cp mc  /usr/local/bin/
which mc
```

## 1.3 利用客户端工具mc工具进行相关的配置
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
mc tree -f                    myminio-root-user/k8s01-velero-backups

## 浏览器访问
http://172.31.7.200:9000/k8s01-velero-backups/779336fde4b11164.png
```

为k8s01-velero-backups这个bucket创建策略
```
## 编写策略文件
cat >/data/minio/conf/readwrite-to-k8s01-velero-backups-in-bucket.json<<'EOF'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::k8s01-velero-backups/*"
            ]
        }
    ]
}
EOF 

## 创建策略
mc admin policy create myminio-root-user  readwrite-to-k8s01-velero-backups-in-bucket  /data/minio/conf/readwrite-to-k8s01-velero-backups-in-bucket.json

## 查看策略
mc admin policy info   myminio-root-user  readwrite-to-k8s01-velero-backups-in-bucket
```

创建 velero 用户，并关联 readwrite-to-k8s01-velero-backups-in-bucket 策略
```
## 创建 velero 用户
mc admin user add  myminio-root-user/
  # 
  # 交互式输入Enter Access Key，这里输入：velero
  # 交互式输入Enter Secret Key，这里输入：12345678
  # 
mc admin user ls   myminio-root-user/
  #
  # 列出所有用户
  #

## 关联策略
mc admin policy attach  myminio-root-user/  readwrite-to-k8s01-velero-backups-in-bucke  --user velero

## 查看 velero的信息
mc admin user  info  myminio-root-user/  velero
```

velero用户测试读写
```
## 以velero用户添加一个别名
mc alias set myminio-velero-user/ http://172.31.7.200:9000 velero 12345678
mc alias ls  myminio-velero-user/

## 下载文件
mc get  myminio-velero-user/k8s01-velero-backups/779336fde4b11164.png    /tmp/
ls -l /tmp/779336fde4b11164.png

## 删除文件
mc rm  myminio-velero-user/k8s01-velero-backups/779336fde4b11164.png
mc tree -f myminio-velero-user/k8s01-velero-backups

## 上传文件
mc put /tmp/779336fde4b11164.png myminio-velero-user/k8s01-velero-backups
mc tree -f myminio-velero-user/k8s01-velero-backups
```





