## 排查开始

```bash
# root 权限 或sudo


SSH 登陆日志会记录在  /var/log/btmp  的二进制文件中，需要  lastb 命令查看。
		里面会记录端口登陆失败的信息， 用户名、IP、时间 等


# 查看最后10条 登陆的请求和用户名、IP 等内容。
sudo  lastb -n 10 | tac


# 查看攻击者 IP 及攻击次数
sudo lastb | awk '{ print $3}' | sort | uniq -c | sort -n


# 查看攻击者尝试登陆的用户名
sudo lastb | awk '{ print $1}' | sort | uniq -c | sort -n


#分析攻击者 、 IP
sudo lastb | grep 128.199.42.242 

#查看攻击终止时间
sudo lastb | grep 128.199.42.242 | tac


#查看攻击者IP 地址位置
 curl ipinfo.io/150.158.94.18 
```

## 防范

```bash
#修改ssh 服务端口
sudo vim /etc/ssh/sshd_config
	# Port = 22  修改为 新的端口
	

# 禁止 root 远程登陆

# 禁止 密码 登陆， 启用密钥登陆

# 指定IP 地址登陆。
```



