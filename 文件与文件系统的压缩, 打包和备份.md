# 文件与文件系统的压缩, 打包和备份

## 文件压缩和解压缩

* .Z
  * compress  程序压缩文件, 可以使用 **`gzip`** 命令进行解压缩.
* **.zip**
  * zip  程序压缩文件, 使用 **`gzip`** 命令进行压缩和解压缩.
* **.gz**
  * gzip  程序压缩文件,   使用 **`gzip`** 命令进行压缩和解压缩.
* **.bz2**
  * bzip2  程序压缩文件, 使用 **`bzip2`** 命令进行压缩和解压缩.
* **.xz**
  * xz 程序压缩的文件,  使用 **`xz`** 命令 来进行压缩和解压缩.
* **.tar**
  * **tar  程序打包的`数据`, `并没有压缩过`.**
* **.tar.gz**
  * tar 程序打包的文件, 其中并且经过  **gzip** 的压缩.
* **.tar.bz2**
  * tar  程序打包的文件, 其中并且经过  **bzip2**  的压缩.
* **.tar.xz**
  * tar 程序打包的文件,  其中并且经过 **xz** 的压缩.

### gzip   , zcat/ zmore/ zless/ zgrep

**gzip是目前应用度最广的压缩指令, 可以解开** **`compress(.Z)  zip(.zip) 与 gzip(.gz)` 等软件所压缩过的文件**

 **`zcat/ zmore/ zless/ zgrep`  这些指令是在对压缩文件不进行解压的情况下,来查看压缩包内文本文件的内容的.**

```bash
$gzip  选项  文件名
选项和参数:
-c    :将压缩的数据输出到屏幕上,可用于重定向写入文件.(就是压缩包的内容)
-d    :进行解压缩 
-t    :可以用来检验一个压缩文件的一致性 ~可以看看文件有无错误;
-v    :可以显示出源文件/压缩文件的压缩等信息;
-数字  :代表压缩等级.  1 表示最快 但压缩比最差, 9最慢 但压缩比最好, 默认值是6

$zcat 压缩包名.gz    # 该命令可以将.gz 压缩包的文本文件内容读取出来.(只可以是单个文件的)

范例1: 找出 /etc 下面 (不含子目录) 容量最大的文件，并将它复制到 /tmp ，然后以 gzip 压缩
$ls -ldSr /etc/*            #会输出/etc/ 下面所有子目录当中文件大小最大的文件,按照从小到大排序
    #比如找到的最大占用文件就是  /etc/services
$cd /tmp
$cp /etc/services   /tmp     #将文件拷贝过去
$gzip  -v  services          #进行压缩, 会得到 services.gz 文件,并且service原文件会消失


范例2:由于上个范例压缩的是文本文件,所以可以使用 zcat 命令来将其内容读取出来.
$zcat    services.gz        #直接可以将这个文件的内容读取出来


范例3:将 services.gz 文件解压缩.
$gzip  -d    services.gz      #该指令会将services.gz 解压缩,但是 services.gz 文件会消失.


范例4: 在services.gz 中找到 http 这个关键字在第几行.
$zgrep -n 'http'  services.gz        #并不会进行解压缩,只是在 services 中寻找 http


范例5: 保留 services 文件,并创建一个 services.gz 文件,才用-9等级压缩, 使用重定向.
$gzip -c -9 services > services.gz        #后面是压缩文件,前面是将压缩后的数据打印到屏幕上

```

### bzip2  , bzcat/bzmore/bzless/bzgrep

**bzip2 则是为了取代 gzip 并提供更佳的压缩比而来的.**

```bash
$bzip2   选项  文件名
选项和参数:
-c    :将压缩的过程产生的数据输出到屏幕上.
-d    :解压缩
-k    :保留原始文件,无论压缩还是解压缩
-z    :压缩    (默认值,可以不加)
-v    :可以显示出 原文件/压缩文件 的压缩比等信息.
-数字  :与 gzip 相同,都是在计算压缩比的参数,  -9 最佳, -1最快, 默认-6

$bzcat    压缩文件.bz2      #和 zcat 命令 相同.

范例: 保留文件 进行 -9 最高等级压缩.
$bzip2 -k -9 services             #会得到一个services.bz2 的压缩包文件
```

