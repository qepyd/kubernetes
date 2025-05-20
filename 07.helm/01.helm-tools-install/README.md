## 下载二进制包
wget https://get.helm.sh/helm-v3.12.3-linux-amd64.tar.gz
ls -l helm-v3.12.3-linux-amd64.tar.gz

## 安装
tar xf helm-v3.12.3-linux-amd64.tar.gz
ls -ld linux-amd64
mv linux-amd64/helm /usr/bin/
which helm
helm version

