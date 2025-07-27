01:需要在各worker node上安装nfs client软件之nfs-common.
   (或者说在wyc项目相关的worker node上安装)

02:不然后面Pod在准备nfs volume type的volume时,会报错(所在worker node上无法挂载)
   
03:安装nfs-common的命令为：
```
apt update
apt install -y nfs-common
```