### **xz , xzcat/xzmore/xzless/xzgrep**

**压缩比更高,用法也和 gzip/bzip2 一样.**

```bash
$xz  选项  文件名
选项和参数:
-d    :解压缩
-t    :测试解压文件的完整性, 看有没有错误.
-l    :列出压缩文件的相关信息
-k    :保留原文件, 无论压缩和解压缩
-c    :将压缩包 数据输出到屏幕上,主要用来重定向.
-v    :可以显示出 原文件/压缩文件 的压缩比等信息.
-数字  :压缩比, -9最佳, -1最快, 默认-6

$xcat  压缩包.xz        #也是在不解压的情况下查看压缩包内文本文件的内容.

范例: 压缩文件 service ,变成压缩包 service.xz, 并答应出压缩比信息.
$xz -v services
输出: services (1/1)
        100 %        97.3 KiB / 654.6 KiB = 0.149    

范例2: 保留原文件 service 并进行压缩.
$xz -k services        #原文件会被保留,并且会出现一个 services.xz 压缩包文件
```

## 打包指令  : tar

**tar** 是将多个文件或目录包成一个大文件的指令指令. 而且还可以通过 **`gzip/bzip2/xz`** 的支持.

**`tarfile`**  是进行打包之后 生成的文件,并没有进行压缩. \(**$tar -cv -f file.tar  data**\)

**`tarball`**  是进行打包并且进行压缩之后的文件. \(**$tar -zcv -f file.tar.gz data** \)

```bash
$tar  [-z | -j | -J ] [cv] [-f 待创建的新文件名] filename     #打包
$tar  [-z | -j | -J ] [tv] [-f 既有的 tar 文件名]            #查看
$tar  [-z | -j | -J ] [xv] [-f 既有的 tar 文件名] [-C 目录]   #解压
选项与参数:
-c   :创建打包文件，可搭配 -v 来察看过程中被打包的文件名(filename)
-t   :察看打包文件的内容含有哪些文件名，重点在察看“文件名”就是了;
-x   :解打包或解压缩的功能，可以搭配 -C (大写) 在特定目录解开特别留意的是,
      -c, -t, -x 不可同时出现在一串命令行中。
-z   :通过 gzip 的支持进行  压缩/解压缩 :此时文件名最好为 *.tar.gz
-j   :通过 bzip2 的支持进行  压缩/解压缩 :此时文件名最好为 *.tar.bz2
-J   :通过 xz 的支持进行  压缩/解压缩 :此时文件名最好为 *.tar.xz 特别留意， 
      -z, -j, -J 不可以同时出现在一串命令行中
      如果不加 -z -j -J 的话,那么后戳名给 .tar
-v   :在 压缩/解压缩 的过程中，将正在处理的文件名显示出来!
-f filename  :-f 后面要立刻接要被处理的文件名!建议 -f 单独写一个选项啰!(比较不会忘记)
-C 目录      :这个选项用在解压缩，若要在特定目录解压缩，可以使用这个选项。

-p   :保留备份数据的原本权限与属性, 常用与备份(-c) 重要的配置文件
-P   :保留绝对路径,亦即允许备份数据中含有根目录存在之意.( 这个选项尽量不要用,非常危险)
--exclude=FILE   :在压缩过程中,不要将FILE打包.

实用的三种命令格式:
$tar -jcv -f  新文件名.tar.bz2  要被压缩的文件或目录     #压缩
$tar -Jtv -f  文件名.tar.xz                          #查询
$tar -zxv -f  文件名.tar.gz   -C 放置解压缩的目录       #解压缩
```

### 压缩

{% hint style="info" %}
```bash
备份 /etc 下的配置文件.并且保留原本文件的权限与属性(-p 选项).
$su      #root权限
$time tar -zpcv -f /root/etc.tar.gz  /etc      
    #备份文件是 etc.tar.gz ,time计算消耗时间
```
{% endhint %}

### 解压缩

{% hint style="info" %}
```bash
解压缩 etc.tar.gz 的所有文件,并放入指定的目录 /tmp/etc 内
$tar -zxv -f etc.tar.gz  -C  /tmp/etc
```
{% endhint %}

