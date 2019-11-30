```bash
$vim  /etc/ssh/sshd_config

#添加如下内容
ClientAliveInterval 60				#每60秒 服务器就和客户端沟通一次
ClientAliveCountMax 50                #沟通失败超过50次之后就断线. 也就是50分钟内不会掉线



$systemctl  restart  sshd    #重启服务即可
```