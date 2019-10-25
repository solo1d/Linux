# BASH

**因为** **shell 是应用程序, 在操作系统的最外层, 所以 shell 被称为壳程序.**

**只要能够操作应用程序的接口都能够被称为壳程序.**

**上次登录执行过的指令都保存在  `~/.bash_history` 中, 本次登录执行的指令保存在内存中, 当你下线时才会写入这个文件.**

别名  **`$alisa   别名='命令'`**

### **分辨 指令是来自bash 还是 外部**

```bash
#有的指令是内置在 bash中(cd), 有的指令则不是内置, 需要一个命令来探查出来. type命令也是bash内置的
$type  [-tpa] name
选项和参数:
    :不添加任何参数和选项时, type 会显示出 name 是外部指令还是 shell bash 的内置指令.
-t  :会显示出下面的一些字眼,来表示一些具体意义.
        file    :表示为外部指令;
        alias   :表示该指令为命令别名所设置的名称
        builtin :表示该指令为 bash 内置的指令功能;
-p  :如果后面的 name 为外部指令时, 才会显示完整的文件名;
-a  :会由 PATH 变量定义的路径中,将所有含 name 的指令都列出来, 包括 alias(别名),更加详细.

范例1: 查询 ls 这个是否为 bash 内置.
$type  -a ls 
输出:   ls 是 `ls --color=auto' 的别名            #表示是别名,而不是内置
       ls 是 /usr/bin/ls                        #这一行就表示ls在自文件中的位置

范例2: 查看 cd 是否为 bash 内置.
$type -a cd
输出:  cd 是 shell 内嵌                #表示 cd 是 bash 内嵌指令
      cd 是 /usr/bin/cd               #这个指令在文件中的位置.
```

## Shell 变量功能

**变量: `变量就是以一组文字或符号等，来取 代一些设置或者是一串保留的数据`**

**变量分为 `自定变量` 与 `环境变量` ,两者的差异是 "`该变量是否被子程序所继续引用`"**

* **`自定变量`  不可以被子程序继承**
* **`环境变量`  可以被子进程继承**

#### **变量取用  echo** 

```bash
$echo   ${变量}
$echo   ${PATH}
输出: /usr/lib64/qt-3.3/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:
        /usr/sbin:/home/dmtsai/.local/bin:/home/dmtsai/bin

[dmtsai@study ~]$ echo ${MAIL}
输出:        /var/spool/mail/dmtsai

[dmtsai@study ~]$ echo ${HOME}
输出:        /home/dmtsai
```

### **设置和修改变量**

* **变量设置规则:**
  * **必须用 '=' 号链接 , 而且不可以在 '=‘  号 左右出现空格.**
  * **变量名称只能是英文和数字, 而且开头必须是英文,绝不可以是数字.**
  * **变量内容若有空白字符可使用** _**`双引号""`**_ **或** _**`单引号''`**_ **将变量内核结合起来, 但是:**
    * _**`双引号`**_**的特殊字符如   $  等,可以保有原本的特性, 如下所示:** 
      * **`var="lang is $LANG"` 会变成:   `echo ${var}   ->  lang is zh_CH.utf8`**
    * _**`单引号`**_**内的特殊字符则为一般字符\(纯文本\), 如下所示:**
      * **`var='lang is $LANG`'   会变成 `echo ${var}    ->  lang is $LANG`**
  * 可用 '\' 转义字符将特殊符号 \(如 \[Enter\] ,$ ,\ ,空白字符,等\) ,变成一般字符, 如 
    * **`myname=VBird\ Tsai`   会变成  `echo ${myname}   ->  VBird Tsai`**
  * **若该变量为扩增变量内容时，则可用 `$变量名称`"或 `${变量}` 累加内容，如下所示: `PATH="$PATH":/home/bin`或`PATH=${PATH}:/home/bin`**
    * **若该变量需要在其他子程序执行，则需要以 `export` 来使变量变成环境变量: `$export PATH`**
* **取消变量**
  * **使用命令  `$unset 变量名`    就可以,  如:  `$unset  myname`**

```bash
$echo  ${myname}       #myname 是一个没有设置过的变量, 是一个空值,不会有任何输出
$myname=VBird          #现在 myname 是一个变量了,它代表 VBird 这个字符了
$echo  ${myname}       #这样设置过之后就可以输出了, 但他只是临时的.
输出: VBird

使用 $set   可以查看所有的变量和环境变量.
使用 $unset 变量名    可以取消变量.
```

### 环境变量的功能

**`env`** 命令和  **`export`** 命令 都可以得到环境变量列表.