### **查阅压缩包的内容**

{% hint style="info" %}
```bash
查阅压缩包是否含有名为 'shadow' 的文件.
$tar -ztv -f file.tar.gz  | grep 'shadow'
```
{% endhint %}

### **仅解开单一文件**

{% hint style="info" %}
```bash
查阅压缩包的内容, 并找到 'shadow' 这个文件, 并且把它单一的解压出来
$tar -ztv -f etc.tar.gz  | grep 'shadow'      #压缩包内确实有这个文件
  输出: ---------- root/root      1299 2019-10-10 09:11 etc/shadow   #这个就是要找的
$tar -zxv -f etc.tar.gz   etc/shadow           
   #找到了,并且把它单独解压了出来在当前目录,如果给 -C 参数 则可以指定目录了.
```
{% endhint %}

### **打包某个目录,但不包含该目录下的某些文件**

{% hint style="info" %}
```bash
打包 /etc 目录和 /root 目录,并且把打包后的文件放在 /root 下,并且不包含 /root/etc 目录
$tar -jcv -f /root/system.tar.bz2 --exclude=/root/etc* -exclude=/root/system.tar.bz2 /etc /root
 #详解: --exclude 后面是不进行打包的目录和文件.后面的/etc 和/root 是会进行打包的文件
 # 包会在/root下,所以要避免死循环打包,要把 system.tar.bz2 排除在外.
```
{% endhint %}

### **仅备份比某个时刻还要新的文件**

{% hint style="info" %}
```bash
仅备份比某个时刻还要新的文件,备份目录/etc* ,时间2015/01/01(mtime),包名/root/etc.tar.bz2
$tar -jcv -f /root/etc.tar.bz2 --newer-mtime='2015/01/01' /etc*
```
{% endhint %}

### **打包备份到设备\(磁带\)**

{% hint style="info" %}
```bash
将 /etc 内容打包备份磁带(/dev/st0),不需要进行压缩. (企业级备份命令)
$tar -cv -f /dev/st0  /etc*
```
{% endhint %}

### **备份系统配置文件并使用嵌入命令**

{% hint style="info" %}
```bash
tar -zcv -f $(date +%Y%m%d).tar.gz --exclude=/root/*.gz --exclude=/root/*.bz2\
/etc /home /var/spool/mail /var/spool/cron /root

# 会输出当前时间名的文件,   20191021.tar.gz
# $(date +%Y%m%d)  会返回当前的时间 并当作文件名.
#要备份的目录有: /etc , /home , /root ,
#                /var/spool/mail,  (系统中,所有账号的邮件信箱)
#                /var/spool/cron,  (所有账号的工作排成配置文件)
#  并排除/root/ 下的两种压缩文件
```
{% endhint %}

### 解压后 SELinux 课题

{% hint style="info" %}
**当使用备份的 /etc 配置文件进行系统恢复的时候,要注意两个地方:** 

* 当将 /etc 配置文件覆盖后, **不要重启** ,随后就输出命令  $**`restorecon -Rv /etc`**  自动修复一下 SELinux 的类型.
* **如果当覆盖并重启之后**, 使用各种方法登录系统, 然后在**根目录下**创建 **`.autorelabel`** 文件, 再次重启,就可以进入系统了

**`出现问题的原因:  /etc/shadwo 这个文件的 SELinux 类型在还原时被更改了`**
{% endhint %}

## XFS 文件系统的备份与还原

* 备份时需要使用命令  **`xfsdump`** 
  * **采用 git 类型的累计备份**
    * **在进行累计备份前,必须有一份完整备份\(等级0\)**
  * 每次备份都是按照 **level0** 开始的,依次递增
  * **level 的记录档放置于 `/var/lib/xfsdump/inventory`** 中
* **使用 `xfsdump` 时需要注意的限制**
  * **`xfsdump` 不支持没有挂载的文件系统备份!所以只能备份已挂载的!**
  * **`xfsdump` 必须使用 root 的权限才能操作 \(涉及文件系统的关系\)**
  * **`xfsdump` 只能备份 XFS 文件系统**
  * **`xfsdump` 备份下来的数据 \(文件或储存媒体\) 只能让 `xfsrestore` 解析**
  * **`xfsdump` 是通过文件系统的 UUID 来分辨各个备份文件的，因此不能备份两个具有相同 UUID 的文件系统**

