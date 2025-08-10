在k8s的各worker node或binbin项目相关的worker node上安装nfs-common软件包。不需要在k8s的各control-plane上安装。
```
sudo apt update
sudo chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow
sudo apt install -y nfs-common
```
