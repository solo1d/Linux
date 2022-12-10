## 目录

- [1、挂载安装镜像文件到目录mnt](#1、挂载安装镜像文件到目录mnt)
- [2、编辑yum配置文件](#2、编辑yum配置文件)
  - [编辑第1个文件](#编辑第1个文件)
  - [编辑剩下的文件](#编辑剩下的文件)

- [3、清空yum缓存](#3、清空yum缓存)
- [4、重建yum缓存内容](#4、重建yum缓存内容)
- [5、直接使用yum命令来安装在镜像中的程序包](#5、直接使用yum命令来安装在镜像中的程序包)





### 1、挂载安装镜像文件到目录mnt

```bash
 # 挂载到 mnt 目录下
$ mount -o loop /dev/cdrom /mnt
```



### 2、编辑yum配置文件

#### 编辑第1个文件

```bash
#在 centos 下是 Rocky-Media.repo ,在 redhat 下是 rhel-source.repo ,也可能是其他的以 .repo 为结尾的文件
$ vim   /etc/yum.repos.d/Rocky-Media.repo  

文件内容如下， 共修改6处：
[rhel-source]
name=Red Hat Enterprise Linux $releasever - $basearch - Source

# 修改下面的内容， baseurl 的内容全部注释掉后， 重新编写
##baseurl=ftp://ftp.redhat.com/pub/redhat/linux/enterprise/$releasever/en/os/BaseOS
baseurl=file:///nmt/BaseOS   		# 修改为镜像挂载的目录，/mnt 。  后面的 BaseOS 是原本的内容，不修改。


enabled=1				# 此处修改。 变0 为1 ，开启
gpgcheck=0      # 此处修改， 变1 为0， 关闭检查验证
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

[rhel-source-beta]
name=Red Hat Enterprise Linux $releasever Beta - $basearch - Source

# 修改下面的内容， baseurl 的内容全部注释掉后， 重新编写
# baseurl=ftp://ftp.redhat.com/pub/redhat/linux/beta/$releasever/en/os/AppStream
baseurl=file:///nmt/AppStream   		# 修改为镜像挂载的目录，/mnt 。  后面的 AppStream 是原本的内容，不修改。

enabled=1				# 此处修改。 变0 为1 ，开启
gpgcheck=0      # 此处修改， 变1 为0， 关闭检查验证

gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-beta,file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
```

#### 编辑剩下的文件

```bash
# 编辑第二个和第三个文件，分被为：Rocky-AppStream.repo 、Rocky-BaseOS.repo 、Rocky-Extras.repo  
$ vim   Rocky-AppStream.repo  Rocky-BaseOS.repo  Rocky-Extras.repo  

将这三个文件中的 enable 选项全部变成0 即可。
enabled=0				# 此处修改。 变1 为0 ，关闭
```



### 3、清空yum缓存

```bash
# 清空yum缓存命令
$ yum clean all
```



### 4、重建yum缓存内容

```bash
# 重建yum内容命令
$ yum makecache
```



### 5、直接使用yum命令来安装在镜像中的程序包

```bash
$ yum install bind bind-utils
```