**特别注意， xfsdump 默认仅支持文件系统的备份，并不支持特定目录的备份~所以你不能用 xfsdump 去备份 /etc ! 因为 /etc 从来就不是一个独立的文件系统**

### **XFS 文件系统备份**

```bash
$xfsdump [-L S_label] [-M M_label] [-l #] [-f 备份文件] 待备份数据
$xfsdump  -I
选项和参数
-L   :xfsdump 会纪录每次备份的 session(对话) 标头，这里可以填写针对此文件系统的简易说明
-M   :xfsdump 可以纪录储存媒体的标头，这里可以填写此媒体的简易说明
-l   :是 L 的小写，就是指定等级~有 0~9 共 10 个等级喔! (默认为 0，即完整备份)
-f   :有点类似 tar 啦!后面接产生的文件，亦可接例如 /dev/st0 设备文件名或其他一般文件文件名等
-I   :从 /var/lib/xfsdump/inventory 列出目前备份的信息状态
如果不加 -L 和 -M 参数, 则会进入互动模式, 要求你输出 对话标头(-L)
```

#### **用 xfsdump  备份完整的文件系统\(等级0\)**

{% hint style="info" %}
```bash
假设/boot 是 独立的文件系统, 并且进行备份
$df -h /boot      #首先要进行查询,确定是独立的文件系统
输出: 文件系统        容量    已用  可用   已用%   挂载点
     /dev/sda2      1014M  155M  860M   16%   /boot
$xfsdump  -l 0 -L boot_all -M boot_all -f /srv/boot.dump  /boot
     #-l 0 等级0, 进行完整备份 ,  -L 对话标头(必须加), -M 存储媒体的标头(必须加)
     #-f 指定备份的文件名,  /boot 是被 备份的目录.
输出:
xfsdump: level 0 dump of study.centos.vbird:/boot      #开始备份本机/boot系统
xfsdump: dump date:Tue Oct 22 08:53:25 2019            #备份的时间
xfsdump: session id: 16e5803f-15fb-41e2-85e8-87eaa0b2d01d     #这次dump的ID
xfsdump: session label: "boot_all"             #简单给予一个名字记忆, -L指定的
xfsdump: ino map phase 1: constructing initial dump list      #开始备份程序

$ll -h /var/lib/xfsdump/inventory    #查看是否有记录档生成 (应该是三个文件)
```
{% endhint %}

#### 用 xfsdump  进行累计备份

{% hint style="info" %}
```bash
累计备份前,必须有一份完整备份 (等级0)
首先查看一下有没有任何文件系统被 xfsdump 过的数据.
$xfsdump -I   #假设有输出,并且有完整的备份

$xfsdump -l 1 -L boot_2 -M boot_2_m -f /srv/boot.dump  /boot 
        #-f 的名字要和原有备份名相同.
```
{% endhint %}

### XFS 文件系统还原 xfsrestore

```bash
$xfsrestore   -I     #查看备份文件数据
$xfsrestore  [-f 备份文件] [-L S_label] [-S] 待复原的目录    #单一文件全系统复原
$xfsrestore  [-f 备份文件] -r 待复原目录       #通过累计备份文件来复原系统
$xfsrestore  [-f 备份文件] -i 待复原目录        #进入互动模式
选项与参数:
-I :跟 xfsdump 相同的输出!可查询备份数据，包括 Label 名称与备份时间等.(去/var/lib/xfsdump/inventory 里面取数据)
-f :后面接的就是备份文件!企业界很有可能会接 /dev/st0 等磁带机!我们这里接文件名!
-L :就是 Session 的 Label name 喔!可用 -I 查询到的数据，在这个选项后输入!
-s :需要接某特定目录，亦即仅复原某一个文件或目录之意!
-r :如果是用文件来储存备份数据,那这个就不需要使用.如果是一个磁带内有多个文件,需要这东西来达成累积复原
-i :进入互动模式，进阶管理员使用的!一般我们不太需要操作它!

```

#### 用 xfsrestore 观察 xfsdump 后的数据内容

