# BASH

**因为** **shell 是应用程序, 在操作系统的最外层, 所以 shell 被称为壳程序.**

**只要能够操作应用程序的接口都能够被称为壳程序.**

**上次登录执行过的指令都保存在  `~/.bash_history` 中, 本次登录执行的指令保存在内存中, 当你下线时才会写入这个文件.**

{% hint style="info" %}
别名  **`$alisa   别名='命令'`**
{% endhint %}

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

{% hint style="info" %}
**`$`  是一个变量,本身有意义,表示 目前这个 Shell 的线程ID, 也就是当前shell的PID**    

 **`$echo    $$                 #这样就得到了目前 shell 的PID`**
{% endhint %}

#### ?   变量\(上个执行指令的返回值\)

{% hint style="info" %}
**`?` 变量是非常有用的,   可以得到上个执行程序和指令的返回值. 用来查看是否有错误代码.**

**`$echo   $?                 #这样就得到上个程序或进程的返回值了.`**
{% endhint %}

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








