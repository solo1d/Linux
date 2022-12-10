## 目录

- [服务器配置](#服务器配置)
  - [1、安装dns服务器程序包](#1、安装dns服务器程序包)
  - [2、编辑DNS服务器主配置文件](#2、编辑DNS服务器主配置文件)
  - [3、编辑DNS服务器区域配置文件](#3、编辑DNS服务器区域配置文件)
  - [4、切换目录到正反向区域配置文件中并进行拷贝和修改](#4、切换目录到正反向区域配置文件中并进行拷贝和修改)
  - [5、编辑新增的正向区域文件](#5、编辑新增的正向区域文件)
  - [6、编辑新增的反向区域文件](#6、编辑新增的反向区域文件)
  - [7、重启DNS服务](#7、重启DNS服务)
  - [8、重启DNS服务器](#8、重启DNS服务器)
  - [9、域名解析测试工具](#9、域名解析测试工具)

- 



## 服务器配置

### 1、安装dns服务器程序包

```bash
#  bind 为服务包，  bind-utils 为测试工具包 
#  在操作系统的安装镜像中也存在这两个安装包。 使用命令 rpm -Uvh 安装包名 安装即可。
$ yum install -y bind bind-utils 


# 将镜像安装光盘插入， 并挂载到 /mnt 下
$ mount -o loop /dev/sr0 /mnt
$ cd /mnt/Packages/
$ rpm -Uvh bind-9.7.3-8.P3.el6.x86_64.rpm 
$ rpm -Uvh bind-utils-9.7.3-8.P3.el6.x86_64.rpm 
```



### 2、编辑DNS服务器主配置文件

```bash
# 编辑DNS服务器配置文件
$ vim /etc/named.conf 


# 该文件内容如下， 共修改2处位置：
options {
	listen-on port 53 { 192.168.141.128; };  # 此处将 127.0.0.1 修改为本机地址 192.168.141.128 ， 监听该地址的 53号端口（ 也就是本机端口） ,如果目前配置的是备用DNS 这个IP也配置为主DNS服务器即可。
	
	listen-on-v6 port 53 { ::1; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        
	allow-query     { any; };   # 此处将 localhost 变更为 any 全部， 允许所有的主机查询。


```



### 3、编辑DNS服务器区域配置文件

```bash
# 编辑DNS服务器区域配置文件
$  vim /etc/named.rfc1912.zones 

# 该文件内容如下， 共新增2处配置：

# 拷贝1份 下面的第一个配置选项到末尾。 也就是第1、 个
# 1、
zone "localhost.localdomain" IN {
	type master;
	file "named.localhost";
	allow-update { none; };
};

# 2、
zone "localhost" IN {
	type master;
	file "named.localhost";
	allow-update { none; };
};

# 3、
zone "1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa" IN {
	type master;
	file "named.loopback";
	allow-update { none; };
};

# 拷贝1份 下面的第一个配置选项到末尾。 也就是第4、 个
# 4、
zone "1.0.0.127.in-addr.arpa" IN {
	type master;
	file "named.loopback";
	allow-update { none; };
};

# 5、
zone "0.in-addr.arpa" IN {
	type master;
	file "named.empty";
	allow-update { none; };
};


# 将第1个的配置 拷贝到这里，并进行修改。
# 此配置为正向区域，创建正反向区域 , 域名
zone "skills.com" IN {  # 将原本的内容 zone "localhost.localdomain" IN 修改为别的域名
	type master;   # master 为主DNS， slave 为从备用DNS， 其他配置基本和主DNS相同
	file "zxqy";  # 正向区域文件配置。将原本的内容  named.loopback 修改 zxqy ,可自定义的名字
								# 如果 type  为 slave， 备份DNS，那么这里写成目录比较好,例如 slaves/Bzxqy
	allow-update { none; };
};


# 将第4个的配置 拷贝到这里，并进行修改。
# 此配置为反向区域，创建正向区域 , IP 的网段。
zone "192.168.141.in-addr.arpa" IN {   # 将原本的内容 "1.0.0.127.in-addr.arpa"  修改为别的IP
	type master;  # master 为主DNS， slave 为从备用DNS， 其他配置基本和主DNS相同
	file "fxqy";  # 反向区域文件配置。将原本的内容  named.localhost 修改 fxqy ,可自定义的名字
								# 如果 type  为 slave， 备份DNS，那么这里写成目录比较好,例如 slaves/Bfxqy
	allow-update { none; };
};
```



### 4、切换目录到正反向区域配置文件中并进行拷贝

```bash
# 正向区域和 反向区域配置的目录。
$ cd /var/named/


# 拷贝 正向区域和 反向区域 的模版，并进行修改 ,名称为上面的配置文件中的名称 file：
# 如果是备份DNS服务器，那么不需要拷贝和配置，只创建在主配中的目录即可， 服务开启后会自动同步的。
$ cp -a /var/named/named.localhost  /var/named/zxqy   # 拷贝 正向区域模版  zxqy
$ cp -a /var/named/named.loopback   /var/named/fxqy   # 拷贝 反向区域模版  fxqy

```



### 5、编辑新增的正向区域文件

```bash
#  正向区域 文件为 zxqy ,  正向区域  为 域名 解析IP
$ vim  cd /var/named/zxqy

# 该文件内容如下， 共新增1处配置，修改1处配置：
$TTL 1D
@	IN SOA	@ linux1.skills.com. (  # 将原本 rname.invalid. 删除，并修改为 主配置文件中设置的。
					0	; serial
					1D	; refresh
					1H	; retry
					1W	; expire
					3H )	; minimum
					NS			@
					A				127.0.0.1
					AAAA		::1
#新增几条主机记录 是主机名和IP地址的对应, 主机名为 linux1 ，A类地址 ，IP地址   。可以添加多条
# 主机名后面的 域名都是按照上面的  linux1.skills.com. 来配置和截取的。
linux1   A				192.168.141.1
linux2   A				192.168.141.2
linux3   A				192.168.141.3
linux4   A				192.168.141.4
```



### 6、编辑新增的反向区域文件

```bash
#  反向区域 文件为 zxqy ,  正向区域  为  IP 解析 域名
$ vim  cd /var/named/fxqy

# 该文件内容如下， 共新增1处配置，修改1处配置：
$TTL 1D
@       IN SOA  @ linux1.skills.com. (  # 将原本 rname.invalid. 删除，并修改为 主配置文件中设置的。
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      @
        A       127.0.0.1
        AAAA    ::1
        PTR     localhost.
#新增几条指针记录 是 IP地址的最后一段主机号的对应, IP地址  ，指针 ，主机名为linux1. 。可以添加多条
1				PTR 		linux1.skills.com.  		#对应的IP 是	192.168.141.1
2				PTR 		linux2.skills.com.      #对应的IP 是	192.168.141.2
3				PTR 		linux3.skills.com.  		#对应的IP 是	192.168.141.3
4				PTR 		linux4.skills.com.  		#对应的IP 是	192.168.141.4
```



### 7、重启DNS服务

```bash
# Debian 、Ubuntu 、 centos 均可使用下面方法
$ systemctl restart  named 

#redhat6 可使用下面的方法
$ /etc/init.d/named restart
```



### 8、重启DNS服务器

```bash
$ reboot
```



### 9、域名解析测试工具

```bash
# 域名解析测试工具 ,该工具在最开始就被安装了。  bind-utils 
$ nslookup
> IP地址或域名即可
```