{% hint style="info" %}
```bash
$xfsrestore   -I     #查看备份文件数据
输出:  ( 只节选很重要的内容)
file system 0:
	fs id:		670c24ae-e100-4457-9799-f82b0e84cb5c
	session 0:
		mount point:	study.centos.vbird:/boot
		device:		study.centos.vbird:/dev/sda2
		time:		Tue Oct 22 08:53:25 2019
		session label:	"boot_all"
		session id:	16e5803f-15fb-41e2-85e8-87eaa0b2d01d
		level:		0
			pathname:	/srv/boot.dump
				mfile size:	127733624
				media label:	"boot_all_M"
	session 1:
		mount point:	study.centos.vbird:/boot
		device:		study.centos.vbird:/dev/sda2
		time:		Tue Oct 22 09:07:27 2019
		session label:	"boot_2"
		session id:	329e0dde-c9ee-4eb2-84b1-c59b891dd355
		level:		1
		stream 0:
			pathname:	/srv/boot.dump
xfsrestore: Restore Status: SUCCESS
# 文件系统就是 /boot 挂载点, 然后有两个备份, 一个level0 一个 level1
#也看到这两个备份的数据它的内容大小,个重要的是 session label 
```
{% endhint %}

#### 简单复原 level 0 的文件系统

{% hint style="info" %}
需要知道被复原的那个文件\(**`/srv/boot.dump`**\), 以及该文件的 **`session label name`** 就可以复原了.

```bash
# 直接将数据给他覆盖回去即可.
$xfsrestore  -f /srv/boot.dump  -L boot_all /boot
       #-f 是备份文件名, -L 是session label 名.  最后/boot 是还原的挂载点
       # 这样复原是将同名文件覆盖, 但是保留 /boot 内的新文件(非同名文件)

#也可以将备份文件的数据在 指定目录下展开
$mkdir /tmp/boot ; xfsrestore -f /srv/boot.dump -L boot_all  /tmp/boot

#对比两个目录下的文件差异
$diff -r /boot /tmp/boot
```
{% endhint %}

#### 只复原某一个目录或文件

{% hint style="info" %}
```bash
$xfsrestore -f /srv/boot.dump -L boot_all -s grub2 /tmp/boot2
    #-s 参数是关键,它指定了一个在备份中的目录或文件
    # 将在备份中的 grub2 复原到 /tmp/boot2 目录下
```
{% endhint %}

#### 复原累计备份数据

{% hint style="info" %}
```bash
$xfsrestore -f /srv/boot.dump /tmp/boot 
#还可以指定 -L 名称来直接进行 level 等级的跳转恢复
$xfsrestore -f /srv/boot.dump -L boot_2   /tmp/boot
```
{% endhint %}

#### 仅还原部分文件的 xfsrestore 互动模式

{% hint style="info" %}
```bash
#先进入备份文件内, 找出需要备份的文件名数据,同时预计还原到 /tmp/boot3 中.
$mkdir /tmp/boot3
$xfsrestore -f /srv/boot.dump -i /tmp/boot3    #-i 进入互动模式.
输出:
 the following commands are available:
 pwd
 ls [ <path> ]      #查看备份文件当前目录下的内容
 cd [ <path> ]      #进入到备份文件的某个目录内
 add [ <path> ]     # 可以加入复原文件列表中
 delete [ <path> ]  # 从复原列表拿掉文件名!并非删除
 extract            # 开始复原动作
 quit
 help
-> ls        #这里要求我进行输出
             105 initramfs-3.10.0-1062.el7.x86_64.img 
             107 vmlinuz-0-rescue-133ece7b9bde7d4e973a95e37eed6af5 
             106 initramfs-0-rescue-133ece7b9bde7d4e973a95e37eed6af5.img 
             104 vmlinuz-3.10.0-1062.el7.x86_64 
             103 symvers-3.10.0-1062.el7.x86_64.gz 
             102 config-3.10.0-1062.el7.x86_64 
             101 System.map-3.10.0-1062.el7.x86_64 
             100 .vmlinuz-3.10.0-1062.el7.x86_64.hmac 
         1069152 grub/
          524384 grub2/
              99 efi/
->add grub
->add grub2
->add config-3.10.0-1062.el7.x86_64       #上面这三个都是要被复原的文件或目录
->extract                   #开始复原,并且只复原 add 添加的
 --------------------------------- end dialog ---------------------------------

xfsrestore: restoring non-directory files
xfsrestore: restore complete: 370 seconds elapsed
xfsrestore: Restore Summary:
xfsrestore:   stream 0 /srv/boot.dump OK (success)
xfsrestore: Restore Status: SUCCESS
#复原完成

$ls /tmp/boot3   
输出: config-3.10.0-1062.el7.x86_64    grub    grub2
```
{% endhint %}

