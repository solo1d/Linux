## 目录

- [服务器配置](#服务器配置)
  - [1、安装Postfix邮件服务器](#1、安装Postfix邮件服务器)
  - [2、创建邮箱账户和密码](#2、创建邮箱账户和密码)
  - [3、修改邮件服务器的配置](#3、修改邮件服务器的配置)
  - 




## 服务器配置

### 1、安装Postfix邮件服务器

```bash
# 环境为 Debian 10 ， # 安装时出现的选项，全部为默认即可。
$  sudo apt install  -y postfix  

#支持的协议链接, smtps pop3s     # centos 为   dovecot  即可
$  sudo apt install  -y dovecot-antispam dovecot-imapd dovecot-mysql dovecot-sqlite dovecot-auth-lua dovecot-ldap dovecot-pgsql dovecot-submissiond dovecot-core dovecot-lmtpd         dovecot-pop3d dovecot-dev dovecot-lucene dovecot-sieve dovecot-gssapi dovecot-managesieved dovecot-solr 

```



### 2、创建邮箱账户和密码

```bash
$ useradd -s /sbin/nologin  mail1
$ useradd -s /sbin/nologin  mail2


$ passwd  mail1
$ passwd  mail2


#查看是否成功
$ cat /etc/passwd | egrep "mail1|mail2"
# 输出如下
	mail1:x:1001:1001::/home/mail1:/sbin/nologin
	mail2:x:1002:1002::/home/mail2:/sbin/nologin

```



### 3、修改邮件服务器的配置

```bash
# 编辑邮件服务器配置文件， 如果该文件未找到，就去编辑 main.cf 文件
$ vim /etc/postfix/main.cf.proto  

#修改内容如下；
mydomain = chinaskills.et   #域名后缀，取消该选项前的 # 。并修改  = domain.tld 为 = chinaskills.et
	
inet_interfaces = all			# 监听外部端口，为其他的IP服务。取消面前的注释即可。如果不为 all, 那就修改。
```







