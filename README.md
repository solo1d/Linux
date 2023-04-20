
# Linux

## 操作系统主要管理的的就是整个硬件功能.

## 主要是 Linux 系统结构和命令.

### 终端乱码解决方案

```bash
终端乱码:   (下面两个解决方案)
    临时生效
        $export LANG=en_US.UTF-8
        $export LC_ALL=en_US.UTF-8

    永久生效->  修改 /etc/locale.conf  文件, 将下面的内容写入文件(会将系统变成英文)
        LC_ALL=en_US.UTF-8
```

## 关机和重启以及内存数据写会到磁盘

```bash
$sync     将内存数据写会到硬盘命令

关机前 应该使用 $sync 命令来将在内存的数据写会到硬盘中.
    关机脚本:  sudo sync && sudo sync && sudo shutdown -h now
```

## 查看当前 Linux所支持的文件系统

```bash
 $ sudo ls -l /lib/modules/$(uname -r)/kernel/fs
 
 #系统目前已载入到内存中支持的文件系统则有:
$cat /proc/filesystems
```

## 挂载点的设备文件名

```bash
$df -T /boot         #后面的/boot  可以换成挂载点(目录)
```

## 挂载硬盘命令

```bash
$mount  -t  文件系统  UUID=''    挂载点目录        #也可以不需要-t和文件系统
$blkid     #会列出所有设备的 UUID和文件系统类型
```

## 获得CPU核心数量

```bash
$grep 'processor' /proc/cpuinfo
 processor : 0
 processor : 1
# 这是表示有两颗 cpu核心的意思, (一颗CPU,两颗CPU核心  / 或者一颗CPU,一颗核心<超线程>)
```

## 获得当前时间和格式化输出当前时间

```bash
$date  +正则表达式
%Y    年份   2019
%m    月份   01
%d    日期   03
%H    小时   23
%M    分钟   02
#中间可以穿插特殊符号,也可以无间隙


选项和参数:
--date='2 days ago' +%Y%m%d         #表示两天前的日期, 输出:20191030  今天是20191101
--date='1 days ago' +%Y%m%d         #表示一天前的日期, 输出:20191031  今天是20191101

--date="YYYYMMDD"  +%s	     #选中 YYYY(年) MM(月) DD(日) 的那天.  +%s 是转换成距离从
			                       # 19700101 那天到 YYYYMMDD  那一天所经过的秒数.

$date +%Y%m%d
    输出: 20191021     #日期 2019年  10月 21日
    
$date +%Y/%m/%d-%H:%M
    输出: 2019/10/21-18:07    #日期 2019年 10月 21日 18点 07分
    
$date --date="20191010" +%s    #日期是2019年10月10日,从19700101到那天所需要的秒数
	  输出: 1570636800               #意思就是从  19700101 到 20191010 需要经过这么多秒

#当前日期
$ date +%F

#当前时间
$ date +"%F %H:%M:%S"

#昨日
$ date -d yesterday +%F

#上一个月
$ date -d "$(date +%Y%m)01 last month" +%Y%m

#当月
$ date +%Y-%m

#下一个月 
$ date -d "$(date +%Y%m)01 next month" +%Y%m
```

## 更新核心分区列表, 磁盘分区完毕后,必须执行一次

```bash
$partprobe   #更新核心分区列表
```

## **DOS 与 Linux 的断行字符 \(LF , CRLF\)**

**需要安装格式化转工具\(dos2unix\), 将 `DOS 的 CRLF` 转换成 `Unix 的 LF` , 反之亦然.**

```bash
#dos格式文件转换成 unix  (CRLF -> LF)
linux@apt$sudo apt-get install dos2unix
linux@yum$sudo yum  install dos2unix
mac@brew$brew  install dos2unix

#unix格式文件转换成 dos  (LF -> CRLF)
linux@apt$sudo apt-get install unix2dos
linux@yum$sudo yum  install unix2dos
mac@brew$brew  install unix2dos

光盘安装则是 (CentOS7)
$mount /dev/sr0 /mnt ; rpm -ivh /mnt/Packages/dos2unix* ;umount /mnt 

#介绍
$dos2unix    [-kn]  file  [newfile]
$unix2dos    [-kn]  file  [newfile]
选项与参数:
-k    :保留该文件原本的 mtime(修改时间)  时间格式 ( 不更新文件上次内容经过修订的时间)
-n    :保留原本的旧文件, 将转换后的内容输出到新文件.如: $dos2unix -n old new

范例: 将file1 转换成 unix
$dos2unix  -kn file1 newfile1
```

## 语系编码转换

```bash
$iconv   --list
$iconv  -f 原本编码  -t 新编码  文件名  [-o  新文件名]
参数和选项:
--list    :列出支持的语系数据
-f        :来源文件的编码 (可以通过 $file  filename 查询)
-t        :转换之后的新编码
-o  新文件名   :如果想保留原本的文件,就要使用这个参数来重新指定一个新的文件

范例:  将 file1 (big5) 编码的文件,转换成 utf8 编码的新文件 utf.file, 并保留原文件.
$iconv  -f big5 -t utf8  file1  -o  unt.file

范例2: 将繁体字文件 a(utf8) 转换成简体字 b(utf8). 
$iconv -f utf8 -t big5 输入文件 | iconv -f big5 -t gb2312 | iconv -f gb2312 -t utf8 -o 输出文件
    #先转成 big5, 再转成 gb2312  再转成 utf8 .
```