## 光盘写入工具

* 先将所需要备份的数据创建成为一个镜像文件\(iso\), 利用 **`mkisofs`**  指令来处理.
* 将镜像文件 烧录至光盘或 DVD中, 利用 **`cdrecord`** 指令来处理.

### mkisofs   创建镜像文件

**烧录可开机与不可开机的光盘, 使用的方法不太一样**

#### **制作一般 数据光盘 镜像文件**

**`光盘的格式一般为 iso9660`**

从 FTP 站捉下来的 Linux 镜像文件 \(不管是 CD 还是 DVD\) 都得要继续烧录成为实体 的光盘/DVD 后， 才能够进一步的使用，包括安装或更新你的 Linux.

* **利用烧录机将你的数据烧录到 DVD 时**
  * **先将数据打包成一个镜像文件, 这样才能够写入 DVD 片中.**
    * **通过 `mkisofs` 这个指令即可**

```bash
$mkisofs  [-o 镜像文件] [-Jrv] [-V vol] [-m file] 待备份文件 -graft-point 镜像文件中的目录所在=实际Linux文件系统的目录所在
选项和参数:
-o  :后面接想要产生的那个镜像文件的文件名
-J  :产生较相容于 windows 机器的文件名结构, 可增加文件名长度到64个 unicode 字符.
-r  :通过 rock ridge 产生支持 Unix/Linux 的文件结构,可记录较多的信息 (如 UID/GID 等)
-v  :显示创建的 ISO 文件的过程.
-V vol  :创建 Volume ,像 windows 在文件资源管理器内看到的 cd title 的东西
-m file :-m为排除文件(exclude)的意思, 后面的文件不备份到镜像文件中, 可以使用 * 万用字符.
-graft-point  :graft 有转嫁或移植的意思, 用来重定位镜像文件中的目录所在和实际Linux文件系统的目录所在.
                -graft-point  /movies/=/srv/movies/ #在 Linux 的 /srv/movies 内的文件，加至镜像文件中的 /movies/ 目录
                -graft-point  /linux/etc=etc   #将 Linux 中的 /etc/ 内的所有数据备份到镜像文件中的 /linux/etc/ 目录中
```

#### 简单的 数据光盘 镜像文件

{% hint style="info" %}
```bash
# 先不使用 -graft-point 选项
#备份 /root  /home  /etc  目录下的文件 制作成镜像文件,镜像文件名是 /tmp/system.img
$mkisofs  -r -v -o /tmp/system.img  /root /home /etc    #后面三个是被打包目录
    #有时备份会失败, 那是因为有同名文件, 只要将这个同名文件删除就可以了
genisoimage: Error: '/etc/fstab' and '/root/fstab' have the same Rock Ridge name 'fstab'.
    #这个输出提示就表示你应该删除 fstab 其中一个
    @这样的备份会造成非常的混乱, 应该三个目录下的所有文件都放在了一起.


#使用 -graft-point 选项
$mkisofs -r -V 'linux_file' -o /tmp/system.img -graft-point /root=/root /home=/home /etc=/etc
    #这样 在镜像文件的目录下就会出现 homt etc root 三个目录,非常整洁.
    
上面两个镜像文件都可以通过  $mount -o loop system.img /mnt   进行挂载.
```
{% endhint %}

#### 制作/修改  可开机光盘  图像档