```bash
#显示目前我shell 环境中的 环境变量
$env             #直接输入这个命令就可以
输出:

HOSTNAME=study.centos.vbird       #这部主机的主机名称
TERM=xterm            #这个终端机使用的环境是什么类型
SHELL=/bin/bash              # 目前这个环境下，使用的 Shell 是哪一个程序?
HISTSIZE=1000           # “记录指令的笔数”在 CentOS 默认可记录 1000 笔
OLDPWD=/home/dmtsai          # 上一个工作目录的所在
LC_ALL=en_US.utf8          # 语系，
USER=dmtsai              #使用者的名称
LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;
             01or=40;31;01:mi=01;05;37;41:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:
             st=37;44:ex=01;32
*.tar=01...       # 一些颜色显示
MAIL=/var/spool/mail/dmtsai     # 这个使用者所取用的 mailbox 位置
PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/dmtsai/.local/bin:/home/dmts
PWD=/home/dmtsai     #目前使用者所在的工作目录 (利用 pwd 取出!)
LANG=zh_TW.UTF-8       #这个与语系有关，下面会再介绍!
HOME=/home/dmtsai       # 这个使用者的主文件夹啊!
LOGNAME=dmtsai       # 登陆者用来登陆的帐号名称
_=/usr/bin/env    #上一次使用的指令的最后一个参数(或指令本身)
```

```bash
#用在 分享自己的变量设置给后来调用的文件或其他程序 .(就是将自定变量 转换成 环境变量)
$export     变量名称
```

####  $    变量\(关于本 shell 的PID\)

**`$`  是一个变量,本身有意义,表示 目前这个 Shell 的线程ID, 也就是当前shell的PID**    

 **`$echo    $$                 #这样就得到了目前 shell 的PID`**

#### ?   变量\(上个执行指令的返回值\)

**`?` 变量是非常有用的,   可以得到上个执行程序和指令的返回值. 用来查看是否有错误代码.**

**`$echo   $?                 #这样就得到上个程序或进程的返回值了.`**

### 变量 键盘读取, 阵列与宣告 : read, array, declare

```bash
$read  [-pt]  变量名
选项与参数:
-p   :后面可以接提示字符!
-t   :后面可以接等待的 '秒数', 如果达到设定时间,那么就自动略过 (结束)

范例: 提示使用者在30秒之内输入自己的名字,并给出提示, named是个变量,没有赋予任何数值.
$read -p "Please keyin your name: " -t 30 named
输出: Please keyin your name:  ppq
$echo  ${named}
输出: ppq
```
- **变量默认是字符串, 若不指定变量类型,则 1+2 为一个字符串 而不是计算式**
- **bash 环境中的数值运算, 默认最多仅能达到整数形态,  所以 1/3 结果是0.**

```bash
$declare  [-aixr]  变量名
选项与参数:
-a    :将后面的 变量 的变量定义成为阵列(array)类型
        +a    :可以取消上面定义的 阵列(array)类型
-i    :将后面的 变量 的变量定义成为 整数数字(integer) 类型
        +i    :可以取消上面定义的 整数数字(integer) 类型
-x    :用法与 export 一样,就是将后面的 自定变量 变成环境变量.
        +x    :可以将 环境变量 修改为  自定变量
-r    :将变量设置称为 readonly(只读) 类型,不可被更改,也不能unset取消, (重新登录即可恢复)
        +r    :将只读变量 修改为 非只读变量
-p    :可列出后面变量的类型.
# declare [tab] [tab]  可以列出所有的变量.

范例: 让变量 sum 进行 100+300+50 的加总结果.
$declare  -i sum=100+300+50
$echo  ${sum}
输出:  450

范例: 将 sum 变成环境变量
$declare  -x sum
$exprot  | grep sum      #exprot会输出环境变量列表. gerp 会进行查询
输出: declare -ix sum="450"        #sum是整数类型, 并且具有 环境变量属性

范例: 将sum 变成 自定变量 ( 取消环境变量)
$declare  +x  sum
$export | grep sum          #什么都不会输出了,因为不是环境变量了.
$echo ${sum}
输出: 450                    #这样就可以输出了
```

#### 设置一个阵列 (就是一个数组)
```bash
$var[1]="on1" ;var[2]="on2" ;var[3]="on3"
$echo ${var[1]} ${var[2]}  ${var[3]}
    输出: on1 on2 on3
$echo ${var[*}}            # *是万用字符,这样写和上面写效果相同,但是会逐个进行遍历,更加方便
    输出: on1 on2 on3
```

