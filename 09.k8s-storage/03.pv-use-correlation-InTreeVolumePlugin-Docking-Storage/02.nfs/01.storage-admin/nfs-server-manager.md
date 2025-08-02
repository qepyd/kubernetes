# 1 nfs-server(172.31.7.203)中创建目录(以项目命名)并暴露
```
## 创建目录(以项目名为名)
mkdir -p /data/binbin/
ls -ld /data/binbin/

## 暴露
编辑/etc/exports文件，添加如下信息保存并退出
/data/binbin *(rw,sync,no_subtree_check,no_root_squash

## 验证暴露
root@master01:~# exportfs -arv | grep /data/binbin
exporting *:/data/binbin
```

# 2 为binbin项目的相关应用准备存储
```
mkdir  /data/binbin/app21/
ls -ld /data/binbin/app21/

mkdir  /data/binbin/app22/
ls -ld /data/binbin/app22/
```