{% hint style="info" %}
```bash
#假设要修改 CentOS-7-x86_64-Minimal-1908.iso 这个Linux安装镜像,并可开机.
# 首先查看下光盘里面的内容,是否是我们需要的光盘系统
$isoinfo -d -i CentOS-7-x86_64-Minimal-1908.iso    
$mount /home/CentOS-7-x86_64-Minimal-1908.iso  /mnt    #进行挂载
$mkdir  /srv/newcd               #修改之后保存新镜像的地方
$rsync -a /mnt/  /srv/newcd      #复制命令,会复制所有的权限属性等数据,能够进行镜像处理.
$ls -lha   /srv/newcd/           #复制完成,查看下该目录的内容.

# 现在就可以进行 /srv/newcd 中的内容修改了,这里假设已经修改完成,准备再次做成镜像.
$cd /srv/newcd 
$mkisofs -o /home/newCD.iso -b /srv/newcd/isolinux/isolinux.bin \ 
    -c /srv/newcd/isolinux/boot.cat  -no-emul-boot -V 'CentOS 7 x86_64' \
    -boot-load-size 4 -boot-info-table -R -J -v -T  /srv/newcd/
    #上面三行是一条命令
    #解释: -o 生成的镜像名, -b 引导镜像文件(在/srv/newcd/isolinux/isolinx.bin)
    # -c 引导目录(/srv/newcd/isolinux/boot.cat)
    # -V 后面是卷标名(Volume id)
```
{% endhint %}

### cdrecord  光盘烧录工具

**Centos7 使用的是 wodim 进行烧录, 也可以链接到 cdrecord .**

```bash
$wodim  --devices dev=/dev/sr0        #查询烧录机的 BUS 位置
$wodim -v dev=/dev/sr0 blank=[fast | all]    #抹除重复读写片
$wodim -v dev=/dev/sr0 -format       #格式化DVD+RW
$wodim -v dev=/dev/sr0 [可用选项功能] file.iso
选项和参数:
--devices   :在扫描磁盘总线并展出可用的烧录机,后续的设备为 ATA 接口.
-v          :在 cdrecord 运行的过程中,显示过程而已.
dev=/dev/sr0  :可以找出此光驱的 bus 位置,非常重要
blank=[fast | all]   :blank为抹除可重复写入的CD/DVD-RW,使用fast较块, all较完整.
-format    :对光盘片进行格式化,但是仅针对 DVD+RW 这种格式的 DVD 而已.

[可用选项功能]  主要是写入 CD/DVD 时可使用的选项, 常见的选项包括有:
        -data    :指定后面的文件以数据格式写入,不是以 CD 音轨 (-audio) 方式写入.
        speed=X  :指烧录速度, 例如CD 可用 speed=40 为40倍,DVD则可用 speed=4 之类.
        -eject   :指定烧录完毕后自动退出光盘
        fs=Ym    :指定多少缓存内存,可用在将镜像文件先暂存至缓冲内存,默认为 fs=4m.
                        一般建议可增加到8m, 不过,还是得视烧录机的情况而定.
针对 DVD 的选项功能:
        driveropts=burnfree   :打开Buffer Underrun Free 模式的写入功能
        -sao                  :支持 DVD-RW 的格式
```

#### 侦测烧录机所在的位置

{% hint style="info" %}
早期的烧录机都是使用 SCSI 接口的.所以查询就要配合着 SCSI 接口的认定来处理了.

```bash
$ll  -h /dev/sr0
brw-rw----+ 1 root cdrom 11, 0 10月 22 08:07 /dev/sr0

$wodim --deviices dev=/dev/sr0
输出:
wodim: Overview of accessible drives (1 found) :
-------------------------------------------------------------------------
 0  dev='/dev/sr0'	rwrw-- : '' 'Virtual DVD-ROM'
-------------------------------------------------------------------------
# 因为是虚拟机,所以无法塞入真正的光盘
```
{% endhint %}

#### 进行 CD/DVD 的烧录动作

{% hint style="info" %}
在烧录之前要抹除 DVD 片 里面的数据.

