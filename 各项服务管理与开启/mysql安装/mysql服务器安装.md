>平台:  4B . Debian 12 (bookworm)
>
>raspberrypi 6.1.0-rpi4-rpi-v8 #1 SMP PREEMPT Debian 1:6.1.54-1+rpt2 (2023-10-05) aarch64 GNU/Linux



### 解压安装包

下载地址： https://dev.mysql.com/downloads/file/?id=523387

下载链接：https://dev.mysql.com/get/Downloads/MySQL-8.2/mysql-8.2.0-linux-glibc2.28-aarch64.tar.xz

下载文件为：`mysql-8.2.0-linux-glibc2.28-aarch64.tar.xz`

```bash
#创建目录
$ mkdir ~/mysql ; cd ~/mysql

# 下载
$  wget "https://dev.mysql.com/get/Downloads/MySQL-8.2/mysql-8.2.0-linux-glibc2.28-aarch64.tar.xz"

$ tar -xvf mysql-8.2.0-linux-glibc2.28-aarch64.tar.xz
```



## 拷贝到安装位置

```bash
$ cd ~/mysql 

$ sudo mv mysql-8.2.0-linux-glibc2.28-aarch64 /usr/local/mysql

$ sudo cp -a /usr/local/mysql/support-files/mysqld_multi.server /etc/init.d/mysqld_multi
$ sudo cp -a /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql

$ sudo mkdir /usr/local/mysql/data
```



### 配置环境变量

```bash
#切换到root
$ su - root 

# root模式下命令  , 如果不成功，可以手动添加
$ echo "export PATH=$PATH:/usr/local/mysql/bin" >> /etc/profile
```



## 重新登录终端



## 安装mysql8

```bash
$ sudo apt update 

$ sudo apt install libaio-dev  libncurses6

# 初始化数据库
$ cd /usr/local/mysql/bin 
$ sudo ./mysqld --user=mysql  --basedir=/usr/local/mysql \
	--datadir=/usr/local/mysql/data --initialize
		#后续输出的内容会有个密码，需要记录   
			#password is generated for root@localhost: gtI.xj#wE9MP   最后这个就是密码

$ sudo systemctl daemon-reload 
$ sudo systemctl start mysql.service 



# 修改密码
$ mysql -u root -p 
# 取出临时密码进行登录  gtI.xj#wE9MP
# 修改密码
mysql> ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '12345678';
# 刷新下权限
mysql> FLUSH PRIVILEGES;
# 开启远程访问
mysql> update user set host='%' where user='root';
mysql> commit;
mysql> FLUSH PRIVILEGES;
```

