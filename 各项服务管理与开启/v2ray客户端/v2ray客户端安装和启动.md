

>平台:  4B . Debian 12 (bookworm)
>
>raspberrypi 6.1.0-rpi4-rpi-v8 #1 SMP PREEMPT Debian 1:6.1.54-1+rpt2 (2023-10-05) aarch64 GNU/Linux

下载v2ray 客户端安装包  https://github.com/v2ray/v2ray-core/releases

因为是树莓派系统4B, 所以下载  `v2ray-linux-arm64-v8a.zip`



## 解压和安装

```bash
$ cd ~
$ mkdir v2ray 
$ cd v2ray
$ unzip  v2ray-linux-arm64-v8a.zip

# 创建配置文件目录
$ sudo mkdir -p /usr/local/share/v2ray
$ sudo mkdir -p /usr/local/etc/v2ray
$ sudo mkdir /var/log/v2ray/

# 拷贝到各个位置
$ sudo cp -a v2ray /usr/local/bin/
$ sudo cp -a v2ctl /usr/local/bin/

$ sudo cp -a systemd/system/v2ray*  /lib/systemd/system/


$ sudo cp -a config.json  /usr/local/etc/v2ray
$ sudo cp -a vpoint_socks_vmess.json  vpoint_vmess_freedom.json /usr/local/etc/v2ray

$ sudo cp -a geoip.dat  geosite.dat  /usr/local/share/v2ray/
```



## 修改配置文件

```bash
# config.json 该文件内记录服务器的配置，IP和端口的内容, 客户端的代理端口也在里面
$ vi  config.json
```



## 配置终端代理

```bash
$  sudo vi /etc/profile    或者修改到单用户的  .bashrc 中

# 开启代理， 下面的端口需要到 config.json 中配置
function  vpn1(){
    export http_proxy=http://127.0.0.1:1087;
    export https_proxy=http://127.0.0.1:1087;
    export ALL_PROXY=socks5://127.0.0.1:1080;
}
function  vpn0(){
    unset  http_proxy;
    unset  https_proxy;
    unset  ALL_PROXY;
}      
# 默认开启
vpn1;
```