```bash
#先抹除光盘的原始内容
$wodim -v dev=/dev/sr0 blank=fast    
    #中间会跑出一段讯息提示抹除进度,并有10秒的时间等待你的取消.

#开始烧录
$wodim -v dev=/dev/sr0  speed=4 -dummy -eject /tmp/system.img
    #system.img 是通过 $mkisofs  -r -v -o /tmp/system.img  /root /home /etc 得到的

#烧录完成,测试挂载一下,检验内容
$mount /dev/sr0 /mnt
$df -h /mnt
输出:
 Filesystem            Size  Used Avail Use% Mounted on
 Filesystem      Size  Used Avail Use% Mounted on
 /dev/sr0         87M   87M     0 100% /mnt

$ll /mnt
输出:
 dr-xr-xr-x. 135 root root 36864 Jun 30 04:00 etc
 dr-xr-xr-x. 19 root root 8192 Jul 2 13:16 root
 
$umount /mnt     #不要忘记卸载
```
{% endhint %}

## 其他常见的压缩与备份工具

### dd

```bash
$dd if="input_file" of="output_file" bs="block_size" count="number"
选项与参数:
 if   :就是 input file 啰~也可以是设备喔!
 of   :就是 output file 喔~也可以是设备;
 bs   :规划的一个 block 的大小，若未指定则默认是 512 Bytes(一个 sector 的大小)
 count:  多少个 bs 的意思。

范例1: 将光驱的内容抓取下来,变成图像档
$dd if=/dev/sr0 of=/tmp/system.iso

范例2: 将 system.iso 烧录到 sub磁盘中(/dev/sdb)
#首先确认 USB 是否存在,以及是否有设备文件, 以及容量是否够用
$lsblk  /dev/sdb
$dd if=/tmp/system.iso of=/dev/sdb  #这样烧录可以变成可开机光盘一样的功能

范例3: 将 /boot 这个文件系统 备份下来
$df -h /boot           #得到设备名
文件系统        容量  已用  可用 已用% 挂载点
/dev/sda2      1014M  165M  850M   17% /boot

$dd if=/dev/sda2  of=/tmp/sda2.img


范例4 :将/dev/sda2 分区的内容全部复制到一个新分区(/dev/sda4),并且两个分区磁盘要一摸一样
#首先进行分区 
$gdisk /dev/sda
 n   ->   +1100M   -> 8300  -> w  -> y     
 
$partprobe     #更新核心分区列表

#不需要进行格式化,直接可以进行 sector 表面的复制.
$dd if=/dev/sda2 of=/dev/sda4         #直接进行扇区复制,完成后,两个磁盘相同, UUID都相同.

$xfs_repair -L /dev/sda4              #一定要先清除一堆 log 才行! 
$xfs_admin -U ($uuidgen) /dev/sda4    #赋予一个新的 UUID, 否则无法挂载

$mount /dev/sda4 /mnt         #可以尝试挂载,并检查文件了.
```

## 小结

* 压缩指令为通过一些运算方法去将原本的文件进行压缩，以减少文件所占用的磁盘容 量。 压缩前与压缩后的文件所占用的磁盘容量比值， 就可以被称为是“压缩比”
* 压缩的好处是可以减少磁盘容量的浪费，在 WWW 网站也可以利用文件压缩的技术来进 行数据的传送，好让网站带宽的可利用率上升喔
* 压缩文件的扩展名大多是:“.gz, .bz2, .xz, .tar, .tar.gz, .tar.bz2, \*.tar.xz” 常见的压缩指令有 gzip, bzip2, xz。压缩率最佳的是 xz，若可以不计时间成本，建议使用 xz 进行压缩。
*  tar 可以用来进行文件打包，并可支持 gzip, bzip2, xz 的压缩。
*  压 缩:tar -Jcv -f filename.tar.xz 要被压缩的文件或目录名称
*  查 询:tar -Jtv -f filename.tar.xz
*  解压缩:tar -Jxv -f filename.tar.xz -C 欲解压缩的目录
*  xfsdump 指令可备份文件系统或单一目录
*  xfsdump 的备份若针对文件系统时，可进行 0-9 的 level 差异备份!其中 level 0 为完整 备份;
*  xfsrestore 指令可还原被 xfsdump 创建的备份文件;
*  要创建光盘烧录数据时，可通过 mkisofs 指令来创建;
*  可通过 wodim 来写入 CD 或 DVD 烧录机
*  dd 可备份完整的 partition 或 disk ，因为 dd 可读取磁盘的 sector 表面数据
*  cpio 为相当优秀的备份指令，不过必须要搭配类似 find 指令来读入欲备份的文件名数