## 语系变量.系统编码 修改和查询

```bash
#这些语系文件都 放置在: /usr/lib/locale/ 这个目录中。
#整体系统默认的语系定义在 /etc/locale.conf  文件中.

$locale        #会输出当前设置的编码
输出:
LANG="zh_CN.UTF-8"            #主语言环境
LC_COLLATE="zh_CN.UTF-8"      #字串的比较与排序等
LC_CTYPE="zh_CN.UTF-8"        #字符(文字) 辨识的编码
LC_MESSAGES="zh_CN.UTF-8"     #讯息显示的内容, 如功能表, 错误讯息等.
LC_MONETARY="zh_CN.UTF-8"     #币值格式的显示
LC_NUMERIC="zh_CN.UTF-8"      #数字系统的显示讯息
LC_TIME="zh_CN.UTF-8"         #时间系统的显示数据
LC_ALL=                       #整体语系的环境
------------------------------------------------
$locale   -a     #会输出当前系统所支持的全部编码
.......

------------------------------------------------
修改的话, 直接修改变量即可,  只需要修改 LANG 或者 LC_ALL 就可以,其他的都会根据这两个进行变化.
$export LANG="en_US.UTF-8"

只要修改/etc/sysconfig/i18n文件就可以修改当前的系统字符集，它可以用来配置当前的语言，字符集等
		$ vim /etc/sysconfig/i18n  
					
				LANG="zh_CN.GB2312" 		   # (指定当前操作系统的字符集)
				SUPPORTED="zh_CN.GB2312"	 #(指定当前操作系统支持的字符集)
				SYSFONT="lat0-sun16"	    #(指定当前操作系统的字体)
```

## 在某条命令中嵌入更多命令

```bash
使用  `命令`   或  $(命令)   这两种方式就可以在任何时候进行嵌入.
$echo  `uname -a`   >>  $(pwd)/uname.file
    # 解释: 首先运行 uname -a 命令, 将返回值传递给 echo 命令, 然后重定向
    # 再次进行 pwd 命令,得到路径 并且将得到的内容写入uname.file 这个新文件内.

#进入目前核心的模块目录
$cd /lib/modules/$(uname -r)/kernel    
    #$uname -r 会输出 当前linux 的版本.
```



## echo 命令

```bash
$echo    -e   多个字符串或变量
选项和参数
-e   :允许对字符串或变量内的转义字符进行解释, 也就是 \n 可以被解释为换行,而不是仅仅输出成文本
		  也包括字符串内嵌 ${变量}  这种变量解释.

$echo  -e  "\n your name  ${name} \n"      #name=Linux
输出: 
your name  Linux
```



## 目前主机启动的服务

```bash
$netstat -tuln
Active Internet connections (only servers)
Proto Recv-Q  Send-Q   Local Address           Foreign Address         State      
tcp        0       0   127.0.0.1:631           0.0.0.0:*               LISTEN     
tcp        0       0   127.0.0.1:25            0.0.0.0:*               LISTEN   
#封包格式               本地端口                  远程端口                 是否监听

#Local Address  是重点,表示的是本机所启动的网络服务.
#	    IP部分说明的是该服务位于那个接口上.
#	           127.0.0.1  表示针对本机开放
#	           0.0.0.0  或 :::  则表示对整个 Internet 开放.
#	    后面的端口号都有其特定的网络服务.
#   80:www    22:ssh    21:ftp    25:mail   111:RPC 远端程序调用   631:CUPS 打印服务功能
```

## 端口和服务对照表文件

```bash
$vim /etc/services          #这个文件内记录了所有端口和服务的说明和对照.
```

## /dev/shm 基于内存的 temps 文件系统

**/dev/shm 目录下的内容是在内存中存储的, 所以速度会非常快, 但是断电也会造成数据消失.**

- /dev/shm 是一个tmpfs文件系统，临时文件系统，是基于内存的文件系统，也就是说/dev/shm中的文件是直接写入内存的，而不占用硬盘空间.
- /dev/shm 是一个tmpfs文件系统，临时文件系统，是基于内存的文件系统，也就是说/dev/shm中的文件是直接写入内存的，而不占用硬盘空间。
- 在Redhat/CentOS等linux发行版中默认大小为物理内存的一半。最大可达到 物理内存+SWAP的大小
- /dev/shm不是立即占用内存，而是采用需要才占用内存的方法。在上面的例子中，/dev/shm设置的值是20G，我们看到已用写入了9.5G的数据，也就是占用了9.5G的内存。 
- tmpfs 文件系统会完全驻留在内存 RAM 中，读写速度快 
- tmpfs 数据在重新启动之后不会保留，例如重启，重新加载，绑定等操作都会清空/dev/shm下的内容 .









