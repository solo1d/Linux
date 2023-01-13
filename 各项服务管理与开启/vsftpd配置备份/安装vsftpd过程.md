#### 安装 vsftpd

```bash
sudo apt-get install vsftpd db-util
```





修改配置文件

```bash
sudo vim /etc/vsftpd.conf



#内容如下
# Uncomment this to enable any form of FTP write command.
write_enable=YES
local_umask=022
# go into a certain directory.
dirmessage_enable=YES
#
# If enabled, vsftpd will display directory listings with the time
# in  your  local  time  zone.  The default is to display GMT. The
# times returned by the MDTM FTP command are also affected by this
# option.
use_localtime=YES
#
# Activate logging of uploads/downloads.
xferlog_enable=YES
#
# Make sure PORT transfer connections originate from port 20 (ftp-data).
connect_from_port_20=YES

#添加如下选项
allow_writeable_chroot=YES




#更具体的内容可以看一下网址介绍
#https://shumeipai.nxez.com/2021/02/04/tutorial-for-installing-vsftpd-on-raspberry-pi.html
```



重启服务

```bash
sudo systemctl restart vsftpd
sudo service vsftpd restart
```



