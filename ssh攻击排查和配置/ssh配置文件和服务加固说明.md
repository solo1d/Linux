服务端加固操作如下：

1. 打开服务端SSH服务的配置文件/etc/ssh/sshd_config，在该文件中修改或添加对应加固项及其加固值。
2. 保存/etc/ssh/sshd_config文件。
3. 重启SSH服务，命令如下：

```bash
# systemctl restart sshd
```



服务端加固策略

SSH服务的所有加固项均保存在配置文件/etc/ssh/sshd_config中，服务端各加固项的含义、加固建议以及openEuler默认是否已经加固为建议加固值请参见[表1](https://docs.openeuler.org/zh/docs/22.09/docs/SecHarden/系统服务.html#zh-cn_topic_0152100390_ta2fdb8e4931b4c1a8f502b3c7d887b95)。

**SSH服务端加固项说明表:**

| **加固项**                                      | **加固项说明**                                               | **加固建议**                                                 | openEuler默认是否已加固为建议值 |
| :---------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- | :------------------------------ |
| Protocol                                        | 设置使用SSH协议的版本                                        | 2                                                            | 是                              |
| SyslogFacility                                  | 设置SSH服务的日志类型。加固策略将其设置为“AUTH”，即认证类日志 | AUTH                                                         | 是                              |
| LogLevel                                        | 设置记录sshd日志消息的层次                                   | VERBOSE                                                      | 是                              |
| X11Forwarding                                   | 设置使用SSH登录后，能否使用图形化界面                        | no                                                           | 是                              |
| MaxAuthTries                                    | 最大认证尝试次数                                             | 3                                                            | 否                              |
| PubkeyAuthentication                            | 设置是否允许公钥认证。                                       | yes                                                          | 是                              |
| RSAAuthentication                               | 设置是否允许只有RSA安全验证                                  | yes                                                          | 是                              |
| IgnoreRhosts                                    | 设置是否使用rhosts文件和shosts文件进行验证。rhosts文件和shosts文件用于记录可以访问远程计算机的计算机名及关联的登录名 | yes                                                          | 是                              |
| RhostsRSAAuthentication                         | 设置是否使用基于rhosts的RSA算法安全验证。rhosts文件记录可以访问远程计算机的计算机名及关联的登录名 | no                                                           | 是                              |
| HostbasedAuthentication                         | 设置是否使用基于主机的验证。基于主机的验证是指已信任客户机上的任何用户都可以使用SSH连接 | no                                                           | 是                              |
| PermitRootLogin                                 | 是否允许root账户直接使用SSH登录系统说明： 若需要直接使用root账户通过SSH登录系统，请修改/etc/ssh/sshd_config文件的PermitRootLogin字段的值为yes。 | no                                                           | 否                              |
| PermitEmptyPasswords                            | 设置是否允许用口令为空的账号登录                             | no                                                           | 是                              |
| PermitUserEnvironment                           | 设置是否解析 ~/.ssh/environment和~/.ssh/authorized_keys中设定的环境变量 | no                                                           | 是                              |
| Ciphers                                         | 设置SSH数据传输的加密算法                                    | aes128-ctr,aes192-ctr,aes256-ctr,chacha20-poly1305@openssh.com,aes128-gcm@openssh.com,aes256-gcm@openssh.com | 是                              |
| ClientAliveCountMax                             | 设置超时次数。服务器发出请求后，客户端没有响应的次数达到一定值，连接自动断开 | 0                                                            | 否                              |
| Banner                                          | 指定登录SSH前后显示的提示信息的文件                          | /etc/issue.net                                               | 是                              |
| MACs                                            | 设置SSH数据校验的哈希算法                                    | hmac-sha2-512,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-256-etm@openssh.com | 是                              |
| StrictModes                                     | 设置SSH在接收登录请求之前是否检查用户HOME目录和rhosts文件的权限和所有权 | yes                                                          | 是                              |
| UsePAM                                          | 使用PAM登录认证                                              | yes                                                          | 是                              |
| AllowTcpForwarding                              | 设置是否允许TCP转发                                          | no                                                           | 是                              |
| Subsystem sftp /usr/libexec/openssh/sftp-server | sftp日志记录级别，记录INFO级别以及认证日志。                 | -l INFO -f AUTH                                              | 是                              |
| AllowAgentForwarding                            | 设置是否允许SSH Agent转发                                    | no                                                           | 是                              |
| GatewayPorts                                    | 设置是否允许连接到转发客户端端口                             | no                                                           | 是                              |
| PermitTunnel                                    | Tunnel设备是否允许使用                                       | no                                                           | 是                              |
| KexAlgorithms                                   | 设置SSH密钥交换算法                                          | curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256 |                                 |
| LoginGraceTime                                  | 限制用户必须在指定的时限内认证成功，0 表示无限制。默认值是 60 秒。 | 60                                                           | 否                              |

> **说明：**
> 默认情况下，登录SSH前后显示的提示信息保存在/etc/issue.net文件中，/etc/issue.net默认信息为“Authorized users only. All activities may be monitored and reported.”。







- 客户端加固策略

  SSH服务的所有加固项均保存在配置文件/etc/ssh/ssh_config中，客户端各加固项的含义、加固建议以及openEuler默认是否已经加固为建议加固值请参见[表2](https://docs.openeuler.org/zh/docs/22.09/docs/SecHarden/系统服务.html#zh-cn_topic_0152100390_tb289c5a6f1c7420ab4339187f9018ea4)。

  **表 2** SSH客户端加固项说明

  

  | **加固项**       | **加固项说明**                          | **加固建议**                                                 | openEuler默认是否已加固为建议值 |
  | :--------------- | :-------------------------------------- | :----------------------------------------------------------- | :------------------------------ |
  | KexAlgorithms    | 设置SSH密钥交换算法                     | ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256 | 否                              |
  | VerifyHostKeyDNS | 是否使用DNS或者SSHFP资源记录验证HostKey | ask                                                          | 否                              |

  > **说明：**
  > 对于使用dh算法进行密钥交换的第三方客户端和服务端工具，要求允许建立连接的最低长度为2048bits。

### 其他安全建议

- SSH服务仅侦听指定IP地址

  出于安全考虑，建议用户在使用SSH服务时，仅在必需的IP上进行绑定侦听，而不是侦听0.0.0.0，可修改/etc/ssh/sshd_config文件中的ListenAddress配置项。

  1. 打开并修改/etc/ssh/sshd_config文件

     ```bash
     vi /etc/ssh/sshd_config
     ```

     修改内容如下，表示绑定侦听IP为 *192.168.1.100*，用户可根据实际情况修改需要侦听的IP

     ```bash
     ...
     ListenAddress 192.168.1.100
     ...
     ```

  2. 重启SSH服务

     ```bash
     systemctl restart sshd.service
     ```

- 限制SFTP用户向上跨目录访问

  SFTP是FTP over SSH的安全FTP协议，对于访问SFTP的用户建议使用专用账号，只能上传或下载文件，不能用于SSH登录，同时对SFTP可以访问的目录进行限定，防止目录遍历攻击，具体配置如下：

  > **说明：**
  > sftpgroup为示例用户组，sftpuser为示例用户名。

  

  1. 创建SFTP用户组

     ```bash
     groupadd sftpgroup
     ```

  2. 创建SFTP根目录

     ```
     ""mkdir /sftp
     ```

  3. 修改SFTP根目录属主和权限

     ```bash
     chown root:root /sftp
     chmod 755 /sftp
     ```

  4. 创建SFTP用户

     ```bash
     useradd -g sftpgroup -s /sbin/nologin sftpuser
     ```

  5. 设置SFTP用户的口令

     ```bash
     passwd sftpuser
     ```

  6. 创建SFTP用户上传目录

     ```bash
     mkdir /sftp/sftpuser
     ```

  7. 修改SFTP用户上传目录属主和权限

     ```bash
     chown root:root /sftp/sftpuser
     chmod 777 /sftp/sftpuser
     ```

  8. 修改/etc/ssh/sshd_config文件

     ```bash
     vi /etc/ssh/sshd_config
     ```

     修改内容如下：

     ```bash
     #Subsystem sftp /usr/libexec/openssh/sftp-server -l INFO -f AUTH
     Subsystem sftp internal-sftp -l INFO -f AUTH
     ...
     
     Match Group sftpgroup                  
         ChrootDirectory /sftp/%u
         ForceCommand internal-sftp
     ```

     >  **说明：**
     >
     > - %u代表当前sftp用户的用户名，这是一个通配符，用户原样输入即可。
     > - 以下内容必须加在/etc/ssh/sshd_config文件的末尾。
     >
     > ```bash
     > Match Group sftpgroup                    
     >     ChrootDirectory /sftp/%u  
     >     ForceCommand internal-sftp  
     > ```

  9. 重启SSH服务

     ```bash
     systemctl restart sshd.service
     ```

- SSH远程执行命令

  OpenSSH通用机制，在远程执行命令时，默认不开启tty，如果执行需要密码的命令，密码会明文回显。出于安全考虑，建议用户增加-t选项，确保密码输入安全。如下：

  ```bash
  ssh -t testuser@192.168.1.100 su
  ```

  > **说明：**
  > 192.168.1.100为示例IP，testuser为示例用户。
