# 1 nfs-server(172.31.7.203)中创建目录(以项目命名)并暴露
```
## 创建目录(以项目名为名)
mkdir -p /data/lili/
ls -ld /data/lili/

## 暴露
编辑/etc/exports文件，添加如下信息保存并退出
/data/lili *(rw,sync,no_subtree_check,no_root_squash

## 验证暴露
root@master01:~# exportfs -arv | grep /data/lili
exporting *:/data/lili
```

# 2 为项目中相关应用创建目录
```
mkdir  /data/lili/app61/
ls -ld /data/lili/app61/
```