#### 变量内容的删除,取代与替换 (Optional)
**修改和取代以及替换都与命令无关, 只是格式化.**
##### 变量内容的删除
- 其实并不是删除,而是进行了格式化输出, 变量本身没有任何变化.
	- **`#`**代表从**前面开始向后面**删除,且删除一个最**短**的字符串
	- **`##`**代表从**前面开始向后面**删除,且删除一个最**长**的字符串
	- **`%`**代表从**后面开始向前面**删除,且删除一个最**短**的字符串
	- **`%%`**代表从**后面开始向前面**删除,且删除一个最**长**的字符串

```bash
$path=${PATH}
$echo ${path}	
输出: /usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/dmtsai/.local/bin:/home/dmtsai/bin

#  从前面开始想后面删除  #  
$echo ${path#/*local/bin:}	#删除最短的 /usr/local/bin: 这一串字符串.只有这个是完全匹配的
				#其实/home/dmtsai/.local/bin: 也匹配,只不过他不是最短的.
输出: 
/usr/bin:/usr/local/sbin:/usr/sbin:/home/dmtsai/.local/bin:/home/dmtsai/bin

$echo  ${path##/*:}     #删除一个最长的字符串 / 开头 :结尾  ,只留下 最后一个. 字符匹配是关键
输出:    
/home/dmtsai/bin	#看整体的字符串, 开头是/ ,这个 /home 之前就是一个 : 符号.



#从后面想前面删除  #
$echo  ${path%*bin}
输出:
/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/dmtsai/.local/bin:/home/dmtsai/		#仅仅只是少了最后面的一个 bin 字符串

$echo  ${path%%:*}
输出: /usr/local/bin		#只剩下了一个

$echo  ${path%%bin*}	    
输出: /usr/local/bin		#和上面有相同的效果.因为是删除最长的一个,所以他会向前搜寻.

```
##### 变量内容的替换
- **`变量/旧/新`** 表示从前到后进行替换, 只替换一个位置
- **`变量//旧/新`** 表示从前到后进行替换, 会替换字符串中所有的位置. 
```bash
$echo  ${path}
输出:
/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/dmtsai/.local/bin:/home/dmtsai/bin

$echo  ${path/sbin/SBIN}    #只替换从头开始的一个串 位置
输出:
/usr/local/bin:/usr/bin:/usr/local/SBIN:/usr/sbin:/home/dmtsai/.local/bin:/home/dmtsai/bin

$echo  ${path//bin/BIIN}   #替换串内所有的位置
输出:
/usr/local/BIN:/usr/BIN:/usr/local/sBIN:/usr/sBIN:/home/dmtsai/.local/BIN:/home/dmtsai/BIN

```
##### 变量的测试与内容替换
- **`-`** 如果前面测试的变量为**未设定**(不是空串),则会将 **`-`** 后面的字符串
	- $echo  ${path-root}       #只是测试,而不是赋值,如果path是空值,则会输出root
	- $path=${path-root}        #测试,并将结果赋值,path如果是空值,则将root赋值给path
- **`:-`** 前面测试的变量为 空串或未设定 ,则会用 -: 后面的字符串来替换.
	- $echo  ${path:-root}    #只是测试,而不是赋值,如果path是空值或空字符串,则会输出root
	- $path=${path:-root}     #测试,将结果赋值,path如果是空值或空字符串,则将root赋值给path

# 与文件系统 及 程序的限制关系 : ulimit

**bash 是可以限制使用者的某些资源,包括打开文件的数量, 可以使用的CPU时间, 可以使用的内存总量 等等,  通过 `ulimit`  来进行设置.**

