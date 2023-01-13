# apache2 网页文件服务器

## 安装网页文件服务器

```bash
sudo apt-get update

sudo apt-get install apache2
```

## 检查配置文件是否修改正确的命令

```bash
$sudo apache2ctl configtest
    可以通过这条命令来得知,配置文件 apache2.conf 是否被正确的修改了,以及是否出现错误.
```

## apache2.conf 配置文件

```bash
sudo vim /etc/apache2/apache2.conf

#在这个文件末尾添加下面的配置代码, 可以添加多个端口,每个端口对应一个目录.
#但要是 ports.conf 在这个文件内添加打开的端口

#需要分享的目录
<Directory /home/pi>                        
        Options Indexes FollowSymLinks
        AllowOverride None
        
        #权限
        Require all granted 
</Directory>

# 后面参数是端口号, 可以任意修改,每个端口可以对应一个文件目录
<VirtualHost *:80>              

# 文档根,相当于分享的目录
	DocumentRoot "/home/pi"  
</VirtualHost>


# 后面参数是端口号, 可以任意修改,每个端口可以对应一个文件目录
<VirtualHost *:9999>              

# 文档根,相当于分享的目录
	DocumentRoot "/home/pi/note"  
</VirtualHost>
```

## ports.conf  端口配置文件

```bash
sudo vim /etc/apache2/ports.conf


Listen 80                #这个是默认存在的
Listen 9999              #这个是后添加的,表示开启9999端口的访问,监听

<IfModule /home/pi/note>      #上面设置过的目录位置
        Listen 9999      #可以访问的端口
</IfModule>

<IfModule /home/pi>     #和上面一样
        Listen 80       #可以设置多个端口访问
</IfModule>
                        #下面的都是默认存在的.
<IfModule ssl_module>
        Listen 443
</IfModule>

<IfModule mod_gnutls.c>
        Listen 443
</IfModule>
```

## 重启服务

```bash
$sudo apache2ctl configtest
    可以通过这条命令来得知,配置文件 apache2.conf 是否被正确的修改了,以及是否出现错误.

$sudo systemctl restart apache2
```









