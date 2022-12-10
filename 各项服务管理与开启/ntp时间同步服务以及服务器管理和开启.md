## 目录

- [ntp服务器配置](#ntp服务器配置)
  - [ntp服务器配置编辑](#ntp服务器配置编辑)
  - [重启服务使服务器修改过的配置生效](#重启服务使服务器修改过的配置生效)

- [ntp客户端配置](#ntp客户端配置)
  - [ntp客户端配置编辑](#ntp客户端配置编辑)
  - [重启服务使客户端修改过的配置生效](#重启服务使客户端修改过的配置生效)
  - [执行强制同步系统时间命令](#执行强制同步系统时间命令)




## ntp服务器配置

## ntp服务器配置编辑

```bash
# 打开配置文件和修改 ，修改完成后，需要重启服务
$ vim /etc/chrony.conf

# 文件内容和修改内容如下, 只有三个地方需要修改：

# 修改内容： 注释下面的原始内容，并添加新的内容。 server 后面是服务器地址，如果本机为服务器，那么就应该为本机的IP 或域名。  例如本机的IP 为 10.1.1.2
# server ntpupdate.tencentyun.com iburst   # 被注释的原本内容
server 10.1.1.2 iburst	    # 新增内容,设置本机的服务器， 后面的 iburst 是格式规范，必须有

## ....
# Allow NTP client access from local network.
#allow 192.168.0.0/16
### 新增一行，将本机的 网段填入， 代表为该网段的客户端提供 ntp 时间同步服务
allow 10.1.1.0/24

## ....
# Serve time even if not synchronized to a time source.
# 取消下面的注释，使之同步本地时间。
local stratum 10
```



### 重启服务使服务器修改过的配置生效

```bash
#重启服务,使之生效
$ systemctl restart chronyd.service 
```





## ntp客户端配置

### ntp客户端配置编辑

```bash
# 打开配置文件和修改 ，修改完成后，需要重启服务
$ vim /etc/chrony.conf

# 文件内容和修改内容如下, 只有一个地方需要修改：

# 修改内容： 注释下面的原始内容，并添加新的内容。 server 后面是服务器地址，例如服务器的IP为10.1.1.2 本机ip 为 10.1.1.3
# server ntpupdate.tencentyun.com iburst   # 被注释的原本内容
server 10.1.1.2 iburst	    # 新增内容,设置服务器的地址， 后面的 iburst 是格式规范，必须有
```



### 重启服务使客户端修改过的配置生效

```bash
#重启服务,使之生效
$ systemctl restart chronyd.service 
```



### 执行强制同步系统时间命令

```bash
# 强制同步系统时间命令 
$  chronyc -a makestep 
```

