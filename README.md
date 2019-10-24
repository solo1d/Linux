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

$date +%Y%m%d
    输出: 20191021     #日期 2019年  10月 21日
$date +%Y/%m/%d-%H:%M
    输出: 2019/10/21-18:07    #日期 2019年 10月 21日 18点 07分
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
$iconv -f utf8 -t big5 a | iconv -f big5 -t gb2312 | iconv -f gb2312 -t utf8 -o b
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



\*\*\*\*