```bash
$ulimit   [-SHacdfltu]  [配额]
选项与参数:
-H    :hard limit, 严格的设置,必定不能超过这个设置的数值
-S    :soft limit, 警告的设置, 可以超过这个设置值,但是若超过则有警告讯息.
	在设置上,通常 soft 会比 hard 小, 举例来说, soft 可设置为80, 而hard 在设置为100,
	那么你可以使用到90, (因为没有超过100), 但介于 80~100 之间时,系统会有警告讯息通知你.
-a    :后面不接任何选项与参数,可列出所有的限制额度;
-c    :当某些程序发生错误时,系统可能会将程序在内存中的信息写成文件(排错用),
	这种文称为核心文件(core file), 此为限制每个核心文件的最大容量.
-f    :此 shell 可以创建的最大文件大小(一般可能设置为 2GB)单位为 KBytes
-d    :程序可使用的最大断裂内存(segment)容量;
-l    :可用于锁定 (lock) 的内存量
-t    :可使用的最大 CPU 时间 (单位为秒)
-u    :单一使用者可以使用的最大程序(process)数量。

范例1: 列出当前身份的所有限制数据值.(一般账号)
$ulimit -a
输出:
core file size          (blocks, -c) 0		  #0表示没有限制
data seg size           (kbytes, -d) unlimited	  #unlimited表示无限
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited	  #可创建的但一文件的大小
pending signals                 (-i) 4314
max locked memory       (kbytes, -l) 64
max memory size         (kbytes, -m) unlimited
open files                      (-n) 1024	  #同时可以打开的文件数量
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 4096
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited

范例2: 限制当前使用者仅能创建 10MBytes 以下容量的文件
$ulimit  -f 10240
$ulimit  -a | grep 'file size'
输出:
core file size          (blocks, -c) 0
file size               (blocks, -f) 10240	#最大量值为 10MBbytes

#尝试创建大于 10MB 的文件会失败:
$dd if=/dev/zero of=test.file  bs=1M count=20    #尝试创建一个20MB的文件
输出 :  文件大小超出限制(吐核)			#虽然报了错,但是这个文件还是会出现
$ls -lh test.file
输出: -rw-rw-r--. 1 dmtsai dmtsai 10M 10月 24 11:19 test.file	 #只是10MB
 
#删除这个新创建的文件,并重新登录,即可解开限制. 
#文件限制 只可以越来越小,不可以增大.
#如果是root, 则直接显示: unlimit  无限制.
```


# 命令别名与历史命令
### 别名 alias
```bash
#设置别名
$alias  别名='指令选项'
$alias  lm='ls -la | more'

#直接输入 alias 会列出所有的设置过的别名.

#取消别名
$unalias  别名
$unalias  lm
```

### 历史命令 history
**HISTFILESIZE 这个变量决定了 history 会保存多少条指令.**
**登录主机的时候,系统会主动读取 ~/.bash_history 这个文件,来获得你曾经下过的指令**
**登录主机之后, 你所下达的指令都会在你退出登录之后 ,才会写入 ~/.bash_history 文件中**
```bash
$history  数字
$history  [-c]
$history  [-raw]  histfiles
选项与参数:
数字 :意思是“要列出最近的 多少条 命令列表”的意思.
-c  :将目前的 shell 中的所有 history 内容全部消除
-a  :将目前新增的 history 指令新增入 histfiles 中，若没有加 histfiles(就是指定个文件),
	则默认写入 ~/.bash_history
-r  :将 histfiles 的内容读到目前这个 shell 的 history 记忆中(就是拷贝一份);
-w  :将目前的 history 记忆内容写入 histfiles 中,如果未指定,则默认写入 ~/.bash_hiistory

#执行错误 或者 无法执行的 指令都会进行存储.

范例一:列出目前内存内的所有 history 记忆
$history	
输出   .....    #省略,从1开始
      858  echo  ${path}
      859  echo  ${path:-root}
      860  history

范例二:列出目前最近的 3 笔数据
$history  3
输出:  859  echo  ${path:-root}
      860  history
      861  history  3

范例三:立刻将目前的数据写入 histfile 当中
$ history -w		#在默认的情况下，会将历史纪录写入 ~/.bash_history 当中!

范例四: 清空指令历史
$history -cw      #必须同时使用 -c -w, -c 是清空, -w 是强制更新到文件.

```

#### 执行曾经执行过的指令
```bash
$!数字
	#这个数字表示: 执行第几个指令的意思,(~/.bash_history 文件中的)
$!指令字符串开头
	#在 ~/.bash_history 中寻找与 指令字符串开头相仿的指令,并执行.

$history  5
输出:
  867  vim .bash_history 
  868  history -w aaa
  869  ls
  870  vim aaa
  871  history  5

$!869
输出: 
ls
aaa      Documents  Music     Public     Videos

$!!	  #执行上一条执行过的指令, 就是 $!869  也就是 $ls

$!vim      #会执行 $vim aaa   因为它是最近执行的指令.
```

## Bash Shell 的操作环境

- **指令运行的顺序**
	- **以相对/绝对路径执行指令，例如“/bin/ls”或“./ls”;**
	- **由 **`alias(别名)`** 找到该指令来执行;**
	- **由 bash 内置 **`(builtin)`** 指令来执行.**
	- **通过 $PATH 这个变量的顺序搜寻到的第一个指令来执行.**
- **可以通过执行 $type -a 指令  来得到执行顺序.排在前面的就会先执行.**

### bash 的进站与欢迎讯息 : /etc/issue ,  /etc/motd


进站讯息(就是未登陆前提示的讯息),存放在 /etc/issue 文件中.
```bash
$cat /etc/issue
输出:
\S
Kernel \r on an \m

里面的反斜杠作为变量 man issue 配合 man agetty 


```











