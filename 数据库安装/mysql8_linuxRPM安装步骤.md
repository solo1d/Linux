1. 登陆root账号
2. 先解压 `mysql-8.0.32-1.el9.aarch64.rpm-bundle.tar` 文件
3. 将解压出来的文件依次进行安装 `rpm -Uvh xxx.rpm`
   1. 如果报错误和依赖，那么就继续向下安装，都安装完成后再回过来继续安装失败的包即可。
   2. 安装顺序：common、libs、libs-compat、client、server、test（可选装，测试数据库使用）、devel（可选装，嵌入式数据库函数）、embedded-compat（可选装，兼容式数据库函数）
4. 执行以下命令：

```bash
# 1、执行安装的命令，并设置默认root密码为空，如下：
$ mysqld --initialize-insecure
			# 初始化完成后，在mysql根目录中会自动生成data文件夹。

#2、创建目录并给予权限
cd /usr/local/  ; mkdir mysql ; chown mysql:mysql /var/lib/mysql -R;
```

5. 启动 mysql

   1. `systemctl start mysqld.service;`
   2. `systemctl enable mysqld;`

6. 查看数据库的 root 登录密码命令

   1. `cat /var/log/mysqld.log | grep password`
   2. ![img](assets/2019092913594879.png)
   3. 如果提示以下内容，则表示可以直接登陆（直接执行 `mysql` 命令即可登录），无需密码：
      1. `2023-03-15T06:58:54.174828Z 6 [Warning] [MY-010453] [Server] root@localhost is created with an empty **password** ! Please consider switching off the --initialize-insecure option.`

7. 修改密码 

   1. ```mysql
      ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '自己想要设置的密码';
      ```

8. 远程访问授权

   1. ```mysql
      create user 'root'@'%' identified with mysql_native_password by '登录密码';
      
      grant all privileges on *.* to 'root'@'%' with grant option;
      
      flush privileges;
      ```

9. 修改防火墙

   1. `systemctl stop firewalld.service;`
   2. `systemctl disable firewalld.service;`
   3. `systemctl mask firewalld.service;`